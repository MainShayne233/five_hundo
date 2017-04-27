module Main exposing (..)

import Html exposing (Html, program, div, p, h2, textarea, text)
import Html.Attributes exposing (class, style, rows, cols)
import Html.Events exposing (onInput)
import Regex exposing (split, regex)
import Http exposing (post)
import Json.Encode as Encode
import Json.Decode as Decode
import Debounce exposing (Debounce)
import Time exposing (second)
import Task exposing (perform, succeed)


-- APP


main =
    program
        { init = init
        , update = update
        , subscriptions = always Sub.none
        , view = view
        }


init =
    ( model
    , fetchEntry
    )



-- MODEL


type alias Model =
    { entry : String
    , persistDebounce : Debounce String
    , setIdleDebounce : Debounce String
    , action : Action
    }


type alias Entry =
    String


model : Model
model =
    { entry = ""
    , persistDebounce = Debounce.init
    , setIdleDebounce = Debounce.init
    , action = Idle
    }



-- DEBOUNCE


persistDebounceConfig : Debounce.Config Msg
persistDebounceConfig =
    { strategy = Debounce.later (0.5 * second)
    , transform = PersistDebounce
    }


setIdleDebounceConfig : Debounce.Config Msg
setIdleDebounceConfig =
    { strategy = Debounce.later (0.5 * second)
    , transform = SetIdleDebounce
    }



-- UPDATE


type Action
    = Typing
    | Idle
    | Save


type Msg
    = Change String
    | PersistSuccess (Result Http.Error String)
    | InitialEntry (Result Http.Error String)
    | PersistDebounce Debounce.Msg
    | SetIdleDebounce Debounce.Msg
    | PersistEntry String
    | SetIdle String


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        InitialEntry (Ok response) ->
            ( { model | entry = response }
            , Cmd.none
            )

        InitialEntry (Err response) ->
            ( { model | entry = "" }
            , Cmd.none
            )

        Change body ->
            let
                ( debounce, cmd ) =
                    Debounce.push persistDebounceConfig body model.persistDebounce
            in
                ( { model | entry = body, persistDebounce = debounce, action = Typing }
                , cmd
                )

        PersistSuccess response ->
            let
                ( debounce, cmd ) =
                    Debounce.push setIdleDebounceConfig "" model.setIdleDebounce
            in
                ( { model | setIdleDebounce = debounce }
                , cmd
                )

        PersistDebounce msg ->
            let
                ( debounce, cmd ) =
                    Debounce.update
                        persistDebounceConfig
                        (Debounce.takeLast persistEntry)
                        msg
                        model.persistDebounce
            in
                ( { model | persistDebounce = debounce }
                , cmd
                )

        SetIdleDebounce msg ->
            let
                ( debounce, cmd ) =
                    Debounce.update
                        setIdleDebounceConfig
                        (Debounce.takeLast setIdle)
                        msg
                        model.setIdleDebounce
            in
                ( { model | setIdleDebounce = debounce }
                , cmd
                )

        PersistEntry entry ->
            ( { model | action = Save }
            , Http.send PersistSuccess (postEntry entry)
            )

        SetIdle str ->
            ( { model | action = Idle }
            , Cmd.none
            )


parseResponse string =
    string ++ "!"


persistEntry entry =
    perform PersistEntry (succeed entry)


setIdle str =
    perform SetIdle (succeed str)



-- VIEW
-- Html is defined as: elem [ attribs ][ children ]
-- CSS can be applied via class names or inline style attrib


view : Model -> Html Msg
view { entry, action } =
    div [ class "container", style [ ( "margin-top", "30px" ), ( "text-align", "center" ) ] ]
        [ div [ class "row" ]
            [ div [ class "col-xs-12" ]
                [ div [ class "jumbotron" ]
                    [ h2 [] [ text ("Five Hundo") ]
                    , textarea [ rows 30, cols 100, onInput Change ] [ text entry ]
                    , p [] [ wordCountLabel entry ]
                    , p [] [ actionLabel action ]
                    ]
                ]
            ]
        ]


actionLabel : Action -> Html Msg
actionLabel action =
    case action of
        Typing ->
            text "typing..."

        Save ->
            text "saved!"

        Idle ->
            text ""


wordCountLabel : String -> Html Msg
wordCountLabel body =
    case wordCount body of
        0 ->
            text "No Words"

        1 ->
            text "1 Word"

        count ->
            [ count
                |> toString
            , " Words"
            ]
                |> String.concat
                |> text


wordCount : String -> Int
wordCount body =
    let
        words =
            split Regex.All (regex " |\n") body
    in
        List.filter isWord words
            |> List.length


isWord : String -> Bool
isWord string =
    case String.trim (string) of
        "" ->
            False

        anything ->
            True



-- HTTP


entryDecoder =
    Decode.string


fetchEntry =
    let
        request =
            Http.get "/api/entries/today" Decode.string
    in
        Http.send InitialEntry request


encodeEntry : String -> Encode.Value
encodeEntry entry =
    Encode.object
        [ ( "entry", entry |> Encode.string ) ]


responseDecoder =
    Decode.string


postEntry : String -> Http.Request String
postEntry entry =
    let
        encodedEntry =
            encodeEntry (entry)
    in
        post
            ("/api/entries/save")
            (Http.stringBody "application/json" <| Encode.encode 0 <| encodeEntry entry)
            (responseDecoder)
