module UI exposing
    ( page
    , header
    , body
    , linkedItem
    , popupMenu
    , icon
    , verticalDivider
    , divider
    )

import Html exposing (..)
import Html.Attributes exposing (..)

import VirtualDom exposing (Node)


script' : String -> Node a
script' s = node "script" [] [ text s ]


initAllDropdowns : Node a
initAllDropdowns = script' <|
        "
            $('.dropdown').dropdown({
                on: 'hover'
            });
        "


logo : String -> String -> Node a
logo title icon =
    span [ class "ui item big teal ribbon label" ]
        [ img [ src icon ] []
        , text title
        ]


icon : String -> Node a
icon id = i [ class <| id ++ " icon" ] []


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
            ( [ logo pageTitle pageIcon ] ++ menus )
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
        , initAllDropdowns ]


verticalDivider color =
    span [
        style
            [ ( "color", color )
            , ( "padding", "0 .5em" )
            ]
        ]
        [ text "|" ]


divider = div [ class "divider" ] []

