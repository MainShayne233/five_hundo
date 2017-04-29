module Commands exposing (..)

import Http exposing (post)
import Json.Encode as Encode
import Json.Decode as Decode
import Debounce exposing (Debounce)
import Time exposing (second)
import Task
import Msgs exposing (..)


-- TASKS


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



-- HTTP


fetchEntry : Cmd Msg
fetchEntry =
    let
        request =
            Http.get "/api/entries/today" Decode.string
    in
        Http.send InitialEntry request


checkIfAuthorized : Cmd Msg
checkIfAuthorized =
    let
        request =
            Http.get "/api/authorization/session" Decode.string
    in
        Http.send SessionResponse request



-- REQUESTS


submitPassword : String -> Cmd Msg
submitPassword password =
    Http.send PasswordResponse (submitPasswordRequest password)


submitPasswordRequest : String -> Http.Request String
submitPasswordRequest password =
    let
        encodedPassword =
            encodePassword (password)
    in
        post
            ("/api/authorization/authorize")
            (Http.stringBody "application/json" <| Encode.encode 0 <| encodedPassword)
            (Decode.string)


postEntry : String -> Cmd Msg
postEntry entry =
    Http.send PersistSuccess (postEntryRequest entry)


postEntryRequest : String -> Http.Request String
postEntryRequest entry =
    let
        encodedEntry =
            encodeEntry (entry)
    in
        post
            ("/api/entries/save")
            (Http.stringBody "application/json" <| Encode.encode 0 <| encodeEntry entry)
            (Decode.string)
