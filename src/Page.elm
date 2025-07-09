module Page exposing (..)

import Api
import Api.Types
import Effect
import Html
import Messages
import Routes
import Store
import Types


type Page
    = NotFound
    | SessionsPage (PageConfig SessionsPageModel Messages.SessionsPageMsg)
    | SessionPage (PageConfig SessionPageModel Messages.SessionPageMsg)


type alias PageConfig model msg =
    { requestedData : Store.Store -> List Store.DataRequest
    , dataUpdated : Store.Store -> model -> ( model, List Effect.Effect )
    , update : Store.Store -> Types.Shared -> msg -> model -> ( model, List Effect.Effect )
    , view : Store.Store -> Types.Shared -> model -> Html.Html msg
    , init : Store.Store -> model
    , model : model
    }


getDataRequestsFromPage : Store.Store -> Page -> List Store.DataRequest
getDataRequestsFromPage store page =
    case page of
        NotFound ->
            []

        SessionsPage pageConfig ->
            pageConfig.requestedData store

        SessionPage pageConfig ->
            pageConfig.requestedData store


processPageMessageUsingConfig : Store.Store -> Types.Shared -> PageConfig pageModel pageMsg -> pageMsg -> ( PageConfig pageModel pageMsg, List Effect.Effect )
processPageMessageUsingConfig store shared pageConfig pageMsg =
    let
        ( updatedPageModel, effects ) =
            pageConfig.update store shared pageMsg pageConfig.model

        updatedPageConfig =
            { pageConfig | model = updatedPageModel }
    in
    ( updatedPageConfig
    , effects
    )


initSessionsPage : Store.Store -> Types.Shared -> Page
initSessionsPage store shared =
    SessionsPage
        { requestedData = \_ -> [ Store.GetSessionsData ]
        , dataUpdated = \_ model -> ( model, [] )
        , update =
            \_ _ msg model ->
                case msg of
                    Messages.NavigateToSession sessionId ->
                        ( model, [ Effect.NavigateTo (Routes.SessionRoute sessionId) ] )

                    Messages.DeleteSession sessionId ->
                        ( model, [] )

                    -- TODO: Implement delete
                    Messages.DuplicateSession sessionId ->
                        ( model, [] )

        -- TODO: Implement duplicate
        , view = \_ _ _ -> Html.div [] [ Html.text "Sessions page" ]
        , init = \_ -> {}
        , model = {}
        }


initSessionPage : Api.Types.SessionId -> Store.Store -> Types.Shared -> Page
initSessionPage sessionId store shared =
    SessionPage
        { requestedData = \_ -> [ Store.GetSessionsData ]
        , dataUpdated = \_ model -> ( model, [] )
        , update =
            \_ _ msg model ->
                case msg of
                    Messages.NotesUpdated notes ->
                        ( { model | notes = notes }, [] )

                    Messages.TeamAdded teamId ->
                        ( model, [] )

                    -- TODO: Implement
                    Messages.TeamRemoved teamId ->
                        ( model, [] )

                    -- TODO: Implement
                    Messages.StartDateUpdated date ->
                        ( { model | startDate = date }, [] )

                    Messages.EndDateUpdated date ->
                        ( { model | endDate = date }, [] )
        , view = \_ _ _ -> Html.div [] [ Html.text ("Api.Session " ++ sessionId) ]
        , init =
            \_ ->
                { id = sessionId
                , startDate = ""
                , endDate = ""
                , teams = []
                , notes = ""
                }
        , model =
            { id = sessionId
            , startDate = ""
            , endDate = ""
            , teams = []
            , notes = ""
            }
        }


routeToPage : Routes.Route -> Store.Store -> Types.Shared -> Page
routeToPage route store shared =
    case route of
        Routes.SessionsRoute ->
            initSessionsPage store shared

        Routes.SessionRoute sessionId ->
            initSessionPage sessionId store shared


pageToString : Page -> String
pageToString page =
    case page of
        NotFound ->
            "NotFound"

        SessionsPage _ ->
            "Sessions"

        SessionPage _ ->
            "Session"


type alias SessionPageModel =
    { id : Api.Types.SessionId
    , startDate : Types.Date
    , endDate : Types.Date
    , teams : List Api.Types.TeamId
    , notes : String
    }


type alias SessionsPageModel =
    {}
