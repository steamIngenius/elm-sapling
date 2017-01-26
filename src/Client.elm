module Client exposing (..)

import Html exposing (..)
import Html.Events exposing (..)
import Api exposing (Request(..), Response(..))


main : Program Never Model Msg
main =
    Html.program
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        }



-- MODEL


type alias Model =
    { input : String
    , messages : List String
    }


init : ( Model, Cmd Msg )
init =
    ( Model "" [], Cmd.none )



-- UPDATE


type Msg
    = Input String
    | Send
    | NewMessage Response


update : Msg -> Model -> ( Model, Cmd Msg )
update msg ({ input, messages } as model) =
    case msg of
        Input newInput ->
            ( Model newInput messages, Cmd.none )

        Send ->
            ( Model "" messages, Api.send (EchoReq input) )

        NewMessage response ->
            case response of
                Error str ->
                    let
                        log =
                            Debug.log "error received: " str
                    in
                        ( model, Cmd.none )

                EchoRes str ->
                    ( Model input (str :: messages), Cmd.none )



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions model =
    Api.listen NewMessage



-- VIEW


view : Model -> Html Msg
view model =
    div []
        [ div [] (List.map viewMessage model.messages)
        , input [ onInput Input ] []
        , button [ onClick Send ] [ text "Send" ]
        ]


viewMessage : String -> Html msg
viewMessage msg =
    div [] [ text msg ]
