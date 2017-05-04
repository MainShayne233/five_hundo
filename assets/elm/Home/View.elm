module View exposing (view)

import Html exposing (Html, div, p, h2, textarea, input, text, button)
import Html.Attributes exposing (class, style, rows, cols, placeholder, type_)
import Html.Events exposing (onInput, onClick)
import Regex exposing (split, regex)
import Msgs exposing (..)
import Models exposing (..)


view : Model -> Html Msg
view { entry, action, authorization, passwordMessage } =
    case authorization of
        Authorized ->
            div [ class "container", style [ ( "margin-top", "30px" ), ( "text-align", "center" ) ] ]
                [ div [ class "row" ]
                    [ div [ class "col-xs-12" ]
                        [ div [ class "jumbotron" ]
                            [ h2 [] [ text ("Five Hundo") ]
                            , textarea
                                [ rows 25
                                , cols 100
                                , onInput Change
                                , placeholder "..."
                                ]
                                [ text entry ]
                            , p [] [ wordCountLabel entry ]
                            , p [] [ actionLabel action ]
                            ]
                        ]
                    ]
                ]

        Checking ->
            div [] []

        NotAuthorized ->
            div [ class "container", style [ ( "margin-top", "30px" ), ( "text-align", "center" ) ] ]
                [ div [ class "row" ]
                    [ div [ class "col-xs-12" ]
                        [ div [ class "jumbotron" ]
                            [ h2 [] [ text ("Five Hundo") ]
                            , input
                                [ placeholder "Enter password..."
                                , type_ "password"
                                , onInput PasswordChange
                                ]
                                []
                            , button [ onClick (SubmitPassword entry) ] [ text "Submit" ]
                            , p [] [ text passwordMessage ]
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
