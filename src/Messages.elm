module Messages exposing (..)

import Http

import Tags exposing (Tag)
import Bookmarks exposing (Bookmark)
import BookmarkViewMode exposing (BookmarkViewMode)

import Model

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

    | SetViewMode BookmarkViewMode


    | SaveState
    | LoadState String

