module Main exposing (main)

import Browser
import Browser.Events
import Container exposing (container)
import Html exposing (Html)
import Html.Attributes
import Html.Events
import Square exposing (square)


main : Program () Model Msg
main =
    Browser.element
        { init = init
        , update = update
        , subscriptions = subscriptions
        , view = view
        }


type alias Model =
    { isGreen : Bool
    , containerContentVisible : Bool
    }


init : () -> ( Model, Cmd Msg )
init _ =
    ( { isGreen = False
      , containerContentVisible = False
      }
    , Cmd.none
    )


type Msg
    = UserSwitched
    | RenderedFrame


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        UserSwitched ->
            ( { model | isGreen = not model.isGreen }
            , Cmd.none
            )

        RenderedFrame ->
            ( { model | containerContentVisible = True }
            , Cmd.none
            )


subscriptions : Model -> Sub Msg
subscriptions { containerContentVisible } =
    if containerContentVisible then
        Sub.none

    else
        Browser.Events.onAnimationFrame (\_ -> RenderedFrame)


view : Model -> Html Msg
view { isGreen, containerContentVisible } =
    Html.div []
        [ Html.div []
            [ Html.div []
                [ Html.map never (square { isGreen = isGreen })
                , Html.text " "
                , Html.map never (square { isGreen = not isGreen })
                ]
            , Html.button
                [ Html.Events.onClick UserSwitched ]
                [ Html.text "Switch!" ]
            ]
        , container
            (if containerContentVisible then
                [ Html.p
                    [ Html.Attributes.style "background-color" "yellow" ]
                    [ Html.text "Inside custom element container" ]
                ]

             else
                []
            )
        ]
