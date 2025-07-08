module Api exposing (..)

import Http
import Json.Decode as Decode
import Json.Decode.Pipeline as Pipeline
import Json.Encode as Encode
import Time
import Types


type ApiRequest msgToSendOnCompletion
    = GetSessions (Result Http.Error (List Session) -> msgToSendOnCompletion)
    | GetSession Types.SessionId (Result Http.Error Session -> msgToSendOnCompletion)
    | UpdateSession Types.SessionId Session (Result Http.Error () -> msgToSendOnCompletion)


processApiRequest : ApiRequest msgToSendOnCompletion -> Cmd msgToSendOnCompletion
processApiRequest request =
    case request of
        GetSessions msgHandler ->
            Http.get
                { url = apiRequestToUrlString request
                , expect = Http.expectJson msgHandler (Decode.list sessionDecoder)
                }

        GetSession sessionId msgHandler ->
            Http.get
                { url = apiRequestToUrlString request
                , expect = Http.expectJson msgHandler sessionDecoder
                }

        UpdateSession sessionId session msgHandler ->
            Http.post
                { url = apiRequestToUrlString request
                , body = sessionEncoder session |> Http.jsonBody
                , expect = Http.expectWhatever msgHandler
                }



----- API Data Types -----


type alias TeamMember =
    { id : Types.TeamMemberId
    , deviceFingerprint : String
    , joinedAt : Time.Posix
    }


type alias Team =
    { id : Types.TeamId
    , name : String
    , notes : String
    , joinCode : Types.JoinCode
    , members : List Types.TeamMemberId
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
    { id : Types.SessionId
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



----- Utility Functions -----


apiRequestToUrlString : ApiRequest msg -> String
apiRequestToUrlString request =
    case request of
        GetSessions _ ->
            "/api/sessions"

        GetSession sessionId _ ->
            "/api/session/" ++ sessionId

        UpdateSession sessionId _ _ ->
            "/api/session/" ++ sessionId
