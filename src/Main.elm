module Main exposing (..)

import Api
import Browser
import Browser.Navigation
import CDict exposing (CDict)
import Effect
import Html
import Html.Attributes as Html
import Json.Decode as Decode
import Messages
import Page
import RemoteData
import Routes
import Store
import Time
import Types
import Url


type alias Model =
    { page : Page.Page
    , store : Store.Store
    , shared : Types.Shared
    , key : Browser.Navigation.Key
    }


type alias SharedModel =
    { sessionToken : Types.Token
    , language : String
    }


main : Program () Model Messages.Msg
main =
    Browser.application
        { init = init
        , update = update
        , view =
            \_ ->
                { title = "Elm Store Experiment"
                , body = [ Html.div [] [ Html.text "Welcome to the Elm Store Experiment!" ] ]
                }
        , subscriptions = \_ -> Sub.none
        , onUrlChange = Messages.UrlChanged
        , onUrlRequest = Messages.NavigationRequest
        }


initialSharedModel : Types.Shared
initialSharedModel =
    { sessionToken = Nothing
    , language = "en"
    }


init : flags -> Url.Url -> Browser.Navigation.Key -> ( Model, Cmd Messages.Msg )
init _ url key =
    let
        store =
            Store.initialStore

        shared =
            initialSharedModel

        page =
            case Routes.urlToRoute url of
                Just route ->
                    Page.routeToPage route store shared

                Nothing ->
                    Page.NotFound

        initialModel =
            { key = key
            , store = store
            , shared = shared
            , page = page
            }

        initialDataRequests =
            Page.getDataRequestsFromPage store page

        ( updatedStore, effects ) =
            initialDataRequests
                -- We do this operation here and in update, it can probably become a function in Store.elm
                |> List.foldl
                    (\request ( currentStore, currentEffects ) ->
                        Store.processStoreDataRequest currentStore request
                            |> Tuple.mapSecond (List.append currentEffects)
                    )
                    ( store, [] )
    in
    processEffects initialModel effects


processEffects : Model -> List Effect.Effect -> ( Model, Cmd Messages.Msg )
processEffects model effects =
    effects
        |> List.foldl
            (\effect ( m, cmds ) ->
                case effect of
                    Effect.ApiRequest apiRequest ->
                        ( m, Cmd.batch [ Api.processApiRequest apiRequest, cmds ] )

                    Effect.NavigateTo route ->
                        ( m, Browser.Navigation.pushUrl model.key (Routes.routeToUrlString route) |> Cmd.map Messages.UrlChanged )

                    Effect.Cmd cmd ->
                        ( m, Cmd.batch [ cmd, cmds ] )

                    Effect.HandleError errorDetails ->
                        ( m
                        , Cmd.none
                          -- Create a standardized way of displaying errors, e.g., using a notification system
                          -- with detailed error reporting / submitting to a logging service
                        )
            )
            ( model, Cmd.none )


update : Messages.Msg -> Model -> ( Model, Cmd Messages.Msg )
update msg model =
    let
        ( updatedModel, collectedEffects ) =
            case msg of
                Messages.StoreMsg storeMsg ->
                    let
                        ( updatedStore, effects ) =
                            Store.processStoreMessage storeMsg model.store

                        newDataRequests =
                            Page.getDataRequestsFromPage updatedStore model.page
                    in
                    ( { model | store = updatedStore }
                    , effects
                    )

                Messages.PageMsg pageMsg ->
                    case ( model.page, pageMsg ) of
                        ( Page.NotFound, _ ) ->
                            -- Handle Page.NotFound case if needed
                            ( model, [] )

                        ( Page.SessionsPage pageConfig, Messages.SessionsPageMsg sessionsMsg ) ->
                            Page.processPageMessageUsingConfig model.store model.shared pageConfig sessionsMsg
                                |> Tuple.mapFirst (\page -> { model | page = Page.SessionsPage page })

                        ( Page.SessionPage pageConfig, Messages.SessionPageMsg sessionMsg ) ->
                            Page.processPageMessageUsingConfig model.store model.shared pageConfig sessionMsg
                                |> Tuple.mapFirst (\page -> { model | page = Page.SessionPage page })

                        _ ->
                            ( model
                            , [ Effect.HandleError
                                    (Effect.MismatchedPageMessage
                                        { page = Page.pageToString model.page
                                        , message = Messages.pageMessageToString pageMsg
                                        }
                                    )
                              ]
                            )

                Messages.UrlChanged url ->
                    case Routes.urlToRoute url of
                        Just route ->
                            let
                                newPage =
                                    Page.routeToPage route model.store model.shared

                                newDataRequests =
                                    Page.getDataRequestsFromPage model.store newPage

                                ( updatedStore, effects ) =
                                    newDataRequests
                                        |> List.foldl
                                            (\dataRequest ( store, accumulatedEffects ) ->
                                                Store.processStoreDataRequest store dataRequest
                                                    |> Tuple.mapSecond (List.append accumulatedEffects)
                                            )
                                            ( model.store, [] )
                            in
                            ( { model | page = newPage, store = updatedStore }, effects )

                        Nothing ->
                            ( { model | page = Page.NotFound }, [] )

                Messages.NavigationRequest request ->
                    case request of
                        Browser.Internal url ->
                            ( model, [ Browser.Navigation.pushUrl model.key (Url.toString url) |> Effect.Cmd ] )

                        Browser.External href ->
                            ( model, [ Browser.Navigation.load href |> Effect.Cmd ] )
    in
    processEffects model collectedEffects
