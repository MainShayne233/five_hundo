module Models exposing (..)

import Action exposing (..)
import Debounce exposing (Debounce)
import Msgs exposing (..)
import Time exposing (second)
import Commands exposing (fetchEntry)


type alias Model =
    { entry : Entry
    , persistDebounce : Debounce String
    , setIdleDebounce : Debounce String
    , action : Action
    }


type alias Entry =
    String


model : Model
model =
    { entry = ""
    , persistDebounce = Debounce.init
    , setIdleDebounce = Debounce.init
    , action = Idle
    }


init =
    ( model
    , fetchEntry
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
