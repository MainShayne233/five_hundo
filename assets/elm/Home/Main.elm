module Main exposing (..)

import Html exposing (program)
import View exposing (view)
import Models exposing (init)
import Update exposing (update)


-- APP


main =
    program
        { init = init
        , update = update
        , subscriptions = always Sub.none
        , view = view
        }
