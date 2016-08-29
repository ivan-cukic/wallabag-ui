port module Main exposing (..)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Html.App as Html

import Http
import Task

import VirtualDom exposing (Node)

import Json.Encode as JsonEnc
import Json.Decode as JsonDec
import Json.Decode.Pipeline as JsonPipeline exposing (decode, required)

import UI
import Tags exposing (Tag)
import Bookmarks exposing (Bookmark)
import Model
import Utils

main =
    Html.program
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        }


projectName = "Freerange Walrus"
projectLogo = "assets/images/logo.svg"



-- Tasks

init : (Model.Model, Cmd Message)
init = (Model.default, Cmd.batch [ fetchTags ])


fetchTags: Cmd Message
fetchTags =
    Task.perform FetchTagsFail FetchTagsSucceed
        Tags.fetchTagsTask


showBookmarksForTag: Tag -> Cmd Message
showBookmarksForTag tag =
    Task.perform FetchBookmarksFail FetchBookmarksSucceed <|
        Bookmarks.fetchBookmarksForTagTask tag.slug


showUntaggedBookmarks: Cmd Message
showUntaggedBookmarks =
    Task.perform FetchBookmarksFail FetchBookmarksSucceed <|
        Bookmarks.fetchUntaggedBookmarksTask


showAllBookmarks: Cmd Message
showAllBookmarks =
    Task.perform FetchBookmarksFail FetchBookmarksSucceed <|
        Bookmarks.fetchAllBookmarksTask


-- Update

type Message
    = FetchTags
    | FetchTagsSucceed (List Tag)
    | FetchTagsFail Http.Error

    | ShowAllTags

    | ShowBookmarksForTag Tag
    | ShowUntaggedBookmarks
    | ShowAllBookmarks
    | FetchBookmarksSucceed (List Bookmark)
    | FetchBookmarksFail Http.Error

    | SetViewMode Model.BookmarkViewMode


    | SaveState
    | LoadState String


update : Message -> Model.Model -> (Model.Model, Cmd Message)
update message model =
    case message of
        FetchTags ->
            { model | loading = True
                    , loadedTags = []
                    , showing = Model.ShowingNothing
            } ! [fetchTags]

        FetchTagsSucceed newTags ->
            { model | loading = False
                    , loadedTags = newTags
            } ! []

        FetchTagsFail error ->
            { model | loading = False
                    , loadedTags = []
                    , statusMessage = "Failed to fetch tags: " ++ (toString error)
            } ! []

        ShowAllTags ->
            let newModel =
                { model | loading = False
                        , showing = Model.ShowingTags
                }
            in newModel ! [Model.saveState newModel]

        ShowBookmarksForTag tag ->
            { model | loading = True
                    , showing = Model.ShowingBookmarksForTag tag
                    , bookmarks = []
            } ! [showBookmarksForTag tag]

        ShowUntaggedBookmarks ->
            { model | loading = True
                    , showing = Model.ShowingUntaggedBookmarks
                    , bookmarks = []
            } ! [showUntaggedBookmarks]

        ShowAllBookmarks ->
            { model | loading = True
                    , showing = Model.ShowingAllBookmarks
                    , bookmarks = []
            } ! [showAllBookmarks]

        FetchBookmarksSucceed newBookmarks ->
            let newModel =
                { model | loading = False
                        , bookmarks = newBookmarks
                        , statusMessage = if Model.showingBookmarks model && List.length newBookmarks == 0
                                  then "There are no bookmarks that have this tag"
                                  else ""
                }
            in newModel ! [Model.saveState newModel]

        FetchBookmarksFail error ->
            { model | loading = False
                    , bookmarks = []
                    , statusMessage = "Failed to fetch bookmarks for this tag: " ++ (toString error)
            } ! []

        SetViewMode mode ->
            let newModel = { model | bookmarkViewMode = mode }
            in newModel ! [Model.saveState newModel]

        SaveState ->
            model ! [Model.saveState model]

        LoadState data ->
            let newModel = Model.deserializeState data
            in newModel !
                case newModel.showing of
                    Model.ShowingTags ->                [ Utils.emit ShowAllTags ]
                    Model.ShowingBookmarksForTag tag -> [ showBookmarksForTag tag ]
                    Model.ShowingUntaggedBookmarks ->   [ showUntaggedBookmarks ]
                    Model.ShowingAllBookmarks ->        [ showAllBookmarks ]
                    _ -> []


-- View


splitTagsOnPopularity tags =
    List.partition (\ tag -> tag.post_count >= 3) tags


listTags : List Tag -> List (Node Message)
listTags tags =
    let item = \ tag -> Tags.item tag <| ShowBookmarksForTag tag
    in  List.map item tags


menuTags : List Tag -> Node Message
menuTags tags =
    let (first, rest) = splitTagsOnPopularity tags in
    UI.popupMenu "navigation_menuTags" "Tags" "tags" "primary" <|
        listTags first ++
        [ UI.divider
        , UI.item
            [ UI.icon "dropdown"
            , text "Other tags"
            , UI.menu <| listTags rest
            ]
        , UI.divider
        , UI.clickableItem "Show all bookmarks" ShowAllBookmarks
        , UI.clickableItem "Show bookmarks without tags" ShowUntaggedBookmarks
        ]


menuCreate : Node a
menuCreate =
    UI.popupMenu "navigation_menuCreate" "New" "plus" "basic" <|
        [ UI.linkedItem "New bookmark" "bookmark" ""
        , UI.linkedItem "Create a new note" "sticky note" ""
        ]


viewBookmarks : Model.Model -> Node Message
viewBookmarks model =
    let bookmarks = model.bookmarks
        view = \ itemFunction componentClass ->
            UI.component componentClass <|
                List.map (\bookmark -> itemFunction bookmark ShowBookmarksForTag) bookmarks
    in if model.bookmarkViewMode == Model.ListViewMode
       then view Bookmarks.listItem "divided link items"
       else view Bookmarks.cardItem "link cards"


header : Model.Model -> Node Message
header model =
    UI.header projectName projectLogo
        [ menuTags model.loadedTags
        , menuCreate
        , UI.menu' "right inverted"
            [ UI.clickableIcon "list layout"  <| SetViewMode Model.ListViewMode
            , UI.clickableIcon "block layout" <| SetViewMode Model.CardViewMode
            ]
        ]


tagsBreadcrumb model =
    UI.breadcrumb <|
        case model.showing of
            Model.ShowingTags ->
                [ text "Tags" ]

            Model.ShowingBookmarksForTag tag ->
                [ UI.clickableItem "Tags" ShowAllTags
                , text tag.title
                ]

            Model.ShowingUntaggedBookmarks ->
                [ text "Bookmarks which are not tagged" ]

            Model.ShowingAllBookmarks ->
                [ text "All bookmarks" ]

            _ -> []


body : Model.Model -> Node Message
body model =
    UI.body <|
        [ UI.spacer "3em"
        , UI.group <|
            if model.statusMessage == ""
            then []
            else [ UI.segment' "red" [ text model.statusMessage ] ]

        , tagsBreadcrumb model
        , if Model.showingTags model
             then UI.list <| listTags model.loadedTags
             else viewBookmarks model
        ]


view : Model.Model -> Node Message
view model = UI.page (header model) (body model)




-- Subscriptions

subscriptions : Model.Model -> Sub Message
subscriptions model =
    Model.load LoadState



