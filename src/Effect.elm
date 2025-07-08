module Effect exposing (..)

import Api
import Messages
import Routes


type Effect
    = ApiRequest (Api.ApiRequest Messages.Msg)
    | NavigateTo Routes.Route
    | Cmd (Cmd Messages.Msg)
    | HandleError ErrorDetails


type ErrorDetails
    = DataLoadFailure { request : String, error : String }
    | MismatchedPageMessage { page : String, message : String }
