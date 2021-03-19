port module Square exposing (javascript, main, square)

-- {{{ IMPORTS

import CustomElement exposing (CustomElement, ElementProgram, HtmlDetails)
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
square : Data -> Html Never
square data =
    CustomElement.toHtml customElement data []


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
        , nameNode = "my-square"
        , nameModule = "Square"
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
        [ Html.Attributes.style "display" "inline-block"
        , Html.Attributes.style "width" "200px"
        , Html.Attributes.style "height" "200px"
        , Html.Attributes.style "background-color"
            (if isGreen then
                "green"

             else
                "blue"
            )
        ]
    , children = []
    }


encode : Data -> Value
encode data =
    Json.Encode.object
        [ ( "isGreen", Json.Encode.bool data.isGreen ) ]


decoder : Decoder Data
decoder =
    Json.Decode.map Data (Json.Decode.field "isGreen" Json.Decode.bool)



-- }}}
