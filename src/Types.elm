module Types exposing (..)


type alias Date =
    String


type alias ChallengeId =
    String


type alias SessionId =
    String


type alias TeamId =
    String


type alias TeamMemberId =
    String


type alias Token =
    String


type alias JoinCode =
    String


type alias Shared =
    { sessionToken : Maybe Token
    , language : String
    }


teamIdToString : TeamId -> String
teamIdToString teamId =
    teamId


sessionIdToString : SessionId -> String
sessionIdToString sessionId =
    sessionId


challengeIdToString : ChallengeId -> String
challengeIdToString challengeId =
    challengeId


dateToString : Date -> String
dateToString date =
    date
