class window.ActionBar
    constructor: (@game, @grid, @borderMargin = 40, @x = 10, @width = 300, @height = 128) ->
        @buttons = []
        @isLock = false
        @buttonWidth = 40
        window.ActionBar.instance = this
        @create()

    create: () ->
        n = 0
        @width = Math.max(@grid.fieldWidth, @buttonWidth * n + @borderMargin )
        @x = (@game.width - @width) / 2

        @graphicsBar = @game.add.graphics(0, 0)
        @graphicsBar.beginFill(0x01579B, 0.5)
        @barRect = @graphicsBar.drawRoundedRect(@x, window.innerHeight - @height, @width, @height)
        @barRect.fixedToCamera = true
        @graphicsBar.endFill()

    lock: () ->
        @isLock = true
        if @graphicsLock?
            @graphicsLock.destroy()
        @graphicsLock = @game.add.graphics(0, 0)
        @graphicsLock.beginFill(0xFFFFFF, 0.5)
        @lockRect = @graphicsLock.drawRoundedRect(@x, window.innerHeight - @height, @width, @height)
        @lockRect.fixedToCamera = true
        @graphicsLock.endFill()

    unlock: () ->
        @isLock = false
        if @graphicsLock?
            console.log("destroy")
            @graphicsLock.destroy()
            @graphicsLock = undefined

window.ActionBar.getInstance = (game, grid) ->
    if window.ActionBar.instance?
        return window.ActionBar.instance
    else
        return new window.ActionBar(game, grid)