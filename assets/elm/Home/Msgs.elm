module Msgs exposing (..)

import Debounce exposing (Debounce)
import Http exposing (post)


type alias AuthorizationResponse =
    { authorized : Bool
    , breakdown : List String}


type Msg
    = Change String
    | PasswordChange String
    | PasswordResponse (Result Http.Error String)
    | SessionResponse (Result Http.Error AuthorizationResponse)
    | SubmitPassword String
    | PersistSuccess (Result Http.Error String)
    | InitialEntry (Result Http.Error { entry : String, breakdown : List String })
    | PersistDebounce Debounce.Msg
    | SetIdleDebounce Debounce.Msg
    | PersistEntry String
    | SetIdle String
