port module Model exposing (..)

import Http

import Json.Encode as JsonEnc
import Json.Decode as JsonDec
import Json.Decode.Pipeline as JsonPipeline exposing (decode, required)

import Bookmarks exposing (Bookmark)
import Tags exposing (Tag)
import Showing exposing (Showing)
import BookmarkViewMode exposing (BookmarkViewMode)

-- Model

type alias Model =
    { showing          : Showing
    , loading          : Bool
    , statusMessage    : String

    , loadedTags       : List Tag
    , bookmarks        : List Bookmark

    , bookmarkViewMode : BookmarkViewMode
    }

messageModel message =
    Model
          Showing.AllTags            -- showing
          False                      -- loading
          message                    -- statusMessage

          []                         -- there are no tags

          []                         -- and no bookmarks
          BookmarkViewMode.ListView  -- and, by default, we want the list view

default = messageModel ""

showingTags : Model -> Bool
showingTags model =
    case model.showing of
        Showing.AllTags -> True
        _ -> False

showingBookmarks : Model -> Bool
showingBookmarks model =
    case model.showing of
        Showing.UntaggedBookmarks -> True
        Showing.AllBookmarks      -> True
        Showing.BookmarksForTag _ -> True
        _ -> False


-- State storage

currentTag : Model -> Maybe Tag
currentTag model =
    case model.showing of
        Showing.BookmarksForTag tag -> Just tag
        _ -> Nothing


port save : String -> Cmd msg
port load : (String -> msg) -> Sub msg


type alias State =
    { showing          : String
    , tagSlug          : String
    , tagTitle         : String
    , bookmarkViewMode : String
    }


serializeState : Model -> String
serializeState model =
    JsonEnc.encode 0 <| JsonEnc.object
        [ ("showing"          , JsonEnc.string <| Showing.toString model.showing)
        , ("tagSlug"          , JsonEnc.string <| Maybe.withDefault "" <| Maybe.map (\tag -> tag.slug)  <| currentTag model)
        , ("tagTitle"         , JsonEnc.string <| Maybe.withDefault "" <| Maybe.map (\tag -> tag.title) <| currentTag model)
        , ("bookmarkViewMode" , JsonEnc.string <| toString model.bookmarkViewMode)
        ]

decodeState : JsonDec.Decoder State
decodeState = decode State
              |> JsonPipeline.required "showing"  JsonDec.string
              |> JsonPipeline.required "tagSlug"  JsonDec.string
              |> JsonPipeline.required "tagTitle" JsonDec.string
              |> JsonPipeline.required "bookmarkViewMode" JsonDec.string

modelFromState : State -> Model
modelFromState state =
    { default | showing =
                    Showing.fromString state.showing (Tags.tag state.tagSlug state.tagTitle)
              , bookmarkViewMode = BookmarkViewMode.fromString state.bookmarkViewMode
    }


deserializeState : String -> Model
deserializeState data =
    if data == ""
        then default
        else case JsonDec.decodeString decodeState data of
            Err err ->
                messageModel <|
                    "Error loading the saved data: " ++ toString err ++ " data = [" ++ data ++ "]"
            Ok state -> modelFromState state


saveState : Model -> Cmd msg
saveState model = save <| serializeState model
