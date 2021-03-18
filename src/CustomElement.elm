module CustomElement exposing
    ( CustomElement
    , ElementProgram
    , from
    , toHtml
    , toJavascript
    , toMain
    )

import Browser
import Html exposing (Html)
import Html.Attributes
import Json.Decode exposing (Decoder)
import Json.Encode exposing (Value)
import String.Extra
import String.Interpolate exposing (interpolate)


type CustomElement data model msg
    = CustomElement
        { init : data -> ( model, Cmd msg )
        , update : data -> msg -> model -> ( model, Cmd msg )
        , subscriptions : data -> model -> Sub msg
        , view : data -> model -> Html msg
        , name : String
        , encode : data -> Value
        , decoder : Decoder data
        }


from :
    { init : data -> ( model, Cmd msg )
    , update : data -> msg -> model -> ( model, Cmd msg )
    , view : data -> model -> Html msg
    , subscriptions : data -> model -> Sub msg
    , name : String
    , encode : data -> Value
    , decoder : Decoder data
    }
    -> CustomElement data model msg
from config =
    CustomElement
        config



-- USED IN APP


toHtml : CustomElement data model elMsg -> data -> Html msg
toHtml (CustomElement config) data =
    Html.node config.name
        [ Html.Attributes.property "elmData" (config.encode data) ]
        []



-- USED IN COMPONENT


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
    { customElement : CustomElement data model msg
    , elmDataChanged : (Value -> Msg msg) -> Sub (Msg msg)
    }
    -> ElementProgram data model msg
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
                    Html.map ElMsg (config.view data model)

                Failed _ ->
                    Html.text "Could not initialize custom element"
    in
    Browser.element
        { init = init
        , update = update
        , subscriptions = subscriptions
        , view = view
        }



-- BOILERPLATE


toJavascript : CustomElement data model msg -> String
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
        this.style.display = "contains";

        this._container = document.createElement("div");
        this.attachChild(this._container);

        this._app = Elm.{1}.init({
            node: this._container,
            flags: this.elmData,
        });
    }

    disconnectedCallback() {
    }

    set elmData(value) {
        this._elmData = value;
        if (!this._app) return;
        this._app.ports.elmDataChanged.send(value);
    }

    get elmData() {
        return this._meta
    }
});
"""
        [ config.name
        , config.name
            |> String.Extra.camelize
            |> String.Extra.toTitleCase
        ]
