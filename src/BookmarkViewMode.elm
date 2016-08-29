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

module BookmarkViewMode exposing (..)

type BookmarkViewMode
    = ListView
    | CardView


toString : BookmarkViewMode -> String
toString mode =
    case mode of
        ListView -> "ListViewMode"
        CardView -> "CardViewMode"

fromString : String -> BookmarkViewMode
fromString mode =
    case mode of
        "ListViewMode" -> ListView
        "CardViewMode" -> CardView
        _              -> ListView


