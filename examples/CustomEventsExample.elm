module CustomEventsExample exposing (..)

import Html exposing (Html)
import Html.Attributes as A
import Draggable
import Draggable.Events exposing (onClick, onDragBy, onDragEnd, onDragStart)
import Html.Events


type alias Position =
    { x : Float
    , y : Float
    }


type alias Model =
    { xy : Position
    , clicksCount : Int
    , isDragging : Bool
    , isClicked : Bool
    , drag : Draggable.State String
    }


type Msg
    = OnDragBy Draggable.Delta
    | OnDragStart
    | OnDragEnd
    | CountClick
    | SetClicked Bool
    | DragMsg (Draggable.Msg String)


main : Program Never Model Msg
main =
    Html.program
        { init = init
        , update = update
        , subscriptions = subscriptions
        , view = view
        }


init : ( Model, Cmd Msg )
init =
    ( { xy = Position 32 32
      , drag = Draggable.init
      , clicksCount = 0
      , isDragging = False
      , isClicked = False
      }
    , Cmd.none
    )


dragConfig : Draggable.Config String Msg
dragConfig =
    Draggable.customConfig
        [ onDragStart (\_ -> OnDragStart)
        , onDragEnd OnDragEnd
        , onDragBy OnDragBy
        , onClick (\_ -> CountClick)
        , Draggable.Events.onMouseDown (\_ -> SetClicked True)
        ]


update : Msg -> Model -> ( Model, Cmd Msg )
update msg ({ xy } as model) =
    case msg of
        OnDragBy ( dx, dy ) ->
            ( { model | xy = Position (xy.x + dx) (xy.y + dy) }
            , Cmd.none
            )

        OnDragStart ->
            ( { model | isDragging = True }, Cmd.none )

        OnDragEnd ->
            ( { model | isDragging = False }, Cmd.none )

        CountClick ->
            ( { model | clicksCount = model.clicksCount + 1 }, Cmd.none )

        SetClicked flag ->
            ( { model | isClicked = flag }, Cmd.none )

        DragMsg dragMsg ->
            Draggable.update dragConfig dragMsg model


subscriptions : Model -> Sub Msg
subscriptions { drag } =
    Draggable.subscriptions DragMsg drag


view : Model -> Html Msg
view { xy, isDragging, isClicked, clicksCount } =
    let
        translate =
            "translate(" ++ (toString xy.x) ++ "px, " ++ (toString xy.y) ++ "px)"

        status =
            if isDragging then
                "Release me"
            else
                "Drag me"

        color =
            if isClicked then
                "limegreen"
            else
                "lightgray"

        style =
            [ "transform" => translate
            , "padding" => "16px"
            , "background-color" => color
            , "width" => "100px"
            , "text-align" => "center"
            , "cursor" => "move"
            ]
    in
        Html.div
            [ A.style style
            , Draggable.mouseTrigger "" DragMsg
            , Html.Events.onMouseUp (SetClicked False)
            ]
            [ Html.text status
            , Html.br [] []
            , Html.text <| (toString clicksCount) ++ " clicks"
            ]


(=>) : a -> b -> ( a, b )
(=>) =
    (,)
