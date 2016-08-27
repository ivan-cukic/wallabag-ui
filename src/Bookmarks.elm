module Bookmarks exposing (item, Bookmark, fetchBookmarksTask, error)

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


bookmarkTagLabel tag =
    a [ class "ui small right ribbon label" ] [ text tag.title ]


item bookmark =
    div [ class "item" ]
        [ div [ class "ui small image" ]
            [ img [ src bookmark.picture ] [] ]
        , div [ class "content" ]
            [ div [ class "meta" ]
                [ span [ class "ui right ribbon label" ] <|
                    [ UI.icon "tags" ] ++
                    (List.map ( \tag -> a [] [ UI.verticalDivider "white", text tag.title ] ) bookmark.tags)
                ]
            , a [ class "header" ]
                [ text bookmark.title ]
            , div [ class "description", style [ ("min-height", "4em !important") ] ]
                [ span [] [ text bookmark.content ] ]
            , div [ class "extra" ]
                [ text bookmark.url ]
            ]
        ]


