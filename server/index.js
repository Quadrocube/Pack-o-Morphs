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

function TQueue () {
    this.carry = [];
    this.length = function () {
        return this.carry.length;
    }
    this.push = function (val) {
        this.carry.push(val);
    };
    this.pop = function () {
        return this.carry.splice(0,1)[0];
    };
    this.removeByValue = function (val) {
        var found = undefined;
        for (i in this.carry) {
            if (this.carry[i] === val) {
                found = i;
            }
        }
        if (found !== undefined) {
            this.carry.splice(found, 1);
        }
    };
}

var UserQueue = new TQueue();
var lobbies = {};

function Lobby(socketOne, socketTwo) {
    this.socketOne = socketOne;
    this.socketTwo = socketTwo;

    this._getOpp = function(id) {
      if (id === socketOne.id) {
        return socketTwo;
      } else {
        return socketOne;
      }
    }
    
    this.disconnect = function(id) {
      this._getOpp(id).disconnect();
    }
    
    this.send = function(id, data) {
      this._getOpp(id).emit('new-turn', data);
    }
};

function initSession(playerOneSocket, playerTwoSocket) {
  var lobby = new Lobby(playerOneSocket, playerTwoSocket);
  lobbies[playerOneSocket.id] = lobby;
  lobbies[playerTwoSocket.id] = lobby;
  playerOneSocket.emit('found-opp', {'order': [0, 1]});
  playerTwoSocket.emit('found-opp', {'order': [1, 0]});
};

listener.sockets.on('connection', function(socket){
    console.log('user connected');
    lobbies[socket.id] = undefined;

    socket.on('manual-field-send', function(data) {
      process.stdout.write("uid " + socket.id + ": " + JSON.stringify(data.objects) + "\n");
    });

    socket.on('disconnect', function(){
      if (!lobbies[socket.id]) {
        UserQueue.removeByValue(socket);
      } else {
        lobbies[socket.id].disconnect(socket.id);
        delete lobbies[socket.id];
      }
    });

    socket.on('new-turn', function(data) {
      console.log('new-turn');
      if (!lobbies[socket.id]) {
        console.log("Panic! No lobby for user " + socket.id + ", but he is sending us new-turns!");
      } else {
        lobbies[socket.id].send(socket.id, data);
      }
    });

    if (UserQueue.length() > 0) {
      opp = UserQueue.pop();
      initSession(socket, opp);
    } else {
      UserQueue.push(socket);
    }
});

