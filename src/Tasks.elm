module Tasks exposing (..)

import Task

import Tags exposing (Tag)
import Messages exposing (..)
import Bookmarks exposing (Bookmark)


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


