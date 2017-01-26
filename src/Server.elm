port module Server exposing (..)

import Api exposing (..)


main : Program Never number Request
main =
    Platform.program
        { init = init
        , update = update
        , subscriptions = subscriptions
        }


init : ( number, Cmd msg )
init =
    ( 0, Cmd.none )


update : Request -> b -> ( b, Cmd msg )
update req model =
    case Debug.log "req:" req of
        EchoReq str ->
            ( model, sendWS (EchoRes ("You sent us: '" ++ str ++ "' ; the reverse is '" ++ (String.reverse str) ++ "'")) )

        Unknown str ->
            ( model, sendWS (Error str) )


subscriptions : a -> Sub Request
subscriptions model =
    receivePort decodeRequest


sendWS : Response -> Cmd msg
sendWS res =
    sendPort (encodeResponse res)


port sendPort : String -> Cmd msg


port receivePort : (String -> msg) -> Sub msg
