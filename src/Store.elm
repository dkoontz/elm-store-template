module Store exposing (..)

import Api
import CDict exposing (CDict)
import Effect
import Messages
import RemoteData
import Types


type DataRequest
    = GetSessionsData
    | GetSessionData Types.SessionId
    | GetTeamsData
    | GetTeamData Types.TeamId
    | GetChallengesData
    | GetChallengeData Types.ChallengeId


type alias ApiData a =
    RemoteData.RemoteData Api.ApiError a


type alias Store =
    { allSessions : ApiData (List Api.Session)
    , sessionsById : CDict Types.SessionId (ApiData Api.Session)
    , teams : CDict Types.TeamId (ApiData Api.Team)

    -- , challenges : CDict Api.ChallengeId (ApiData Challenge)
    }


initialStore : Store
initialStore =
    { allSessions = RemoteData.NotAsked
    , sessionsById = CDict.empty identity identity
    , teams = CDict.empty identity identity
    }


processStoreMessage : Messages.StoreMsg -> Store -> ( Store, List Effect.Effect )
processStoreMessage storeMsg store =
    let
        formatApiError apiError =
            case apiError of
                Api.BadUrl url ->
                    "Bad URL: " ++ url

                Api.Timeout ->
                    "Request timed out"

                Api.NetworkError ->
                    "Network error occurred"

                Api.BadStatus status ->
                    "Bad status: " ++ String.fromInt status

                Api.BadBody body ->
                    "Bad body: " ++ body
    in
    case storeMsg of
        Messages.GotSessions result ->
            case result of
                Ok sessions ->
                    ( { store
                        | allSessions = RemoteData.Success sessions
                        , sessionsById = List.foldl (\session acc -> CDict.insert session.id (RemoteData.Success session) acc) store.sessionsById sessions
                      }
                    , []
                    )

                Err error ->
                    ( { store | allSessions = RemoteData.Failure error }
                    , [ Effect.HandleError (Effect.DataLoadFailure { request = "GetSessions", error = formatApiError error })
                      ]
                    )

        _ ->
            -- Handle other StoreMsg cases as needed
            ( store, [] )


processStoreDataRequest : Store -> DataRequest -> ( Store, List Effect.Effect )
processStoreDataRequest store dataRequest =
    -- Implement this to create the correct Api.ApiRequest for the DataRequest
    -- Also update the associated value(s) in the store to be RemoteData.Loading
    case dataRequest of
        GetSessionsData ->
            ( { store | allSessions = RemoteData.Loading }
            , [ Effect.ApiRequest (Api.GetSessions (Messages.GotSessions >> Messages.StoreMsg)) ]
            )

        GetSessionData sessionId ->
            let
                updatedStore =
                    { store | sessionsById = CDict.insert sessionId RemoteData.Loading store.sessionsById }
            in
            ( updatedStore
            , [ Effect.ApiRequest (Api.GetSession sessionId (Messages.StoreMsg << Messages.GotSession)) ]
            )

        GetTeamsData ->
            -- Implement fetching teams data
            ( store, [] )

        GetTeamData teamId ->
            -- Implement fetching a specific team data
            ( store, [] )

        GetChallengesData ->
            -- Implement fetching challenges data
            ( store, [] )

        GetChallengeData challengeId ->
            -- Implement fetching a specific challenge data
            ( store, [] )
