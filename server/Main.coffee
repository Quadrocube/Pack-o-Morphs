express = require('express')
app = express()
http = require('http').Server(app)
io = require('socket.io')
_root = __dirname + "/../client/"

app.get('/', (req, res) ->
    res.sendFile('index.html', { root: _root })
)
app.get('/game.js', (req, res) ->
    res.sendFile('game.js', { root: _root })
)
app.use('/libs', express.static(_root + '/libs'))
app.use('/include', express.static(_root + '/include'))
app.use('/arts', express.static(_root + '/arts'))

http.listen(3000, ()->
    console.log('listening on *:3000')
)
listener = io.listen(http)

class Lobby
    constructor: (@socketOne, @socketTwo) ->
        return

    _getOpp: (id) ->
        if id == @socketOne.id
            return @socketTwo
        else
            return @socketOne

    disconnect: (id) ->
        @_getOpp(id).disconnect()

    send: (id, data) ->
        @_getOpp(id).emit('new-turn', data)

waitingSocket = undefined
lobbies = {}

initSession = (socket1, socket2) ->
    lobby = new Lobby(socket1, socket2)
    lobbies[socket1.id] = lobby
    lobbies[socket2.id] = lobby
    socket1.emit('found-opp', {'order': [0, 1]})
    socket2.emit('found-opp', {'order': [1, 0]})
    waitingSocket = undefined
    console.log("Session inited")

listener.sockets.on('connection', (socket) ->
    console.log('user connected')
    if waitingSocket?
        initSession(waitingSocket, socket)
    else
        waitingSocket = socket

    socket.on('disconnect', () ->
        console.log('user disconnected')
        if !lobbies[socket.id]
            waitingSocket = undefined
        else
            lobbies[socket.id].disconnect(socket.id)
            delete lobbies[socket.id]
    )

    socket.on('new-turn', (data) ->
        console.log('new-turn')
        if !lobbies[socket.id]
            console.log("Panic! No lobby for user " + socket.id + ", but he is sending us new-turns!")
        else
            lobbies[socket.id].send(socket.id, data)
    )
)

