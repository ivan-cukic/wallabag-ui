module Bookmarks exposing
    ( listItem
    , cardItem
    , Bookmark
    , fetchBookmarksTask
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


fetchBookmarksTask tag =
    Http.get decodeBookmarks <| "server/query.php?tag=" ++ tag


bookmarkTagLabel tag onTagClick =
    -- a [] [ UI.verticalDivider "white", text tag.title ]
    Tags.link tag onTagClick


listItem bookmark onTagClick =
    div [ class "item" ]
        [ div [ class "ui small image" ]
            [ img [ src bookmark.picture ] [] ]
        , div [ class "content" ]
            [ div [ class "meta" ]
                [ span [ class "ui right ribbon label" ] <|
                    [ UI.icon "tags" ] ++
                    (List.map (\tag -> bookmarkTagLabel tag (onTagClick tag)) bookmark.tags)
                ]
            , a [ class "header", href bookmark.url ]
                [ text bookmark.title ]
            , div [ class "description", style [ ("min-height", "4em !important") ] ]
                [ span [] [ text bookmark.content ] ]
            , div [ class "extra" ]
                [ text bookmark.url ]
            ]
        ]


cardItem bookmark onTagClick =
    div [ class "ui card" ]
        [ div [ class "image" ]
            [ img [ src bookmark.picture ] []
            , span [ class "ui right ribbon label" ] <|
                  -- [ UI.icon "tags" ] ++
                  (List.map (\tag -> div [ attribute "style" "white-space: nowrap" ] [ UI.icon "tag", bookmarkTagLabel tag (onTagClick tag) ]) bookmark.tags)
            ]
        , div [ class "content" ]
            [ div [ class "header" ] [ a [ href bookmark.url, target "_blank" ] [ text bookmark.title ] ]
            -- , div [ class "meta" ] [ a [ href bookmark.url, target "_blank" ] [] ]
            -- , div [ class "meta" ]
            --     [ span [ class "ui right ribbon label" ] <|
            --         [ UI.icon "tags" ] ++
            --         (List.map (\tag -> bookmarkTagLabel tag (onTagClick tag)) bookmark.tags)
            --     ]
            , div [ class "description" ] [ text bookmark.content ]
            ]
        , div [ class "extra content", style [ ("text-overflow", "ellipsis"), ("overflow", "hidden") ] ]
            [ text bookmark.url ]
        ]

