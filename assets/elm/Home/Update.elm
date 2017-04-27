module Update exposing (..)

import Msgs exposing (..)
import Models exposing (..)
import Commands exposing (persistEntry, postEntry, setIdle)
import Debounce exposing (Debounce)
import Time exposing (second)


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
            ( { model | action = Saved }
            , postEntry entry
            )

        SetIdle str ->
            ( { model | action = Idle }
            , Cmd.none
            )
