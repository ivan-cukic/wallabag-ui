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

module Bookmarks exposing
    ( listItem
    , cardItem
    , Bookmark
    , fetchBookmarksForTagTask
    , fetchAllBookmarksTask
    , fetchUntaggedBookmarksTask
    , error
    )

import Html exposing (..)
import Html.Attributes exposing (..)

import Http

import Json.Decode as Json
import Json.Decode.Pipeline as JsonPipeline exposing (decode, required)

import Tags
import UI


type alias Bookmark =
    { id      : Int
    , title   : String
    , picture : String
    , content : String
    , url     : String
    , tags    : List Tags.Tag
    }


error message = Bookmark 0 message "" "" "" []


decodeBookmark : Json.Decoder Bookmark
decodeBookmark = decode Bookmark
                 |> JsonPipeline.required "id" Json.int
                 |> JsonPipeline.required "title" Json.string
                 |> JsonPipeline.optional "picture" Json.string "assets/images/blank-bookmark.png"
                 |> JsonPipeline.required "content" Json.string
                 |> JsonPipeline.required "url" Json.string
                 |> JsonPipeline.required "tags" Tags.decodeTags


decodeBookmarks : Json.Decoder (List Bookmark)
decodeBookmarks = Json.list decodeBookmark


fetchBookmarksForTagTask : String -> Platform.Task Http.Error (List Bookmark)
fetchBookmarksForTagTask tag =
    Http.get decodeBookmarks <| "server/query.php?tag=" ++ tag


fetchAllBookmarksTask : Platform.Task Http.Error (List Bookmark)
fetchAllBookmarksTask =
    Http.get decodeBookmarks "server/query.php?all"


fetchUntaggedBookmarksTask : Platform.Task Http.Error (List Bookmark)
fetchUntaggedBookmarksTask =
    Http.get decodeBookmarks "server/query.php?untagged"


bookmarkTagLabel tag onTagClick =
    Tags.link tag onTagClick


listItem bookmark onTagClick =
    UI.listItem
        bookmark.title
        bookmark.picture
        bookmark.content
        bookmark.url
        onTagClick
        (
            [ UI.icon "tags" ] ++
            (List.map
                (\tag -> bookmarkTagLabel tag (onTagClick tag))
                bookmark.tags
            )
        )


cardItem bookmark onTagClick =
    UI.cardItem
        bookmark.title
        bookmark.picture
        bookmark.content
        bookmark.url
        onTagClick
        (
            (List.map (\tag -> div [ attribute "style" "white-space: nowrap" ] [ UI.icon "tag", bookmarkTagLabel tag (onTagClick tag) ]) bookmark.tags)
        )


