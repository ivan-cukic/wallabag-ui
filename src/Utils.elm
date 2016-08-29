module Utils exposing (..)

import Task

emit message = Task.perform identity identity <| Task.succeed message
