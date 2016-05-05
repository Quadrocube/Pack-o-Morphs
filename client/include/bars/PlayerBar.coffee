class window.PlayerBar
    constructor: (@game, @width = 200, @margin = 40, @height = 300, @x = 0, @y = 0) ->
        @Draw()

    Draw: () ->
        @Destroy()

        @graphics = @game.add.graphics(0, 0)
        @graphics.beginFill(0x01579B, 0.5)
        rect = @graphics.drawRoundedRect(@x, @y, @width, @height, 5)
        rect.fixedToCamera = true
        @graphics.endFill()

        style = { font: "20px Comfortaa", fill: "#B3E5FC", wordWrap: true, wordWrapWidth: @width - @margin, align: "left"}
        @textHandler = @game.add.text(@x + @margin / 2, @y + @margin / 2, "", style)
        @textHandler.fixedToCamera = true
        return

    Destroy: () ->
        if @graphics?
            @graphics.destroy()
            @graphics = undefined
        if @textHandler?
            @textHandler.destroy()
            @textHandler = undefined
        return

    DisplayPlayerInfo: (myNutrition, oppNutrition, nMyCreatures, nOpponentCreatures) ->
        stats = '\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\tME\n' +
        stats += "\tNUT: " + myNutrition + '\n\t#CREATURES: ' + nMyCreatures + '\n\n' +
        stats += '\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\tOPP\n' +
        stats += "\tNUT: " + oppNutrition + '\n\t#CREATURES: ' + nOpponentCreatures
        @textHandler.setText(stats)