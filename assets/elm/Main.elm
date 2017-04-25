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


-- APP


main =
    program
        { init = init
        , update = update
        , subscriptions = always Sub.none
        , view = view
        }


init =
    ( ""
    , fetchEntry
    )



-- MODEL


type alias Model =
    String


type alias Entry =
    String


model : String
model =
    ""



-- UPDATE


type Msg
    = Change String
    | Success (Result Http.Error String)
    | InitialEntry (Result Http.Error String)


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        InitialEntry (Ok response) ->
            ( response
            , Cmd.none
            )

        InitialEntry (Err response) ->
            ( ""
            , Cmd.none
            )

        Change body ->
            ( body
            , Http.send Success (postEntry body)
            )

        Success response ->
            ( model
            , Cmd.none
            )


parseResponse string =
    string ++ "!"



-- VIEW
-- Html is defined as: elem [ attribs ][ children ]
-- CSS can be applied via class names or inline style attrib


view : Model -> Html Msg
view model =
    div [ class "container", style [ ( "margin-top", "30px" ), ( "text-align", "center" ) ] ]
        [ div [ class "row" ]
            [ div [ class "col-xs-12" ]
                [ div [ class "jumbotron" ]
                    [ h2 [] [ text ("Five Hundo") ]
                    , textarea [ rows 30, cols 100, onInput Change ] [ text model ]
                    , p [] [ wordCountLabel model ]
                    ]
                ]
            ]
        ]


wordCountLabel : String -> Html Msg
wordCountLabel body =
  case wordCount body of
    0 -> text "No Words"
    1 -> text "1 Word"
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
