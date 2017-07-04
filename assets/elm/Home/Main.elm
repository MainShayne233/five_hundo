module Main exposing (..)

import Debounce exposing (Debounce)
import Html exposing (Html, button, div, h2, img, input, p, program, text, textarea)
import Html.Attributes exposing (class, cols, placeholder, rows, src, style, type_)
import Html.Events exposing (onClick, onInput)
import Http exposing (post)
import Json.Decode as Decode exposing (Decoder)
import Json.Decode.Pipeline exposing (decode, hardcoded, optional, required, requiredAt)
import Json.Encode as Encode
import Regex exposing (regex, split)
import Task
import Time exposing (second)


-- APP


main : Program Never Model Msg
main =
    program
        { init = init
        , update = update
        , subscriptions = always Sub.none
        , view = view
        }



-- MODEL


type Action
    = Typing
    | Saved
    | Idle


type Authorization
    = Authorized
    | NotAuthorized
    | Checking


type DayGrade
    = Gutter
    | Spare
    | Strike
    | NoGrade


type DayStatus
    = Past
    | Present
    | Future
    | NoStatus


type alias Model =
    { entry : Entry
    , breakdown : WeekBreakdown
    , persistDebounce : Debounce String
    , setIdleDebounce : Debounce String
    , action : Action
    , authorization : Authorization
    , passwordMessage : String
    }


type alias WeekBreakdown =
    List DayBreakdown


type alias DayBreakdown =
    { grade : DayGrade
    , status : DayStatus
    }


type alias Entry =
    String


type alias EntryResponse =
    { entry : Entry
    , breakdown : WeekBreakdown
    }


type alias PostEntryResponse =
    { breakdown : WeekBreakdown
    }


type alias AuthorizationResponse =
    { authorized : Bool
    , breakdown : WeekBreakdown
    , entry : Entry
    }


model : Model
model =
    { entry = ""
    , breakdown = []
    , persistDebounce = Debounce.init
    , setIdleDebounce = Debounce.init
    , action = Idle
    , authorization = Checking
    , passwordMessage = ""
    }


init : ( Model, Cmd Msg )
init =
    ( model
    , checkIfAuthorized
    )


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



-- MSGS


type Msg
    = Change String
    | PasswordChange String
    | PasswordResponse (Result Http.Error AuthorizationResponse)
    | SessionResponse (Result Http.Error AuthorizationResponse)
    | SubmitPassword String
    | PersistSuccess (Result Http.Error PostEntryResponse)
    | PersistDebounce Debounce.Msg
    | SetIdleDebounce Debounce.Msg
    | PersistEntry String
    | SetIdle String



-- CMDS


persistEntry : String -> Cmd Msg
persistEntry entry =
    Task.perform PersistEntry (Task.succeed entry)


setIdle : String -> Cmd Msg
setIdle str =
    Task.perform SetIdle (Task.succeed str)



-- ENCODERS


encodeEntry : String -> Encode.Value
encodeEntry entry =
    Encode.object
        [ ( "entry", entry |> Encode.string ) ]


encodePassword : String -> Encode.Value
encodePassword password =
    Encode.object
        [ ( "password", password |> Encode.string ) ]



-- DECODERS


postEntryResponseDecoder : Decoder PostEntryResponse
postEntryResponseDecoder =
    decode PostEntryResponse
        |> required "breakdown" weekBreakdownDecoder


stringListDecoder : Decoder (List String)
stringListDecoder =
    Decode.list Decode.string


authorizationResponseDecoder : Decoder AuthorizationResponse
authorizationResponseDecoder =
    decode AuthorizationResponse
        |> required "authorized" Decode.bool
        |> required "breakdown" weekBreakdownDecoder
        |> required "entry" Decode.string


weekBreakdownDecoder : Decoder WeekBreakdown
weekBreakdownDecoder =
    Decode.list dayBreakdownDecoder


dayBreakdownDecoder : Decoder DayBreakdown
dayBreakdownDecoder =
    decode DayBreakdown
        |> required "grade" dayGradeDecoder
        |> required "status" dayStatusDecoder


dayGradeDecoder : Decoder DayGrade
dayGradeDecoder =
    stringToTypeDecoder decodeDayGrade


dayStatusDecoder : Decoder DayStatus
dayStatusDecoder =
    stringToTypeDecoder decodeDayStatus


stringToTypeDecoder : (String -> a) -> Decoder a
stringToTypeDecoder decoder =
    Decode.string
        |> Decode.andThen (doStringToTypeDecoding decoder)


doStringToTypeDecoding : (String -> a) -> String -> Decoder a
doStringToTypeDecoding decoder string =
    Decode.succeed (decoder string)


decodeDayGrade : String -> DayGrade
decodeDayGrade dayGrade =
    case dayGrade of
        "gutter" ->
            Gutter

        "spare" ->
            Spare

        "strike" ->
            Strike

        _ ->
            NoGrade


decodeDayStatus : String -> DayStatus
decodeDayStatus dayStatus =
    case dayStatus of
        "past" ->
            Past

        "present" ->
            Present

        "future" ->
            Future

        _ ->
            NoStatus



-- HTTP


checkIfAuthorized : Cmd Msg
checkIfAuthorized =
    let
        request =
            Http.get "/api/authorization/session" authorizationResponseDecoder
    in
    Http.send SessionResponse request



-- REQUESTS


submitPassword : String -> Cmd Msg
submitPassword password =
    Http.send PasswordResponse (submitPasswordRequest password)


submitPasswordRequest : String -> Http.Request AuthorizationResponse
submitPasswordRequest password =
    let
        encodedPassword =
            encodePassword password
    in
    Http.post
        "/api/authorization/authorize"
        (Http.stringBody "application/json" <| Encode.encode 0 <| encodedPassword)
        authorizationResponseDecoder


postEntry : String -> Cmd Msg
postEntry entry =
    Http.send PersistSuccess (postEntryRequest entry)


postEntryRequest : String -> Http.Request PostEntryResponse
postEntryRequest entry =
    let
        encodedEntry =
            encodeEntry entry
    in
    post
        "/api/entries/save"
        (Http.stringBody "application/json" <| Encode.encode 0 <| encodeEntry entry)
        postEntryResponseDecoder



-- UPDATE


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        Change body ->
            let
                ( debounce, cmd ) =
                    Debounce.push persistDebounceConfig body model.persistDebounce
            in
            ( { model | entry = body, persistDebounce = debounce, action = Typing }
            , cmd
            )

        PasswordChange password ->
            ( { model | entry = password }
            , Cmd.none
            )

        SubmitPassword password ->
            ( { model | passwordMessage = "checking..." }
            , submitPassword password
            )

        PasswordResponse (Ok response) ->
            case response.authorized of
                True ->
                    ( { model
                        | authorization = Authorized
                        , entry = response.entry
                        , breakdown = response.breakdown
                      }
                    , Cmd.none
                    )

                other ->
                    ( { model | passwordMessage = "try again" }
                    , Cmd.none
                    )

        PasswordResponse (Err response) ->
            let
                _ =
                    Debug.log "PasswwordResponse Err" response
            in
            ( model
            , Cmd.none
            )

        SessionResponse (Ok response) ->
            case response.authorized of
                True ->
                    ( { model
                        | authorization = Authorized
                        , entry = response.entry
                        , breakdown = response.breakdown
                      }
                    , Cmd.none
                    )

                False ->
                    ( { model | authorization = NotAuthorized }
                    , Cmd.none
                    )

        SessionResponse (Err response) ->
            let
                _ =
                    Debug.log "SessionResponse Err" response
            in
            ( { model | authorization = NotAuthorized }
            , Cmd.none
            )

        PersistSuccess (Ok response) ->
            let
                ( debounce, cmd ) =
                    Debounce.push setIdleDebounceConfig "" model.setIdleDebounce
            in
            ( { model | setIdleDebounce = debounce, breakdown = response.breakdown }
            , cmd
            )

        PersistSuccess (Err response) ->
            let
                _ =
                    Debug.log "PersistSuccess Err" response
            in
            ( model
            , Cmd.none
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
            ( { model | action = Saved }
            , postEntry entry
            )

        SetIdle str ->
            ( { model | action = Idle }
            , Cmd.none
            )



-- VIEW


view : Model -> Html Msg
view { entry, action, authorization, passwordMessage, breakdown } =
    case authorization of
        Authorized ->
            div [ class "container", style [ ( "margin-top", "30px" ), ( "text-align", "center" ) ] ]
                [ div [ class "row" ]
                    [ div [ class "col-xs-12" ]
                        [ div [ class "jumbotron" ]
                            [ h2 [] [ text "Five Hundo" ]
                            , renderBreakdown breakdown
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
            div []
                [ p [] []
                ]

        NotAuthorized ->
            div [ class "container", style [ ( "margin-top", "30px" ), ( "text-align", "center" ) ] ]
                [ div [ class "row" ]
                    [ div [ class "col-xs-12" ]
                        [ div [ class "jumbotron" ]
                            [ h2 [] [ text "Five Hundo" ]
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


renderBreakdown : WeekBreakdown -> Html Msg
renderBreakdown weekBreakdown =
    div [ flexboxContainerStyle ]
        (List.map renderDayBreakdown weekBreakdown)


renderDayBreakdown : DayBreakdown -> Html Msg
renderDayBreakdown dayBreakdown =
    div [ flexboxChildStyle ]
        [ dayBreakdownImage dayBreakdown ]


dayBreakdownImage : DayBreakdown -> Html Msg
dayBreakdownImage dayBreakdown =
    case dayBreakdown.status of
        Future ->
            img [ src "/images/future.png", styleForDayBreakdown dayBreakdown ] []

        _ ->
            img [ src (imageSrcForDayBreakdown dayBreakdown), styleForDayBreakdown dayBreakdown ] []


imageSrcForDayBreakdown : DayBreakdown -> String
imageSrcForDayBreakdown { grade } =
    case grade of
        Gutter ->
            "/images/gutter.png"

        Spare ->
            "/images/spare.png"

        Strike ->
            "/images/strike.png"

        NoGrade ->
            ""


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
    case String.trim string of
        "" ->
            False

        anything ->
            True



-- STYLES


styleForDayBreakdown : DayBreakdown -> Html.Attribute msg
styleForDayBreakdown { status } =
    case status of
        Present ->
            List.concat [ gradeBaseStyle, [ ( "border-style", "solid" ) ] ]
                |> style

        other ->
            style gradeBaseStyle


gradeBaseStyle : List ( String, String )
gradeBaseStyle =
    [ ( "height", "50px" )
    , ( "width", "50px" )
    ]


flexboxContainerStyle : Html.Attribute msg
flexboxContainerStyle =
    style
        [ ( "display", "flex" )
        , ( "flex-direction", "row" )
        , ( "align-items", "center" )
        , ( "justify-content", "center" )
        ]


flexboxChildStyle : Html.Attribute msg
flexboxChildStyle =
    style
        [ ( "flex", "0.07" )
        ]
