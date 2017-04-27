module View exposing (view)

import Html exposing (Html, div, p, h2, textarea, text)
import Html.Attributes exposing (class, style, rows, cols)
import Html.Events exposing (onInput)
import Regex exposing (split, regex)
import Msgs exposing (..)
import Models exposing (..)


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

        Saved ->
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
