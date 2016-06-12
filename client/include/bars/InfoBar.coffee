# Автор: Гусев Илья.
# Описание: Класс панели, отображающей информацию об объектах на поле.

class window.InfoBar extends window.Bar
    constructor: (@game, @width = 200, @margin = 40, @height = 400) ->
        @Draw()
        return

    Draw: () ->
        @Destroy()
        @x = @game.width - @width
        @y = 0

        super(@game, @x, @y, @width, @height)

        style = {font: "32px Comfortaa", fill: "#B3E5FC", wordWrap: true, wordWrapWidth: @width - @margin, align: "left"}
        @textHandler = @game.add.text(@x + @margin / 2, @y + @margin/2, "", style)
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