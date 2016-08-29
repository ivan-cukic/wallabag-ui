port module Main exposing (..)

import Html.App as Html

import Messages exposing (..)

import Model exposing (Model)
import Showing exposing (Showing)

import Tasks
import Utils
import View


-- Update


update : Message -> Model -> (Model, Cmd Message)
update message model =
    case message of
        FetchTags ->
            { model | loading = True
                    , loadedTags = []
                    , showing = Showing.Nothing
            } ! [Tasks.fetchTags]

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
                        , showing = Showing.AllTags
                }
            in newModel ! [Model.saveState newModel]

        ShowBookmarksForTag tag ->
            { model | loading = True
                    , showing = Showing.BookmarksForTag tag
                    , bookmarks = []
            } ! [Tasks.showBookmarksForTag tag]

        ShowUntaggedBookmarks ->
            { model | loading = True
                    , showing = Showing.UntaggedBookmarks
                    , bookmarks = []
            } ! [Tasks.showUntaggedBookmarks]

        ShowAllBookmarks ->
            { model | loading = True
                    , showing = Showing.AllBookmarks
                    , bookmarks = []
            } ! [Tasks.showAllBookmarks]

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
                    Showing.AllTags ->             [Utils.emit ShowAllTags]
                    Showing.BookmarksForTag tag -> [Tasks.showBookmarksForTag tag]
                    Showing.UntaggedBookmarks ->   [Tasks.showUntaggedBookmarks]
                    Showing.AllBookmarks ->        [Tasks.showAllBookmarks]
                    _ -> []





-- Main init

main =
    Html.program
        { init   = init
        , view   = View.view
        , update = update
        , subscriptions = subscriptions
        }

init : (Model, Cmd Message)
init = (Model.default, Cmd.batch [Tasks.fetchTags])

subscriptions : Model -> Sub Message
subscriptions model =
    Model.load LoadState



