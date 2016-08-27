module Semantic exposing (..)

import Html exposing (..)
import Html.Attributes exposing (..)


script' s = node "script" [] [ text s ]


initDropdown id buttonId = script' <|
        "
            $('#" ++ id ++ "').dropdown({
                on: 'hover',
                onShow: function() {
                    $('#" ++ buttonId ++ "').addClass('pointing');
                    $('#" ++ buttonId ++ "').addClass('below');
                },
                onHide: function() {
                    $('#" ++ buttonId ++ "').removeClass('pointing');
                    $('#" ++ buttonId ++ "').removeClass('below');
                }
            });
        "

logo title icon =
    a [ class "ui image big label teal left ribbon" ]
        [ img [ src icon ] []
        , text title
        ]

icon id = i [ class <| id ++ " icon" ] []

linkedItemsList items =
    div [ class "ui link list" ] items

linkedItem itemTitle itemIcon itemUrl =
    a [ class "item", href itemUrl ] <|
        if itemIcon == "" then [ text itemTitle ]
                          else [ icon itemIcon, text itemTitle ]

popupMenu menuId menuTitle menuIcon menuType menuContent =
    span [ id menuId, class "ui dropdown item" ]
        [ button [ id (menuId ++ "_button"), class ("ui " ++ menuType ++ " button big label") ]
            [ icon menuIcon
            , text menuTitle
            ]

        , div [ class "menu ui floating popup basic" ]
            [ div [ class "ui segment basic" ]
                [ menuContent ]
            ]
        , initDropdown menuId (menuId ++ "_button")
        ]

header title icon items =
    div [ style [ ("height", "100px") ] ]
        ( [ logo title icon ] ++ items )

page title icon headerItems bodyItems =
    div [ class "ui raised segment container" ]
        ( [ header title icon headerItems ] ++ bodyItems )

