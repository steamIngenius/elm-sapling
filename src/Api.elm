module Api exposing (Request(..), Response(..), send, listen, encodeResponse, decodeRequest)

import Json.Decode as JD exposing (Value)
import Json.Encode as JE
import WebSocket


serverUrl : String
serverUrl =
    "ws://localhost:8080"


type Request
    = EchoReq String
    | Unknown String


type Response
    = EchoRes String
    | Error String



--- JSON ENCODERS AND DECODERS


requestDecoder : JD.Decoder Request
requestDecoder =
    JD.field "ctor" JD.string
        |> JD.andThen
            (\str ->
                case str of
                    "EchoReq" ->
                        JD.map EchoReq (JD.field "_0" JD.string)

                    _ ->
                        JD.fail str
            )


decodeRequest : String -> Request
decodeRequest str =
    JD.decodeString requestDecoder str
        |> Result.withDefault (Unknown str)


encodeRequest : Request -> String
encodeRequest req =
    case req of
        EchoReq str ->
            JE.encode 0 <|
                JE.object
                    [ ( "ctor", JE.string "EchoReq" )
                    , ( "_0", JE.string str )
                    ]

        Unknown str ->
            str


responseDecoder : JD.Decoder Response
responseDecoder =
    JD.field "ctor" JD.string
        |> JD.andThen
            (\str ->
                case str of
                    "Error" ->
                        JD.map Error (JD.field "_0" JD.string)

                    "EchoRes" ->
                        JD.map EchoRes (JD.field "_0" JD.string)

                    _ ->
                        JD.fail str
            )


decodeResponse : String -> Response
decodeResponse str =
    JD.decodeString responseDecoder (Debug.log "received for Decoding:" str)
        |> Result.withDefault (Error str)


encodeResponse : Response -> String
encodeResponse res =
    case res of
        EchoRes str ->
            JE.encode 0 <|
                JE.object
                    [ ( "ctor", JE.string "EchoRes" )
                    , ( "_0", JE.string str )
                    ]

        Error str ->
            str


send : Request -> Cmd msg
send req =
    WebSocket.send serverUrl (encodeRequest req)


listen : (Response -> msg) -> Sub msg
listen tagger =
    WebSocket.listen serverUrl (decodeResponse >> tagger)
