port module UiSquare exposing (javascript, main, uiSquare)

-- {{{ IMPORTS

import CustomElement exposing (CustomElement, ElementProgram, HtmlDetails)
import Element
    exposing
        ( Attribute
        , Element
        , el
        , fill
        , height
        , html
        , noStaticStyleSheet
        , none
        , rgb
        , width
        )
import Element.Background as Background
import Html exposing (Html)
import Html.Attributes
import Json.Decode exposing (Decoder)
import Json.Encode exposing (Value)



-- }}}
-- {{{ BOILERPLATE


port elmDataChanged : (Value -> msg) -> Sub msg


type alias Data =
    { isGreen : Bool }


{-| Use this in your application.
-}
uiSquare : List (Attribute Never) -> Data -> Element Never
uiSquare attrs data =
    el attrs (html (CustomElement.toHtml customElement data []))


{-| Used by generated Javascript.
-}
main : ElementProgram Data () ()
main =
    CustomElement.toMain
        { customElement = customElement
        , elmDataChanged = elmDataChanged
        }


{-| Used to generate Javascript.
-}
javascript : String
javascript =
    CustomElement.toJavascript customElement



-- }}}
-- {{{ IMPLEMENTATION


customElement : CustomElement Data () () Never
customElement =
    CustomElement.element
        { init = init
        , update = update
        , subscriptions = subscriptions
        , view = view
        , nameNode = "ui-square"
        , nameModule = "UiSquare"
        , namePort = "elmDataChanged"
        , encode = encode
        , decoder = decoder
        }


init : Data -> ( (), Cmd () )
init _ =
    ( (), Cmd.none )


update : Data -> () -> () -> ( (), Cmd () )
update _ _ model =
    ( model, Cmd.none )


subscriptions : Data -> () -> Sub ()
subscriptions _ _ =
    Sub.none


view : Data -> () -> HtmlDetails msg
view { isGreen } _ =
    { attributes =
        [ Html.Attributes.style "display" "contents" ]
    , children =
        [ Element.layoutWith
            { options =
                [ noStaticStyleSheet ]
            }
            [ width fill
            , height fill
            , Background.color
                (if isGreen then
                    rgb 0 1 0

                 else
                    rgb 0 0 1
                )
            ]
            none
        ]
    }


encode : Data -> Value
encode data =
    Json.Encode.object
        [ ( "isGreen", Json.Encode.bool data.isGreen ) ]


decoder : Decoder Data
decoder =
    Json.Decode.map Data (Json.Decode.field "isGreen" Json.Decode.bool)



-- }}}
