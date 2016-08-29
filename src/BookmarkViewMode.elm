module BookmarkViewMode exposing (..)

type BookmarkViewMode
    = ListView
    | CardView


toString : BookmarkViewMode -> String
toString mode =
    case mode of
        ListView -> "ListViewMode"
        CardView -> "CardViewMode"

fromString : String -> BookmarkViewMode
fromString mode =
    case mode of
        "ListViewMode" -> ListView
        "CardViewMode" -> CardView
        _              -> ListView


