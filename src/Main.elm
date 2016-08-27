module Main exposing (..)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.App as Html

import Http
import Task

import Semantic as UI
import Tags exposing (Tag)


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

type alias Model =
    { currentTag : String
    , tags: List(Tag)
    , loading: Bool
    }

init : (Model, Cmd Message)
init =
    ( Model "" [] False
    , fetchTags
    )

fetchTags =
    Task.perform FetchTagsFail FetchTagsSucceed Tags.fetchTagsTask

-- Update

type Message
    = FetchTags
    | FetchTagsSucceed (List Tag)
    | FetchTagsFail Http.Error

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
                    , tags = [ Tag "Error" ("Error: " ++ (toString error)) 0 ]
            } ! []


-- View

tagsColumn tags =
    UI.linkedItemsList Tags.item tags


tagsMenu model =
    UI.popupMenu "tags_menu" "Tags" "tags" <| tagsColumn model.tags


view model = UI.page projectName projectLogo [tagsMenu model]
    [ div [ style [ ( "height", "10em" ) ] ] [ text "Lorem ipsum" ]
    , div [ class "ui three buttons" ]
        [ button [ class "ui active button" ] [ text "One" ]
        , button [ class "ui button" ] [ text "Two" ]
        , button [ class "ui button" ] [ text "Three" ]
        ]
    ]


-- Subscriptions

subscriptions : Model -> Sub Message
subscriptions model =
    Sub.none
