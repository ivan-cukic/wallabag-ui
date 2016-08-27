module Tags exposing (item, Tag, fetchTagsTask, decodeTags, error)

import Html exposing (..)
import Html.Attributes exposing (..)

import Http

import Json.Decode as Json
import Json.Decode.Pipeline as JsonPipeline exposing (decode, required)


type alias Tag =
    { slug       : String
    , title      : String
    , post_count : Int
    }

error message = Tag "error" message 0

decodeTag : Json.Decoder Tag
decodeTag = decode Tag
            |> JsonPipeline.required "slug" Json.string
            |> JsonPipeline.required "title" Json.string
            |> JsonPipeline.optional "post_count" Json.int 0

decodeTags : Json.Decoder (List Tag)
decodeTags = Json.list decodeTag

fetchTagsTask = Http.get decodeTags "server/tags.php"

tagLevel : Tag -> Int
tagLevel tag = round <| logBase 2 <| toFloat tag.post_count

tagColor : Tag -> String
tagColor tag =
    case tagLevel tag of
        0 -> ""
        1 -> "grey"
        2 -> "blue"
        3 -> "green"
        4 -> "yellow"
        5 -> "orange"
        6 -> "red"
        _ -> "black"

tagFontSize : Tag -> Int
tagFontSize tag =
    case tagLevel tag of
        0 -> 12
        1 -> 14
        2 -> 18
        3 -> 22
        4 -> 26
        5 -> 28
        6 -> 32
        _ -> 34

tagStyle tag =
    let size = tagFontSize tag in
    style
        [ ("font-size", (toString <| size) ++ "pt")
        , ("padding",   (toString <| size // 4) ++ "px 0")
        ]

item : Tag -> Html a
item tag =
    a [ class "item", href tag.slug, tagStyle tag ]
        [ span [ tagStyle tag ] [ text tag.title ]
        , span [ class ("ui label " ++ (tagColor tag)) ] [ text (toString tag.post_count) ]
        ]

