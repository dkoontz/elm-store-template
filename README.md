# Elm Store Template

This template provides a structured foundation for building Elm applications using several architectural patterns that promote maintainability, type safety, and clear separation of concerns.

## Philosophy

### The Store Pattern

This template implements a centralized store pattern for managing remote data. The store acts as a single source of truth for all data fetched from external sources, separate from UI state. Key aspects include:

- **Centralized data management**: All remote data lives in one place (`Store.elm`), making it easy to understand what data is available and how it's being used
- **Explicit loading states**: Using the `RemoteData` pattern, every piece of data tracks whether it's not requested, loading, successfully loaded, or failed
- **Request-based data fetching**: Pages declare what data they need through `DataRequest` types, and the store handles fetching and caching

### API Module Ownership

The `Api` module owns all details of HTTP communication. This design choice provides several benefits:

- **Type-safe requests**: Each API request includes its response handler, ensuring type safety through continuation-passing style
- **Centralized HTTP logic**: URL construction, headers, and request configuration live in one place
- **No direct HTTP usage**: Other modules never import `Http` directly, making the API boundary explicit and enforceable through tools like elm-review

### Effect Pattern

The effect pattern transforms side effects into plain data that can be inspected, tested, and manipulated:

- **Effects as data**: Instead of returning commands directly, functions return `Effect` values that describe what should happen
- **Centralized processing**: All effects are processed in one place (`Main.elm`), allowing consistent handling of errors, logging, or effect transformation
- **Testability**: Effects can be easily tested without executing them, and mock effects can be substituted during development
- **Composability**: Effects can be batched, transformed, or conditionally executed based on application state

### Data Separation

The template enforces strict separation between different types of data:

- **Page-specific data**: Form inputs, UI preferences, and temporary state live in individual page models. This data is scoped to a single page and discarded on navigation
- **Shared data**: Information needed across pages (session token, language preference) lives in the shared model. This persists across page transitions
- **Remote data**: Data fetched from external sources lives in the store, with explicit loading states and caching behavior

## Structure

### Core Modules

- `Main.elm`: Application entry point that coordinates routing, effects, and message delegation
- `Store.elm`: Centralized store for remote data with request processing
- `Api.elm`: Type-safe API layer with request definitions and JSON handling
- `Effect.elm`: Effect type and processing logic
- `Page.elm`: Page configuration pattern for consistent page behavior
- `Messages.elm`: Hierarchical message structure
- `Types.elm`: Shared type definitions and domain modeling
- `Routes.elm`: URL parsing and generation
- `CDict.elm`: Custom dictionary for non-string keys

### Page Implementation

Pages follow a consistent pattern using `PageConfig`:

```elm
type alias PageConfig model msg data =
    { requestedData : DataRequest
    , dataUpdated : data -> model -> ( model, Effect msg )
    , update : msg -> model -> ( model, Effect msg )
    , view : model -> Html msg
    , init : data -> ( model, Effect msg )
    }
```

This structure ensures pages:
- Declare their data requirements explicitly
- React to data changes from the store
- Maintain their own local state
- Generate effects rather than commands

## Benefits

The patterns in this template provide:

- **Predictable data flow**: Data moves through well-defined channels with clear ownership
- **Improved testability**: Effects as data and centralized API handling make testing straightforward
- **Better error handling**: Centralized effect processing allows consistent error handling across the application
- **Type safety**: The continuation-passing API pattern and custom types prevent many runtime errors
- **Scalability**: Clear separation of concerns makes it easy to add new pages, API endpoints, and features
- **Development tooling**: The effect pattern enables powerful development tools like time-travel debugging or effect mocking

## Getting Started

The template includes example implementations of sessions and teams to demonstrate the patterns. These can be modified or replaced with your domain-specific needs while maintaining the architectural benefits of the store, API, and effect patterns.