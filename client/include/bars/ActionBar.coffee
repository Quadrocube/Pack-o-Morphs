class window.ActionBar
    constructor: (@game, @grid, @borderMargin = 40, @x = 10, @width = 300, @height = 128) ->
        @buttons = []
        @isLock = false
        @buttonWidth = 40
        @y = @game.height - @height

    DisplayObjectActions: (object, buttonCallbacks) ->
        if @buttons?
            for button in @buttons
                button.destroy()
            @buttons = []

        if @graphics?
            @graphics.destroy()
            @graphics = undefined

        if object.IsCreature()
            actions = Object.keys(buttonCallbacks)
            @width = Math.max(@grid.fieldWidth, @buttonWidth * actions.length + @borderMargin )
            @x = (@game.width - @width) / 2

            @graphics = @game.add.graphics(0, 0)
            @graphics.beginFill(0x01579B, 0.5)
            @rect = @graphics.drawRoundedRect(@x, @y, @width, @height, 5)
            @rect.fixedToCamera = true
            @graphics.endFill()

            for action in actions
                posX = @x + @buttonWidth * actions.indexOf(action)
                posY = @y
                callback = () ->
                    buttonCallbacks[action](object, object)
                button = @game.add.button(posX, posY, "button_"+action, callback, this, 0, 1, 1)
                @buttons.push(button)
                button.fixedToCamera = true
        return