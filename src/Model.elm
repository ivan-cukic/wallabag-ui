port module Model exposing (..)

import Http

import Json.Encode as JsonEnc
import Json.Decode as JsonDec
import Json.Decode.Pipeline as JsonPipeline exposing (decode, required)

import Bookmarks exposing (Bookmark)
import Tags exposing (Tag)

-- Model

type BookmarkViewMode
    = ListViewMode
    | CardViewMode


type Showing
    = ShowingNothing
    | ShowingTags
    | ShowingBookmarksForTag Tag
    | ShowingUntaggedBookmarks
    | ShowingAllBookmarks

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
          ShowingTags   -- showing
          False         -- loading
          message       -- statusMessage

          []            -- there are no tags

          []            -- and no bookmarks
          ListViewMode  -- and, by default, we want the list view

default = messageModel ""

showingTags : Model -> Bool
showingTags model =
    case model.showing of
        ShowingTags -> True
        _ -> False

showingBookmarks : Model -> Bool
showingBookmarks model =
    case model.showing of
        ShowingUntaggedBookmarks -> True
        ShowingAllBookmarks      -> True
        ShowingBookmarksForTag _ -> True
        _ -> False


-- State storage

bookmarkViewMode'toString : BookmarkViewMode -> String
bookmarkViewMode'toString mode =
    case mode of
        ListViewMode -> "ListViewMode"
        CardViewMode -> "CardViewMode"

bookmarkViewMode'fromString : String -> BookmarkViewMode
bookmarkViewMode'fromString mode =
    case mode of
        "ListViewMode" -> ListViewMode
        "CardViewMode" -> CardViewMode
        _              -> ListViewMode



showing'toString : Showing -> String
showing'toString showing =
    case showing of
        ShowingNothing           -> "ShowingNothing"
        ShowingTags              -> "ShowingTags"
        ShowingBookmarksForTag _ -> "ShowingBookmarksForTag"
        ShowingUntaggedBookmarks -> "ShowingUntaggedBookmarks"
        ShowingAllBookmarks      -> "ShowingAllBookmarks"

showing'fromString : String -> Maybe Tag -> Showing
showing'fromString showing maybeTag =
    case showing of
        "ShowingNothing"           -> ShowingNothing
        "ShowingTags"              -> ShowingTags
        "ShowingBookmarksForTag"   -> (case maybeTag of
                                          Nothing -> ShowingAllBookmarks
                                          Just tag -> ShowingBookmarksForTag tag)
        "ShowingUntaggedBookmarks" -> ShowingUntaggedBookmarks
        "ShowingAllBookmarks"      -> ShowingAllBookmarks
        _                          -> ShowingNothing


currentTag : Model -> Maybe Tag
currentTag model =
    case model.showing of
        ShowingBookmarksForTag tag -> Just tag
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
        [ ("showing"          , JsonEnc.string <| showing'toString model.showing)
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
    { default | showing = showing'fromString state.showing <| Tags.tag state.tagSlug state.tagTitle
              , bookmarkViewMode = bookmarkViewMode'fromString state.bookmarkViewMode
    }


deserializeState : String -> Model
deserializeState data =
    case JsonDec.decodeString decodeState data of
        Err err -> messageModel ("Error loading the saved data: " ++ toString err)
        Ok state -> modelFromState state


saveState : Model -> Cmd msg
saveState model = save <| serializeState model
