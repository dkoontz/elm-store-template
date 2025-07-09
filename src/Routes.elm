module Routes exposing (..)

import Api
import Api.Types
import Types
import Url


type Route
    = SessionsRoute
    | SessionRoute Api.Types.SessionId


routeToUrlString : Route -> String
routeToUrlString route =
    case route of
        SessionsRoute ->
            "/sessions"

        SessionRoute sessionId ->
            "/session/" ++ Api.Types.sessionIdToString sessionId


urlToRoute : Url.Url -> Maybe Route
urlToRoute url =
    case String.split "/" (String.dropLeft 1 url.path) of
        [ "sessions" ] ->
            Just SessionsRoute

        [ "session", sessionId ] ->
            Just (SessionRoute (Api.Types.SessionId sessionId))

        _ ->
            Nothing
