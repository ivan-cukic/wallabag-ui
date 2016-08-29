--
-- Copyright (C) 2016 Ivan Cukic
--
-- This program is free software: you can redistribute it and/or modify
-- it under the terms of the GNU Affero General Public License as
-- published by the Free Software Foundation, either version 3 of the
-- License, or (at your option) any later version.
--
-- This program is distributed in the hope that it will be useful,
-- but WITHOUT ANY WARRANTY; without even the implied warranty of
-- MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
-- GNU Affero General Public License for more details.
--
-- You should have received a copy of the GNU Affero General Public License
-- along with this program.  If not, see <http://www.gnu.org/licenses/>.
--

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

