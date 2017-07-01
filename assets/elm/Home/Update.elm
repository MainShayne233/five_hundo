module Update exposing (..)

import Msgs exposing (..)
import Models exposing (..)
import Commands exposing (..)
import Debounce exposing (Debounce)


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        InitialEntry (Ok { entry, breakdown }) ->
            ( { model | entry = entry, breakdown = breakdown }
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

        PasswordChange password ->
            ( { model | entry = password }
            , Cmd.none
            )

        SubmitPassword password ->
            ( { model | passwordMessage = "checking..." }
            , submitPassword password
            )

        PasswordResponse (Ok response) ->
            case response of
                "authorized" ->
                    ( { model | authorization = Authorized }
                    , fetchEntry
                    )

                other ->
                    ( { model | passwordMessage = "try again" }
                    , Cmd.none
                    )

        PasswordResponse (Err response) ->
            ( { model | entry = response |> toString }
            , Cmd.none
            )

        SessionResponse (Ok response) ->
            case response of
                "authorized" ->
                    ( { model | authorization = Authorized }
                    , fetchEntry
                    )

                other ->
                    ( { model | authorization = NotAuthorized }
                    , Cmd.none
                    )

        SessionResponse (Err response) ->
            ( { model | entry = response |> toString }
            , Cmd.none
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
            ( { model | action = Saved }
            , postEntry entry
            )

        SetIdle str ->
            ( { model | action = Idle }
            , Cmd.none
            )
