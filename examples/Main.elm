module Main exposing (main)

import Browser
import Container exposing (container)
import Html exposing (Html)
import Html.Attributes
import Html.Events
import Square exposing (square)


main : Program () Bool Msg
main =
    Browser.sandbox
        { init = False
        , update = update
        , view = view
        }


type Msg
    = UserSwitched


update : Msg -> Bool -> Bool
update msg isGreen =
    case msg of
        UserSwitched ->
            not isGreen


view : Bool -> Html Msg
view isGreen =
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
            { attributes =
                [ Html.Attributes.style "background-color" "yellow" ]
            , children =
                [ Html.text "Inside custom element container" ]
            }
        ]
