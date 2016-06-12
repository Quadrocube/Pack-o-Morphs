# Автор: Гусев Илья.
# Описание: Класс панели, отображающей текущее состояние игрока.

class window.PlayerBar extends window.Bar
    constructor: (@game, @width = 200, @margin = 40, @height = 300, @x = 0, @y = 0) ->
        @Draw()
        return

    Draw: () ->
        @Destroy()

        super(@game, @x, @y, @width, @height)

        style = { font: "32px Comfortaa", fill: "#B3E5FC", wordWrap: true, wordWrapWidth: @width - @margin, align: "left"}
        @textHandler = @game.add.text(@x + @margin / 2, @y + @margin / 2, "", style)
        @textHandler.fixedToCamera = true
        if @stats?
            @textHandler.setText(@stats)
        return

    Destroy: () ->
        super()
        if @textHandler?
            @textHandler.destroy()
            @textHandler = undefined
        return

    DisplayPlayerInfo: (turnState) ->
        @stats = ""

        if turnState.IsClientTurn()
            @stats += 'turn: my\n'
        else
            @stats += 'turn: opp\n'

        @stats += 'nut: ' + turnState.clientPlayer.nutrition + '\n'

        @Draw()
        return