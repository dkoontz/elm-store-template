module Api exposing (..)

import Api.Types
import Http
import Json.Decode as Decode
import Json.Decode.Pipeline as Pipeline
import Json.Encode as Encode
import Time
import Types


type ApiError
    = BadUrl String
    | Timeout
    | NetworkError
    | BadStatus Int
    | BadBody String


type ApiRequest msgToSendOnCompletion
    = GetSessions (Result ApiError (List Api.Types.Session) -> msgToSendOnCompletion)
    | GetSession Api.Types.SessionId (Result ApiError Api.Types.Session -> msgToSendOnCompletion)
    | UpdateSession Api.Types.SessionId Api.Types.Session (Result ApiError () -> msgToSendOnCompletion)


processApiRequest : ApiRequest msgToSendOnCompletion -> Cmd msgToSendOnCompletion
processApiRequest request =
    case request of
        GetSessions msgHandler ->
            Http.get
                { url = apiRequestToUrlString request
                , expect = Http.expectJson (Result.mapError httpErrorToApiError >> msgHandler) (Decode.list Api.Types.sessionDecoder)
                }

        GetSession sessionId msgHandler ->
            Http.get
                { url = apiRequestToUrlString request
                , expect = Http.expectJson (Result.mapError httpErrorToApiError >> msgHandler) Api.Types.sessionDecoder
                }

        UpdateSession sessionId session msgHandler ->
            Http.post
                { url = apiRequestToUrlString request
                , body = Api.Types.sessionEncoder session |> Http.jsonBody
                , expect = Http.expectWhatever (Result.mapError httpErrorToApiError >> msgHandler)
                }



----- Utility Functions -----


apiRequestToUrlString : ApiRequest msg -> String
apiRequestToUrlString request =
    case request of
        GetSessions _ ->
            "/api/sessions"

        GetSession sessionId _ ->
            "/api/session/" ++ Api.Types.sessionIdToString sessionId

        UpdateSession sessionId _ _ ->
            "/api/session/" ++ Api.Types.sessionIdToString sessionId


httpErrorToApiError : Http.Error -> ApiError
httpErrorToApiError httpError =
    case httpError of
        Http.BadUrl url ->
            BadUrl url

        Http.Timeout ->
            Timeout

        Http.NetworkError ->
            NetworkError

        Http.BadStatus status ->
            BadStatus status

        Http.BadBody body ->
            BadBody body
