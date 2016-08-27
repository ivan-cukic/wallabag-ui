module Main exposing (..)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.App as Html

import Http
import Task

import VirtualDom exposing (Node)

import UI
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


type Message
    = FetchTags
    | FetchTagsSucceed (List Tag)
    | FetchTagsFail Http.Error

    | FetchBookmarks Tag
    | FetchBookmarksSucceed (List Bookmark)
    | FetchBookmarksFail Http.Error


type alias Model =
    { currentTag : Tag
    , tags       : List Tag
    , bookmarks  : List Bookmark
    , loading    : Bool
    }


init : (Model, Cmd Message)
init =
    ( Model Tags.none [] [] True
    , Cmd.batch [ fetchTags ]
    )


fetchTags: Cmd Message
fetchTags =
    Task.perform FetchTagsFail FetchTagsSucceed
        Tags.fetchTagsTask


fetchBookmarks: Tag -> Cmd Message
fetchBookmarks tag =
    Task.perform FetchBookmarksFail FetchBookmarksSucceed
        (Bookmarks.fetchBookmarksTask tag.slug)




-- Update

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
                    , currentTag = tag
                    , bookmarks = []
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

splitTagsOnPopularity tags =
    List.partition (\ tag -> tag.post_count >= 3) tags


listTags tags = List.map (\tag -> Tags.item tag (FetchBookmarks tag)) tags


menuTags : List Tag -> Node Message
menuTags tags =
    let (first, rest) = splitTagsOnPopularity tags
    in
    UI.popupMenu "navigation_menuTags" "Tags" "tags" "primary" <|
        listTags first ++
        [ UI.divider
        , div [ class "ui item" ]
            [ UI.icon "dropdown"
            , text "Other tags"
            , div [ class "ui menu" ] <|
                listTags rest
            ]
        , UI.divider
        , div [ class "ui item" ] [ text "Show all bookmarks" ]
        , div [ class "ui item" ] [ text "Show bookmarks without tags" ]
        ]


menuCreate =
    UI.popupMenu "navigation_menuCreate" "New" "plus" "basic" <|
        [ UI.linkedItem "New bookmark" "bookmark" ""
        , UI.linkedItem "Create a new note" "sticky note" ""
        ]


viewBookmarks bookmarks =
    div [ class "ui divided items" ] <|
        List.map (\ bmark -> Bookmarks.item bmark FetchBookmarks) bookmarks


header model =
    UI.header projectName projectLogo
        [ menuTags model.tags
        , menuCreate
        ]


body model =
    UI.body <|
        [ div [ style [ ( "height", "10em" ) ] ] []
        , h1 [] [ text (if (model.currentTag.slug == "") then "Tags:" else model.currentTag.title) ]
        , if (model.currentTag.slug == "")
             then div [ class "ui list" ] ( listTags model.tags )
             else viewBookmarks model.bookmarks
        -- , div [ class "ui buttons" ]
        --     [ button [ class "ui active button" ] [ text "One" ]
        --     , button [ class "ui button" ] [ text "Two" ]
        --     , button [ class "ui button" ] [ text "Three" ]
        --     ]
        ]


view model = UI.page (header model) (body model)




-- Subscriptions

subscriptions : Model -> Sub Message
subscriptions model =
    Sub.none




