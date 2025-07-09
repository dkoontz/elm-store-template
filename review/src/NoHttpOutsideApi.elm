module NoHttpOutsideApi exposing (rule)

{-| This rule ensures that the Http module can only be imported in Api.elm
or any file in the src/Api directory.

@docs rule

-}

import Elm.Syntax.Import exposing (Import)
import Elm.Syntax.ModuleName exposing (ModuleName)
import Elm.Syntax.Node as Node exposing (Node)
import Review.Rule as Rule exposing (Error, Rule)


{-| Prevents importing the Http module outside of Api.elm or src/Api directory.

    config =
        [ NoHttpOutsideApi.rule
        ]

-}
rule : Rule
rule =
    Rule.newModuleRuleSchemaUsingContextCreator "NoHttpOutsideApi" contextCreator
        |> Rule.withImportVisitor importVisitor
        |> Rule.fromModuleRuleSchema


type alias Context =
    { moduleName : ModuleName
    }


contextCreator : Rule.ContextCreator () Context
contextCreator =
    Rule.initContextCreator
        (\moduleName () -> { moduleName = moduleName })
        |> Rule.withModuleName


importVisitor : Node Import -> Context -> ( List (Error {}), Context )
importVisitor node context =
    let
        importedModuleName : ModuleName
        importedModuleName =
            node
                |> Node.value
                |> .moduleName
                |> Node.value

        isAllowedModule : Bool
        isAllowedModule =
            case context.moduleName of
                [ "Api" ] ->
                    True

                "Api" :: _ ->
                    -- Any module starting with Api. (e.g., Api.Endpoints)
                    True

                _ ->
                    False
    in
    if importedModuleName == [ "Http" ] && not isAllowedModule then
        ( [ Rule.error
                { message = "Do not import Http directly"
                , details =
                    [ "The Http module should only be imported in Api.elm or files in the src/Api directory."
                    , "Use the Api module instead to make HTTP requests."
                    ]
                }
                (Node.range node)
          ]
        , context
        )
    else
        ( [], context )