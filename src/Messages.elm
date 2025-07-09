module Messages exposing (..)

import Api
import Api.Types
import Browser
import Types
import Url


type Msg
    = StoreMsg StoreMsg
    | PageMsg PageMsg
    | UrlChanged Url.Url
    | NavigationRequest Browser.UrlRequest


type StoreMsg
    = GotSessions (Result Api.ApiError (List Api.Types.Session))
    | GotSession (Result Api.ApiError Api.Types.Session)
    | SessionUpdated (Result Api.ApiError ())


type PageMsg
    = SessionsPageMsg SessionsPageMsg
    | SessionPageMsg SessionPageMsg


type SessionPageMsg
    = NotesUpdated String
    | TeamAdded Api.Types.TeamId
    | TeamRemoved Api.Types.TeamId
    | StartDateUpdated Types.Date
    | EndDateUpdated Types.Date


type SessionsPageMsg
    = NavigateToSession Api.Types.SessionId
    | DeleteSession Api.Types.SessionId
    | DuplicateSession Api.Types.SessionId


sessionsPageMessageToString : SessionsPageMsg -> String
sessionsPageMessageToString msg =
    case msg of
        NavigateToSession sessionId ->
            "NavigateToSession " ++ Api.Types.sessionIdToString sessionId

        DeleteSession sessionId ->
            "DeleteSession " ++ Api.Types.sessionIdToString sessionId

        DuplicateSession sessionId ->
            "DuplicateSession " ++ Api.Types.sessionIdToString sessionId


sessionPageMessageToString : SessionPageMsg -> String
sessionPageMessageToString msg =
    case msg of
        NotesUpdated notes ->
            "NotesUpdated: " ++ notes

        TeamAdded teamId ->
            "TeamAdded: " ++ Api.Types.teamIdToString teamId

        TeamRemoved teamId ->
            "TeamRemoved: " ++ Api.Types.teamIdToString teamId

        StartDateUpdated date ->
            "StartDateUpdated: " ++ Types.dateToString date

        EndDateUpdated date ->
            "EndDateUpdated: " ++ Types.dateToString date


pageMessageToString : PageMsg -> String
pageMessageToString pageMsg =
    case pageMsg of
        SessionsPageMsg msg ->
            "SessionsPageMessage: " ++ sessionsPageMessageToString msg

        SessionPageMsg msg ->
            "SessionPageMessage: " ++ sessionPageMessageToString msg
