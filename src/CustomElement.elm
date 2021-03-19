module CustomElement exposing
    ( CustomElement
    , ElementProgram
    , HtmlDetails
    , container
    , element
    , toHtml
    , toJavascript
    , toMain
    )

-- {{{ IMPORTS

import Browser
import Html exposing (Attribute, Html)
import Html.Attributes
import Json.Decode exposing (Decoder)
import Json.Encode exposing (Value)
import String.Extra
import String.Interpolate exposing (interpolate)



-- }}}
-- {{{ CUSTOM ELEMENT


type CustomElement data model elMsg msg
    = CustomElement
        { init : data -> ( model, Cmd elMsg )
        , update : data -> elMsg -> model -> ( model, Cmd elMsg )
        , subscriptions : data -> model -> Sub elMsg
        , view : data -> model -> HtmlDetails elMsg
        , nameNode : String
        , nameModule : String
        , namePort : String
        , encode : data -> Value
        , decoder : Decoder data
        }


type alias HtmlDetails msg =
    { attributes : List (Attribute msg)
    , children : List (Html msg)
    }


element :
    { init : data -> ( model, Cmd msg )
    , update : data -> msg -> model -> ( model, Cmd msg )
    , subscriptions : data -> model -> Sub msg
    , view : data -> model -> HtmlDetails msg
    , nameNode : String
    , nameModule : String
    , namePort : String
    , encode : data -> Value
    , decoder : Decoder data
    }
    -> CustomElement data model msg Never
element config =
    CustomElement
        { init = config.init
        , update = config.update
        , view = config.view
        , subscriptions = config.subscriptions
        , nameNode = config.nameNode
        , nameModule = config.nameModule
        , namePort = config.namePort
        , encode = config.encode
        , decoder = config.decoder
        }


container :
    { init : data -> ( model, Cmd elMsg )
    , update : data -> elMsg -> model -> ( model, Cmd elMsg )
    , subscriptions : data -> model -> Sub elMsg
    , attributes : data -> model -> List (Attribute elMsg)
    , nameNode : String
    , nameModule : String
    , namePort : String
    , encode : data -> Value
    , decoder : Decoder data
    }
    -> CustomElement data model elMsg msg
container config =
    let
        view data model =
            { attributes = config.attributes data model
            , children = []
            }
    in
    CustomElement
        { init = config.init
        , update = config.update
        , view = view
        , subscriptions = config.subscriptions
        , nameNode = config.nameNode
        , nameModule = config.nameModule
        , namePort = config.namePort
        , encode = config.encode
        , decoder = config.decoder
        }



-- }}}
-- {{{ TO HTML


toHtml :
    CustomElement data model elMsg msg
    -> data
    -> List (Html msg)
    -> Html msg
toHtml (CustomElement config) data children =
    Html.node config.nameNode
        [ Html.Attributes.property "elmData" (config.encode data) ]
        children



-- }}}
-- {{{ TO MAIN


type Model data model
    = Running
        { model : model
        , data : data
        }
    | Failed Json.Decode.Error


type Msg msg
    = ElMsg msg
    | ElmDataChanged Value


type alias ElementProgram data model msg =
    Program Value (Model data model) (Msg msg)


toMain :
    { customElement : CustomElement data model elMsg msg
    , elmDataChanged : (Value -> Msg elMsg) -> Sub (Msg elMsg)
    }
    -> ElementProgram data model elMsg
toMain { customElement, elmDataChanged } =
    let
        (CustomElement config) =
            customElement

        init flags =
            case Json.Decode.decodeValue config.decoder flags of
                Err error ->
                    ( Failed error
                    , Cmd.none
                    )

                Ok data ->
                    let
                        ( model, cmd ) =
                            config.init data
                    in
                    ( Running
                        { model = model
                        , data = data
                        }
                    , Cmd.map ElMsg cmd
                    )

        update msg wrapped =
            case wrapped of
                Running { model, data } ->
                    case msg of
                        ElMsg elMsg ->
                            let
                                ( newModel, cmd ) =
                                    config.update data elMsg model
                            in
                            ( Running
                                { model = newModel
                                , data = data
                                }
                            , Cmd.map ElMsg cmd
                            )

                        ElmDataChanged value ->
                            case Json.Decode.decodeValue config.decoder value of
                                Err _ ->
                                    ( wrapped, Cmd.none )

                                Ok newData ->
                                    ( Running
                                        { model = model
                                        , data = newData
                                        }
                                    , Cmd.none
                                    )

                Failed _ ->
                    ( wrapped, Cmd.none )

        subscriptions wrapped =
            case wrapped of
                Running { model, data } ->
                    Sub.batch
                        [ Sub.map ElMsg (config.subscriptions data model)
                        , elmDataChanged ElmDataChanged
                        ]

                Failed _ ->
                    Sub.none

        view wrapped =
            case wrapped of
                Running { model, data } ->
                    let
                        { attributes, children } =
                            config.view data model
                    in
                    Html.node config.nameNode
                        (List.map (Html.Attributes.map ElMsg) attributes)
                        (List.map (Html.map ElMsg) children)

                Failed _ ->
                    Html.text "Could not initialize custom element"
    in
    Browser.element
        { init = init
        , update = update
        , subscriptions = subscriptions
        , view = view
        }



-- }}}
-- {{{ TO JAVASCRIPT


toJavascript : CustomElement data model elMsg msg -> String
toJavascript (CustomElement config) =
    interpolate
        """
customElements.define("{0}", class extends HTMLElement {
    constructor() {
        super();
        this._elmData = null;
        this._app = null;
    }

    adoptedCallback() {
    }

    connectedCallback() {
        window.requestAnimationFrame(function() {
            this._app = Elm.{1}.init({
                node: this,
                flags: this.elmData,
            });
        });
    }

    disconnectedCallback() {
    }

    set elmData(value) {
        this._elmData = value;
        if (this._app) {
            this._app.ports.{2}.send(value);
        }
    }

    get elmData() {
        return this._elmData
    }
});
"""
        [ config.nameNode
        , config.nameModule
        , config.namePort
        ]



-- }}}
