port module Container exposing (container, javascript, main)

-- {{{ IMPORTS

import CustomElement exposing (CustomElement, ElementProgram, HtmlDetails)
import Html exposing (Attribute, Html)
import Html.Attributes
import Json.Decode exposing (Decoder)
import Json.Encode exposing (Value)



-- }}}
-- {{{ BOILERPLATE


port containerDataChanged : (Value -> msg) -> Sub msg


{-| Use this in your application.
-}
container : List (Html msg) -> Html msg
container children =
    CustomElement.toHtml customElement () children


{-| Used by generated Javascript.
-}
main : ElementProgram () () ()
main =
    CustomElement.toMain
        { customElement = customElement
        , elmDataChanged = containerDataChanged
        }


{-| Used to generate Javascript.
-}
javascript : String
javascript =
    CustomElement.toJavascript customElement



-- }}}
-- {{{ IMPLEMENTATION


customElement : CustomElement () () () msg
customElement =
    CustomElement.container
        { init = init
        , update = update
        , subscriptions = subscriptions
        , attributes = attributes
        , nameNode = "my-container"
        , nameModule = "Container"
        , namePort = "containerDataChanged"
        , encode = encode
        , decoder = decoder
        }


init : () -> ( (), Cmd () )
init _ =
    ( (), Cmd.none )


update : () -> () -> () -> ( (), Cmd () )
update _ _ model =
    ( model, Cmd.none )


subscriptions : () -> () -> Sub ()
subscriptions _ _ =
    Sub.none


attributes : () -> () -> List (Attribute ())
attributes _ _ =
    [ Html.Attributes.style "display" "inline-block" ]


encode : () -> Value
encode _ =
    Json.Encode.null


decoder : Decoder ()
decoder =
    Json.Decode.succeed ()



-- }}}
