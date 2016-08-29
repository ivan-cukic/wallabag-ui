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

module UI exposing
    ( page
    , header
    , body
    , linkedItem
    , popupMenu
    , icon
    , divider
    , spacer
    , breadcrumb
    , clickableItem
    , clickableIcon
    , component
    , list
    , segment
    , segment'
    , group
    , item
    , menu
    , menu'
    , cardItem
    , listItem
    )

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)

import VirtualDom exposing (Node)


spacer : String -> Node a
spacer height = div [ style [ ( "height", height ) ] ] []


private'simplify function = function ""


component' : String -> String -> List (Node a) -> Node a
component' additional className items = div [ class <| "ui " ++ additional ++ " " ++ className ] items
component = private'simplify component'


menu' : String -> List (Node a) -> Node a
menu' additional items = component' "menu" additional items
menu = private'simplify menu'


segment' : String -> List (Node a) -> Node a
segment' additional items = component' additional "segment" items
segment = private'simplify segment'


list' : String -> List (Node a) -> Node a
list' additional items = component "list" items
list = private'simplify list'


item' : String -> List (Node a) -> Node a
item' additional items = component "item" items
item = private'simplify item'


divider : Node a
divider = component "divider" []


icon : String -> Node a
icon id = i [ class <| id ++ " icon" ] []


breadcrumb : List (Node a) -> Node a
breadcrumb items =
    let breadcrumbDivider = icon "divider right chevron"
    in
    div [ class "ui massive breadcrumb", style [ ("padding", "1em 0") ] ] <|
        (List.intersperse breadcrumbDivider items) ++ [ breadcrumbDivider ]


clickableItem : String -> a -> Node a
clickableItem title function =
    a [ class "ui item", onClick function ]
      [ text title ]


clickableIcon : String -> a -> Node a
clickableIcon iconName function =
    a [ class "ui item", onClick function ]
      [ icon iconName ]


group : List (Node a) -> Node a
group items = div [] items


linkedItem : String -> String -> String -> Node a
linkedItem itemTitle itemIcon itemUrl =
    a [ class "item", href itemUrl ] <|
        if itemIcon == "" then [ text itemTitle ]
                          else [ icon itemIcon, text itemTitle ]


popupMenu : String -> String -> String -> String -> List (Node a) -> Node a
popupMenu menuId menuTitle menuIcon menuType items =
    a [ class "ui dropdown item" ]
        [ icon menuIcon
        , text menuTitle
        , div [ class "menu" ] items
        ]


header : String -> String -> List (Node a) -> Node a
header pageTitle pageIcon menus =
    div [ class "ui computer tablet only row" ]
        [ div [ class "ui large fixed inverted menu navbar page grid" ]
            ( [ private'logo pageTitle pageIcon ] ++ menus )
        ]


body : List (Node a) -> Node a
body items =
    div [ class "ui page grid main" ]
        [ div [ class "row" ]
            [ div [ class "column padding-reset" ] items
            ]
        ]


page : Node a -> Node a -> Node a
page header items =
    div [ class "ui grid" ]
        [ header
        , items
        , spacer "2em"
        , private'initAllDropdowns
        ]


listItem title picture content url onTagClick ribbonItems =
    div [ class "item" ]
        [ div [ class "ui small image" ]
            [ img [ src picture ] [] ]
        , div [ class "content" ]
            [ div [ class "meta" ]
                [ span [ class "ui right ribbon label" ] ribbonItems ]
            , a [ class "header", href url, target "_blank" ]
                [ text title ]
            , div [ class "description", style [ ("min-height", "4em !important") ] ]
                [ span [] [ text content ] ]
            , div [ class "extra" ]
                [ text url ]
            ]
        ]


cardItem title picture content url onTagClick ribbonItems =
    div [ class "ui card" ]
        [ div [ class "image" ]
            [ img [ src picture ] []
            , span [ class "ui right ribbon label" ] ribbonItems
            ]
        , div [ class "content" ]
            [ div [ class "header" ] [ a [ href url, target "_blank" ] [ text title ] ]
            , div [ class "description" ] [ text content ]
            ]
        , div [ class "extra content", style [ ("text-overflow", "ellipsis"), ("overflow", "hidden") ] ]
            [ text url ]
        ]





-- Private

private'script : String -> Node a
private'script s = node "script" [] [ text s ]

private'initAllDropdowns : Node a
private'initAllDropdowns = private'script
    "
        $('.dropdown').dropdown({
            on: 'hover'
        });
    "

private'logo : String -> String -> Node a
private'logo title icon =
    span [ class "ui item big teal ribbon label" ]
        [ img [ src icon ] []
        , text title
        ]

