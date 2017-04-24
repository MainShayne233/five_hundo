module Main exposing (..)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onInput)
import Regex


-- APP


main : Program Never Model Msg
main =
    Html.beginnerProgram
        { model = model
        , view = view
        , update = update
        }



-- MODEL


type alias Model =
    String


model : String
model =
    ""



-- UPDATE


type Msg
    = Change String


update : Msg -> Model -> Model
update msg model =
    case msg of
        Change text ->
            text



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
                    , p [] [ text model ]
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
