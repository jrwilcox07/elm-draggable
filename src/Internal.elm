module Internal exposing (..)

import Draggable.Vector as Vector exposing (Vector)
import Maybe.Extra exposing (maybeToList)
import Mouse exposing (Position)
import String


type State
    = NotDragging
    | DraggingTentative Position
    | Dragging Position


type Msg
    = StartDragging Position
    | DragAt Position
    | StopDragging


type alias Config msg =
    { onDragStart : Maybe msg
    , onDragBy : Vector -> Maybe msg
    , onDragEnd : Maybe msg
    , onClick : Maybe msg
    , onMouseDown : Maybe msg
    , onMouseUp : Maybe msg
    }


defaultConfig : Config msg
defaultConfig =
    { onDragStart = Nothing
    , onDragBy = \_ -> Nothing
    , onDragEnd = Nothing
    , onClick = Nothing
    , onMouseDown = Nothing
    , onMouseUp = Nothing
    }


updateAndEmit : Config msg -> Msg -> State -> ( State, List msg )
updateAndEmit config msg drag =
    case ( drag, msg ) of
        ( NotDragging, StartDragging initialPosition ) ->
            ( DraggingTentative initialPosition, maybeToList config.onMouseDown )

        ( DraggingTentative oldPosition, DragAt newPosition ) ->
            ( Dragging newPosition
            , List.concatMap maybeToList
                [ config.onDragStart
                , config.onDragBy (distanceTo newPosition oldPosition)
                ]
            )

        ( Dragging oldPosition, DragAt newPosition ) ->
            ( Dragging newPosition
            , maybeToList (config.onDragBy (distanceTo newPosition oldPosition))
            )

        ( DraggingTentative _, StopDragging ) ->
            ( NotDragging
            , List.concatMap maybeToList [ config.onClick, config.onMouseUp ]
            )

        ( Dragging _, StopDragging ) ->
            ( NotDragging
            , List.concatMap maybeToList [ config.onDragEnd, config.onMouseUp ]
            )

        _ ->
            ( drag, [] )
                |> logInvalidState drag msg



-- utility


distanceTo : Position -> Position -> Vector
distanceTo end start =
    Vector.sub
        (Vector.fromPosition end)
        (Vector.fromPosition start)


logInvalidState : State -> Msg -> a -> a
logInvalidState drag msg result =
    let
        str =
            String.join ""
                [ "Invalid drag state: "
                , toString drag
                , ": "
                , toString msg
                ]

        _ =
            Debug.log str
    in
        result
