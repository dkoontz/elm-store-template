module Api.Types exposing (..)

import Json.Decode as Decode
import Json.Decode.Pipeline as Pipeline
import Json.Encode as Encode
import Time
import Types


type alias ChallengeId =
    String


type alias SessionId =
    String


type alias TeamId =
    String


type alias TeamMemberId =
    String


teamIdToString : TeamId -> String
teamIdToString teamId =
    teamId


sessionIdToString : SessionId -> String
sessionIdToString sessionId =
    sessionId


challengeIdToString : ChallengeId -> String
challengeIdToString challengeId =
    challengeId


type alias JoinCode =
    String


type alias TeamMember =
    { id : TeamMemberId
    , deviceFingerprint : String
    , joinedAt : Time.Posix
    }


type alias Team =
    { id : TeamId
    , name : String
    , notes : String
    , joinCode : JoinCode
    , members : List TeamMemberId
    }


teamDecoder : Decode.Decoder Team
teamDecoder =
    Decode.succeed Team
        |> Pipeline.required "id" Decode.string
        |> Pipeline.required "name" Decode.string
        |> Pipeline.required "notes" Decode.string
        |> Pipeline.required "joinCode" Decode.string
        |> Pipeline.required "members" (Decode.list Decode.string)


teamEncoder : Team -> Encode.Value
teamEncoder team =
    Encode.object
        [ ( "id", Encode.string team.id )
        , ( "name", Encode.string team.name )
        , ( "notes", Encode.string team.notes )
        , ( "joinCode", Encode.string team.joinCode )
        , ( "members", Encode.list Encode.string team.members )
        ]


type alias Session =
    { id : SessionId
    , startDate : Types.Date
    , endDate : Types.Date
    , notes : String
    , teams : List Team
    }


sessionDecoder : Decode.Decoder Session
sessionDecoder =
    Decode.succeed Session
        |> Pipeline.required "id" Decode.string
        |> Pipeline.required "startDate" Decode.string
        |> Pipeline.required "endDate" Decode.string
        |> Pipeline.required "notes" Decode.string
        |> Pipeline.required "teams" (Decode.list teamDecoder)


sessionEncoder : Session -> Encode.Value
sessionEncoder session =
    Encode.object
        [ ( "id", Encode.string session.id )
        , ( "startDate", Encode.string session.startDate )
        , ( "endDate", Encode.string session.endDate )
        , ( "notes", Encode.string session.notes )
        , ( "teams", Encode.list teamEncoder session.teams )
        ]
