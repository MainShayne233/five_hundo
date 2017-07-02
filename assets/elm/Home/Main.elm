module Main exposing (..)

import Html exposing (program, Html)
import View exposing (view)
import Models exposing (init)
import Update exposing (update)
import Debug


-- APP


main =
    program
        { init = init
        , update = update
        , subscriptions = always Sub.none
        , view = view
        }
