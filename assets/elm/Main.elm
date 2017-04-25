module Main exposing (..)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onInput)
import Regex
import Http exposing (post, Body)
import Json.Encode as Encode
import Json.Decode as Decode exposing (Decoder)


-- APP
-- main : Program Never Model Msg
-- main =
--     Html.beginnerProgram
--         { model = model
--         , view = view
--         , update = update
--         }


main =
    program
        { init = init
        , update = update
        , subscriptions = always Sub.none
        , view = view
        }


init =
    ( ""
    , Cmd.none
    )



-- MODEL


type alias Model =
    String


model : String
model =
    ""



-- UPDATE


type Msg
    = Change String
    | Success (Result Http.Error String)


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        Change entry ->
            ( entry
            , Http.send Success (postEntry entry)
            )

        Success response ->
            ( model
            , Cmd.none
            )



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
                    , textarea [ rows 30, cols 100, onInput Change, placeholder "...what's up?" ] [ text model ]
                    , p [] [ wordCountLabel model ]
                    ]
                ]
            ]
        ]


wordCountLabel : String -> Html Msg
wordCountLabel body =
    [ wordCount body
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


encodeEntry : Model -> Encode.Value
encodeEntry model =
    Encode.object
        [ ( "entry", Encode.string model ) ]


responseDecoder =
    Decode.field "id_token" Decode.string


postEntry entry =
    let
        encodedEntry =
            encodeEntry (entry)
    in
        post
            ("/api/entries/save")
            (Http.stringBody "application/json" <| Encode.encode 0 <| encodeEntry entry)
            (responseDecoder)
