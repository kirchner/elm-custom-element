module UiMain exposing (main)

import Browser
import Browser.Events
import Element
    exposing
        ( Element
        , centerX
        , column
        , el
        , fill
        , height
        , map
        , none
        , padding
        , px
        , rgb
        , row
        , spacing
        , text
        , width
        )
import Element.Background as Background
import Element.Input as Input
import Html exposing (Html)
import UiSquare exposing (uiSquare)


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
    Element.layout
        [ width fill
        , height fill
        ]
        (column
            [ width fill
            , height fill
            , padding 16
            , spacing 16
            ]
            [ row
                [ width fill
                , height fill
                , spacing 16
                ]
                [ map never
                    (uiSquare
                        [ width fill
                        , height fill
                        ]
                        { isGreen = isGreen }
                    )
                , map never
                    (uiSquare
                        [ width fill
                        , height fill
                        ]
                        { isGreen = not isGreen }
                    )
                ]
            , Input.button
                [ width fill
                , padding 16
                , Background.color (rgb 0.9 0.9 0.9)
                ]
                { onPress = Just UserSwitched
                , label =
                    el
                        [ centerX ]
                        (text "Switch!")
                }
            ]
        )
