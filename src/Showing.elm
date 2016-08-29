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

module Showing exposing (..)

import Tags exposing (Tag)

type Showing
    = Nothing
    | AllTags
    | BookmarksForTag Tag
    | UntaggedBookmarks
    | AllBookmarks


toString : Showing -> String
toString showing =
    case showing of
        Nothing           -> "ShowingNothing"
        AllTags           -> "ShowingAllTags"
        BookmarksForTag _ -> "ShowingBookmarksForTag"
        UntaggedBookmarks -> "ShowingUntaggedBookmarks"
        AllBookmarks      -> "ShowingAllBookmarks"

fromString : String -> Maybe Tag -> Showing
fromString data maybeTag =
    case data of
        "ShowingTags"              -> AllTags
        "ShowingBookmarksForTag"   -> (
                case maybeTag of
                          Just tag -> BookmarksForTag tag
                          _  -> AllTags
                )
        "ShowingUntaggedBookmarks" -> UntaggedBookmarks
        "ShowingAllBookmarks"      -> AllBookmarks
        _                          -> Nothing


