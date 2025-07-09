module Types exposing (..)


type alias Date =
    String


type alias Token =
    String


type alias Shared =
    { sessionToken : Maybe Token
    , language : String
    }


dateToString : Date -> String
dateToString date =
    date
