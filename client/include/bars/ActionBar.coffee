class window.ActionBar
    constructor: (@game, @grid, @borderMargin = 40, @x = 10, @width = 300, @height = 128) ->
        @buttons = []
        @isLock = false
        @buttonWidth = 128
        @callbacks = {}

    Draw: () ->
        @Destroy()
        if @callbacks? && @toRedraw? && @toRedraw
            actions = Object.keys(@callbacks)

            @width = Math.max(@grid.fieldWidth, @buttonWidth * actions.length + @borderMargin )
            @x = (@game.width - @width) / 2
            @y = @game.height - @height

            @graphics = @game.add.graphics(0, 0)
            @graphics.beginFill(0x01579B, 0.5)
            @rect = @graphics.drawRoundedRect(@x, @y, @width, @height, 5)
            @rect.fixedToCamera = true
            @graphics.endFill()

            for action in actions
                x = @x + (@width - @buttonWidth * actions.length)/2 + @buttonWidth * actions.indexOf(action)
                button = @game.add.button(x, @y, "button_"+action, @callbacks[action], this, 0, 1, 1)
                button.fixedToCamera = true
                @buttons.push(button)
        return

    Destroy: () ->
        if @buttons?
            for button in @buttons
                button.destroy()
            @buttons = []
        if @graphics?
            @graphics.destroy()
            @graphics = undefined
        return

    DisplayObjectActions: (object, @callbacks) ->
        @toRedraw = false
        if object.IsCreature()
            @toRedraw = true
            @Draw()
        else
            @toRedraw = false
            @Destroy()
        return