class window.ActionBar
    constructor: (@game, @grid, @borderMargin = 40, @x = 10, @width = 300, @height = 128) ->
        @buttons = []
        @isLock = false
        @buttonWidth = 40

    DisplayObjectActions: (object) ->
        if @graphics?
            @graphics.destroy()
            @graphics = undefined

        if object.IsCreature()
            n = 0
            @width = Math.max(@grid.fieldWidth, @buttonWidth * n + @borderMargin )
            @x = (@game.width - @width) / 2

            @graphics = @game.add.graphics(0, 0)
            @graphics.beginFill(0x01579B, 0.5)
            @rect = @graphics.drawRoundedRect(@x, @game.height - @height, @width, @height)
            @rect.fixedToCamera = true
            @graphics.endFill()
        return