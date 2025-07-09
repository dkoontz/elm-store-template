module Messages exposing (..)

import Api
import Browser
import Types
import Url


type Msg
    = StoreMsg StoreMsg
    | PageMsg PageMsg
    | UrlChanged Url.Url
    | NavigationRequest Browser.UrlRequest


type StoreMsg
    = GotSessions (Result Api.ApiError (List Api.Session))
    | GotSession (Result Api.ApiError Api.Session)
    | SessionUpdated (Result Api.ApiError ())


type PageMsg
    = SessionsPageMsg SessionsPageMsg
    | SessionPageMsg SessionPageMsg


type SessionPageMsg
    = NotesUpdated String
    | TeamAdded Types.TeamId
    | TeamRemoved Types.TeamId
    | StartDateUpdated Types.Date
    | EndDateUpdated Types.Date


type SessionsPageMsg
    = NavigateToSession Types.SessionId
    | DeleteSession Types.SessionId
    | DuplicateSession Types.SessionId


sessionsPageMessageToString : SessionsPageMsg -> String
sessionsPageMessageToString msg =
    case msg of
        NavigateToSession sessionId ->
            "NavigateToSession " ++ Types.sessionIdToString sessionId

        DeleteSession sessionId ->
            "DeleteSession " ++ Types.sessionIdToString sessionId

        DuplicateSession sessionId ->
            "DuplicateSession " ++ Types.sessionIdToString sessionId


sessionPageMessageToString : SessionPageMsg -> String
sessionPageMessageToString msg =
    case msg of
        NotesUpdated notes ->
            "NotesUpdated: " ++ notes

        TeamAdded teamId ->
            "TeamAdded: " ++ Types.teamIdToString teamId

        TeamRemoved teamId ->
            "TeamRemoved: " ++ Types.teamIdToString teamId

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
