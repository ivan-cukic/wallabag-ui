module Main exposing (..)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.App as Html

import Http
import Task

import Semantic as UI
import Tags exposing (Tag)
import Bookmarks exposing (Bookmark)


main =
    Html.program
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        }

projectName = "Freerange Walrus"
projectLogo = "assets/images/logo.svg"

-- Model

type alias Model =
    { currentTag : String
    , tags       : List Tag
    , bookmarks  : List Bookmark
    , loading    : Bool
    }

init : (Model, Cmd Message)
init =
    ( Model "" [] [] False
    , Cmd.batch [fetchTags, fetchBookmarks "c"]
    )

fetchTags: Cmd Message
fetchTags =
    Task.perform FetchTagsFail FetchTagsSucceed
        Tags.fetchTagsTask

fetchBookmarks: String -> Cmd Message
fetchBookmarks tag =
    Task.perform FetchBookmarksFail FetchBookmarksSucceed
        (Bookmarks.fetchBookmarksTask tag)


-- Update

type Message
    = FetchTags
    | FetchTagsSucceed (List Tag)
    | FetchTagsFail Http.Error

    | FetchBookmarks String
    | FetchBookmarksSucceed (List Bookmark)
    | FetchBookmarksFail Http.Error

update : Message -> Model -> (Model, Cmd Message)
update message model =
    case message of
        FetchTags ->
            { model | loading = True
                    , tags = []
            } ! [fetchTags]

        FetchTagsSucceed newTags ->
            { model | loading = False
                    , tags = newTags
            } ! []

        FetchTagsFail error ->
            { model | loading = False
                    , tags = [ Tags.error (toString error) ]
            } ! []

        FetchBookmarks tag ->
            { model | loading = True
                    , tags = []
            } ! [fetchBookmarks tag]

        FetchBookmarksSucceed newBookmarks ->
            { model | loading = False
                    , bookmarks = newBookmarks
            } ! []

        FetchBookmarksFail error ->
            { model | loading = False
                    , bookmarks = [ Bookmarks.error (toString error) ]
            } ! []




-- View

menuTags model =
    UI.popupMenu "navigation_menuTags" "Tags" "tags" "primary"
        <| List.map Tags.item model.tags


menuCreate =
    UI.popupMenu "navigation_menuCreate" "New" "plus" "basic" <|
        [ UI.linkedItem "New bookmark" "bookmark" ""
        , UI.linkedItem "Create a new note" "sticky note" ""
        ]


viewBookmarks bookmarks =
    div [ class "ui items" ] <|
        List.map Bookmarks.item bookmarks


header model =
    UI.header projectName projectLogo
        [ menuTags model
        , menuCreate
        ]

body model =
    UI.body <|
        [ div [ style [ ( "height", "10em" ) ] ]
            [ text "Lorem ipsum" ]
        , viewBookmarks model.bookmarks
        , div [ class "ui buttons" ]
            [ button [ class "ui active button" ] [ text "One" ]
            , button [ class "ui button" ] [ text "Two" ]
            , button [ class "ui button" ] [ text "Three" ]
            ]
        ]


view model = UI.page (header model) (body model)


-- Subscriptions

subscriptions : Model -> Sub Message
subscriptions model =
    Sub.none
