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

module View exposing (..)

import Html exposing (text)

import VirtualDom exposing (Node)

import Messages exposing (..)

import Tags exposing (Tag)
import Bookmarks exposing (Bookmark)
import Model exposing (Model)
import Showing exposing (Showing)
import BookmarkViewMode exposing (BookmarkViewMode)

import About
import UI

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


viewBookmarks : Model -> Node Message
viewBookmarks model =
    let bookmarks = model.bookmarks
        view = \ itemFunction componentClass ->
            UI.component componentClass <|
                List.map (\bookmark -> itemFunction bookmark ShowBookmarksForTag) bookmarks
    in if model.bookmarkViewMode == BookmarkViewMode.ListView
       then view Bookmarks.listItem "divided link items"
       else view Bookmarks.cardItem "link cards"


header : Model -> Node Message
header model =
    UI.header About.name About.logo
        [ menuTags model.loadedTags
        , menuCreate
        , UI.menu' "right inverted"
            [ UI.clickableIcon "list layout"  <| SetViewMode BookmarkViewMode.ListView
            , UI.clickableIcon "block layout" <| SetViewMode BookmarkViewMode.CardView
            ]
        ]


tagsBreadcrumb model =
    UI.breadcrumb <|
        case model.showing of
            Showing.AllTags ->
                [ text "Tags" ]

            Showing.BookmarksForTag tag ->
                [ UI.clickableItem "Tags" ShowAllTags
                , text tag.title
                ]

            Showing.UntaggedBookmarks ->
                [ text "Bookmarks which are not tagged" ]

            Showing.AllBookmarks ->
                [ text "All bookmarks" ]

            _ -> []


body : Model -> Node Message
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


view : Model -> Node Message
view model = UI.page (header model) (body model)

