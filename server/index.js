var express = require('express');
var app = express();
var http = require('http').Server(app);
var io = require('socket.io');

_root = __dirname+"/../client/";

app.get('/', function(req, res){
  res.sendFile('index.html', { root: _root });
});

app.get('/game.js', function(req, res){
  res.sendFile('game.js', { root: _root });
});

app.use('/libs', express.static(_root + '/libs'));
app.use('/include', express.static(_root + '/include'));
app.use('/arts', express.static(_root + '/arts'));

http.listen(3000, function(){
  console.log('listening on *:3000');
});

var listener = io.listen(http);
listener.sockets.on('connection', function(socket){
    console.log('user connected');
    socket.on('client_data', function(data) {
      process.stdout.write(JSON.stringify(data.objects) + "\n");
    });
});

