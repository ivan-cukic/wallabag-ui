module Showing exposing (..)

import Tags exposing (Tag)

type Showing
    = Nothing
    | AllTags
    | BookmarksForTag Tag
    | UntaggedBookmarks
    | AllBookmarks


toString : Showing -> String
toString showing =
    case showing of
        Nothing           -> "ShowingNothing"
        AllTags           -> "ShowingAllTags"
        BookmarksForTag _ -> "ShowingBookmarksForTag"
        UntaggedBookmarks -> "ShowingUntaggedBookmarks"
        AllBookmarks      -> "ShowingAllBookmarks"

fromString : String -> Maybe Tag -> Showing
fromString data maybeTag =
    case data of
        "ShowingTags"              -> AllTags
        "ShowingBookmarksForTag"   -> (
                case maybeTag of
                          Just tag -> BookmarksForTag tag
                          _  -> AllTags
                )
        "ShowingUntaggedBookmarks" -> UntaggedBookmarks
        "ShowingAllBookmarks"      -> AllBookmarks
        _                          -> Nothing


