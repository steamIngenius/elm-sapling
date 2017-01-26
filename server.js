const express = require('express');
const http = require('http');
const url = require('url');
const WebSocket = require('ws');
const elmsrv = require('./elmsrv.js');

const app = express();

app.use(express.static(__dirname + '/dist/public'));

app.get('*', function(req, res){
  res.sendFile(__dirname + '/public/index.html');
});

const server = http.createServer(app);
const wss = new WebSocket.Server({ server });

wss.on('connection', function connection(ws) {
  const location = url.parse(ws.upgradeReq.url, true);
  const elm = elmsrv.Server.worker();

  elm.ports.sendPort.subscribe(function(message){
    console.log('sending: %s', message);
    ws.send(message);
  })
  
  ws.on('message', function incoming(message) {
    console.log('received: %s', message);
    elm.ports.receivePort.send(message);
  });

});

server.listen(8080, function listening() {
  console.log('Listening on %d', server.address().port);
});