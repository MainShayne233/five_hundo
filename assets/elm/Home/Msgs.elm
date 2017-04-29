module Msgs exposing (..)

import Debounce exposing (Debounce)
import Http exposing (post)


type Msg
    = Change String
    | PasswordChange String
    | PasswordResponse (Result Http.Error String)
    | SessionResponse (Result Http.Error String)
    | SubmitPassword String
    | PersistSuccess (Result Http.Error String)
    | InitialEntry (Result Http.Error String)
    | PersistDebounce Debounce.Msg
    | SetIdleDebounce Debounce.Msg
    | PersistEntry String
    | SetIdle String
