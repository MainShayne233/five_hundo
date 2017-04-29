module Models exposing (..)

import Debounce exposing (Debounce)
import Msgs exposing (..)
import Time exposing (second)
import Commands exposing (checkIfAuthorized)


type Action
    = Typing
    | Saved
    | Idle


type Authorization
    = Authorized
    | NotAuthorized


type alias Model =
    { entry : Entry
    , persistDebounce : Debounce String
    , setIdleDebounce : Debounce String
    , action : Action
    , authorization : Authorization
    , passwordMessage : String
    }


type alias Entry =
    String


model : Model
model =
    { entry = ""
    , persistDebounce = Debounce.init
    , setIdleDebounce = Debounce.init
    , action = Idle
    , authorization = NotAuthorized
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
