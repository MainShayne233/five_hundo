module Main exposing (..)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onInput)
import Regex
import Http exposing (post, Body)
import Json.Encode as Encode
import Json.Decode as Decode
import Json.Decode.Pipeline exposing (decode)
import RemoteData exposing (WebData)
import Debounce exposing (Debounce)
import Time exposing (..)
import Task exposing (..)


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
    , debounce : Debounce String
    }


type alias Entry =
    String


model : Model
model =
    { entry = "", debounce = Debounce.init }



-- DEBOUNCE


debounceConfig : Debounce.Config Msg
debounceConfig =
    { strategy = Debounce.later (1 * second)
    , transform = DebounceMsg
    }



-- UPDATE


type Msg
    = Change String
    | Success (Result Http.Error String)
    | InitialEntry (Result Http.Error String)
    | DebounceMsg Debounce.Msg
    | PersistEntry String


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
                    Debounce.push debounceConfig body model.debounce
            in
                ( { model | entry = body, debounce = debounce }
                , cmd
                )

        Success response ->
            ( model
            , Cmd.none
            )

        DebounceMsg msg ->
            let
                ( debounce, cmd ) =
                    Debounce.update
                        debounceConfig
                        (Debounce.takeLast persistEntry)
                        msg
                        model.debounce
            in
                ( { model | debounce = debounce }
                , cmd
                )

        PersistEntry entry ->
            ( model
            , Http.send Success (postEntry entry)
            )


parseResponse string =
    string ++ "!"


persistEntry entry =
    Task.perform PersistEntry (Task.succeed entry)



-- VIEW
-- Html is defined as: elem [ attribs ][ children ]
-- CSS can be applied via class names or inline style attrib


view : Model -> Html Msg
view { entry } =
    div [ class "container", style [ ( "margin-top", "30px" ), ( "text-align", "center" ) ] ]
        [ div [ class "row" ]
            [ div [ class "col-xs-12" ]
                [ div [ class "jumbotron" ]
                    [ h2 [] [ text ("Five Hundo") ]
                    , textarea [ rows 30, cols 100, onInput Change ] [ text entry ]
                    , p [] [ wordCountLabel entry ]
                    , p [] [ text entry ]
                    ]
                ]
            ]
        ]


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
            Regex.split Regex.All (Regex.regex " |\n") body
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
