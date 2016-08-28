port module Main exposing (..)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Html.App as Html

import Http
import Task

import VirtualDom exposing (Node)

import UI
import Tags exposing (Tag)
import Bookmarks exposing (Bookmark)

import Json.Encode as JsonEnc
import Json.Decode as JsonDec
import Json.Decode.Pipeline as JsonPipeline exposing (decode, required)

main =
    Html.program
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        }


projectName = "Freerange Walrus"
projectLogo = "assets/images/logo.svg"




-- Model


type Message
    = FetchTags
    | FetchTagsSucceed (List Tag)
    | FetchTagsFail Http.Error

    | FetchBookmarks Tag
    | FetchBookmarksSucceed (List Bookmark)
    | FetchBookmarksFail Http.Error

    | SetViewMode ViewMode

    | SaveState
    | LoadState String

type ViewMode
    = ListView
    | CardView

type alias Model =
    { currentTag  : Tag
    , tags        : List Tag
    , bookmarks   : List Bookmark
    , loading     : Bool
    , viewMode    : ViewMode
    , errorString : String
    }

defaultModel =
    Model
          Tags.none
          []
          []
          True
          ListView
          ""


errorModel error =
    Model
          Tags.none
          []
          []
          True
          ListView
          error



init : (Model, Cmd Message)
init = (defaultModel, Cmd.batch [ fetchTags ] )


fetchTags: Cmd Message
fetchTags =
    Task.perform FetchTagsFail FetchTagsSucceed
        Tags.fetchTagsTask


fetchBookmarks: Tag -> Cmd Message
fetchBookmarks tag =
    Task.perform FetchBookmarksFail FetchBookmarksSucceed
        (Bookmarks.fetchBookmarksTask tag.slug)


-- Storage

port save : String -> Cmd msg
port load : (String -> msg) -> Sub msg

serializeState : Model -> String
serializeState model =
    JsonEnc.encode 0 <| JsonEnc.object
        [ ("tagSlug"  , JsonEnc.string model.currentTag.slug)
        , ("tagTitle" , JsonEnc.string model.currentTag.title)
        , ("viewMode" , JsonEnc.string (toString model.viewMode))
        ]

type alias State =
    { tagSlug     : String
    , tagTitle    : String
    , viewMode    : String
    }

decodeState : JsonDec.Decoder State
decodeState = decode State
              |> JsonPipeline.required "tagSlug"  JsonDec.string
              |> JsonPipeline.required "tagTitle" JsonDec.string
              |> JsonPipeline.required "viewMode" JsonDec.string

modelFromState : State -> Model
modelFromState state =
    Model (Tags.tag state.tagSlug state.tagTitle)
          []
          []
          False
          ( if state.viewMode == "CardView" then CardView else ListView )
          "Loaded"


deserializeState : String -> Model
deserializeState data =
    case JsonDec.decodeString decodeState data of
        Err err -> errorModel (toString err)
        Ok state -> modelFromState state


saveState : Model -> Cmd msg
saveState model = save <| serializeState model

-- Update

update : Message -> Model -> (Model, Cmd Message)
update message model =
    case message of
        FetchTags ->
            { model | loading = True
                    , tags = []
            } ! [fetchTags]

        FetchTagsSucceed newTags ->
            { model | loading = False
                    , tags = newTags
            } ! []

        FetchTagsFail error ->
            { model | loading = False
                    , tags = [ Tags.error (toString error) ]
            } ! []

        FetchBookmarks tag ->
            { model | loading = True
                    , currentTag = tag
                    , bookmarks = []
            } ! [fetchBookmarks tag]

        FetchBookmarksSucceed newBookmarks ->
            { model | loading = False
                    , bookmarks = newBookmarks
            } ! [saveState model]

        FetchBookmarksFail error ->
            { model | loading = False
                    , bookmarks = [ Bookmarks.error (toString error) ]
            } ! []

        SetViewMode mode ->
            let newModel = { model | viewMode = mode }
            in newModel ! [saveState newModel]

        SaveState ->
            model ! [ saveState model ]

        LoadState data ->
            let newModel = deserializeState data
            in newModel ! [fetchBookmarks newModel.currentTag]


-- View

splitTagsOnPopularity tags =
    List.partition (\ tag -> tag.post_count >= 3) tags


listTags tags = List.map (\tag -> Tags.item tag (FetchBookmarks tag)) tags


menuTags : List Tag -> Node Message
menuTags tags =
    let (first, rest) = splitTagsOnPopularity tags
    in
    UI.popupMenu "navigation_menuTags" "Tags" "tags" "primary" <|
        listTags first ++
        [ UI.divider
        , div [ class "ui item" ]
            [ UI.icon "dropdown"
            , text "Other tags"
            , div [ class "ui menu" ] <|
                listTags rest
            ]
        , UI.divider
        , div [ class "ui item" ] [ text "Show all bookmarks" ]
        , div [ class "ui item" ] [ text "Show bookmarks without tags" ]
        ]


menuCreate =
    UI.popupMenu "navigation_menuCreate" "New" "plus" "basic" <|
        [ UI.linkedItem "New bookmark" "bookmark" ""
        , UI.linkedItem "Create a new note" "sticky note" ""
        ]


viewBookmarkList bookmarks =
    div [ class "ui divided items" ] <|
        List.map (\ bmark -> Bookmarks.item bmark FetchBookmarks) bookmarks


viewBookmarkCards bookmarks =
    div [ class "ui link cards" ] <|
        List.map (\ bmark -> Bookmarks.cardItem bmark FetchBookmarks) bookmarks


viewBookmarks model =
    if model.viewMode == ListView then viewBookmarkList model.bookmarks
                                  else viewBookmarkCards model.bookmarks


header model =
    UI.header projectName projectLogo
        [ menuTags model.tags
        , menuCreate
        , div [ class "ui right inverted menu" ]
            [ a [ class "ui item", onClick (SetViewMode ListView) ] [ UI.icon "list layout" ]
            , a [ class "ui item", onClick (SetViewMode CardView) ] [ UI.icon "block layout" ]
            ]
        ]


tagsBreadcrumb model =
    div [ class "ui massive breadcrumb", style [ ("padding", "1em 0") ] ] <|
    if (model.currentTag.slug == "")
        then [ text "Tags:" ]
        else [ a [ onClick (FetchBookmarks Tags.none) ] [ text "Tags" ]
             , UI.icon "divider right chevron"
             , text model.currentTag.title
             ]


body model =
    UI.body <|
        [ div [ style [ ( "height", "10em" ) ] ] []
        , div [] <|
            if (model.errorString == "")
            then
                []
            else
                [ div [ class "ui red segment" ] [ text model.errorString ] ]

        , tagsBreadcrumb model
        , if (model.currentTag.slug == "")
             then div [ class "ui list" ] ( listTags model.tags )
             else viewBookmarks model
        ]


view model = UI.page (header model) (body model)




-- Subscriptions

subscriptions : Model -> Sub Message
subscriptions model =
    load LoadState




