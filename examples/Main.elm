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
    }


init : () -> ( Model, Cmd Msg )
init _ =
    ( { isGreen = False
      }
    , Cmd.none
    )


type Msg
    = UserSwitched


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        UserSwitched ->
            ( { model | isGreen = not model.isGreen }
            , Cmd.none
            )


subscriptions : Model -> Sub Msg
subscriptions _ =
    Sub.none


view : Model -> Html Msg
view { isGreen } =
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
            [ Html.p
                [ Html.Attributes.style "background-color" "yellow" ]
                [ Html.text "Inside custom element container" ]
            , Html.ul []
                [ Html.li [] [ Html.text "Item 1" ]
                , Html.li [] [ Html.text "Item 2" ]
                , Html.li [] [ Html.text "Item 3" ]
                ]
            ]
        ]
