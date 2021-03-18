port module Square exposing (javascript, main, square)

import CustomElement exposing (CustomElement, ElementProgram)
import Html exposing (Html)
import Html.Attributes
import Json.Decode exposing (Decoder)
import Json.Encode exposing (Value)


port elmDataChanged : (Value -> msg) -> Sub msg


type alias Data =
    { isGreen : Bool }


{-| Use this in your application.
-}
square : Data -> Html msg
square data =
    CustomElement.toHtml customElement data


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



-- IMPLEMENTATION


customElement : CustomElement Data () ()
customElement =
    CustomElement.from
        { init = init
        , update = update
        , subscriptions = subscriptions
        , view = view
        , name = "my-square"
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


view : Data -> () -> Html ()
view { isGreen } _ =
    Html.div
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
        []


encode : Data -> Value
encode data =
    Json.Encode.object
        [ ( "isGreen", Json.Encode.bool data.isGreen ) ]


decoder : Decoder Data
decoder =
    Json.Decode.map Data (Json.Decode.field "isGreen" Json.Decode.bool)
