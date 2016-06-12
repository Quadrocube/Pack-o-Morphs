# Автор: Гусев Илья.
# Описание: Общение клиента с сервером. Все callbacks в game.coffee.

class window.ServerTalk
    constructor: () ->
        @socket = io.connect('http://localhost:3000')
        @initCallback = undefined
        @turnCallback = undefined

        @socket.on('found-opp', (data) => @initCallback(data.order))
        @socket.on('new-turn', (data) => @turnCallback(data))
        @socket.on('disconnect', () =>
            console.log("Sorry, your opponent has disconnected...")
        )

    Send: (type, data) ->
        @socket.emit(type, data)




