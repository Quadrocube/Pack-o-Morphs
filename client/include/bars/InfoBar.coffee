class window.InfoBar
    constructor: (@game, @width = 200, @margin = 40, @height = 400) ->
        @Draw()
        return

    Draw: () ->
        @Destroy()
        @x = @game.width - @width
        @y = 0

        @graphics = @game.add.graphics(0, 0)
        @graphics.beginFill(0x01579B, 0.5)
        @rect = @graphics.drawRoundedRect(@x, @y, @width, @height, 5)
        @rect.fixedToCamera = true
        @graphics.endFill()

        style = {font: "32px Comfortaa", fill: "#B3E5FC", wordWrap: true, wordWrapWidth: @width - @margin, align: "left"}
        @textHandler = @game.add.text(@x + @margin / 2, @y + @margin/2, "", style)
        @textHandler.fixedToCamera = true
        if @stats?
            @textHandler.setText(@stats)
        return

    Destroy: () ->
        if @graphics?
            @graphics.destroy()
            @graphics = undefined
        if @textHandler?
            @textHandler.destroy()
            @textHandler = undefined
        return

    DisplayObjectInfo: (object) ->
        @stats = ""
        if object.IsCreature()
            creature = object.creature
            @stats = 'type: ' + object.type.toLowerCase() + '\n'
            @stats+= 'att: ' + creature.att + '\n'
            @stats+= 'def: ' + creature.def + '\n'
            @stats+= 'dam: ' + creature.dam + '\n'
            @stats+= 'hpp: ' + creature.hpp + '\n'
            @stats+= 'mov: ' + creature.mov + '\n'
            @stats+= 'nut: ' + creature.nut + '\n'
        else
            @stats = 'type: ' + object.type.toLowerCase() + '\n'
        @Draw()
        return