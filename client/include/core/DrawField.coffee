class window.DrawField
    constructor: (@game, hexWidth, @rowNum, @colNum) ->
        @data = new window.FieldData(@rowNum, @colNum)
        @grid = new window.THexGrid(@game.width, @game.height, hexWidth, @rowNum, @colNum)

        @groundGroup = @ResetGroup @game.add.group()
        @highlightGroup = @ResetGroup @game.add.group()
        @groundSprites = @GenerateGrid(@groundGroup, "hexagon", true)
        @highlightSprites = @GenerateGrid(@highlightGroup, "marker", false)
        @Highlight(4, 4, 3)

    ResetGroup: (group) ->
        group.destroy()
        group = @game.add.group()
        group.x = @grid.leftBound
        group.y = @grid.upperBound
        return group

    GenerateGrid: (group, spriteTag, visible) ->
        sprites = (new Array(@colNum) for i in [0..@rowNum-1])
        for i in [0..@rowNum-1]
            for j in [0..@colNum-1]
                coord = @grid.ColRowToXY(i, j)
                sprite = @game.add.sprite(coord.x, coord.y, spriteTag)
                sprite.visible = visible
                sprites[i][j] = sprite
                group.add(sprite)
        return sprites

    Highlight: (row, col, rad) ->
        @HighlightOff()
        highlight = @grid.GetBlocksInRadius(row, col, rad)
        for r in [0..highlight.length - 1]
            for k in [0..highlight[r].length - 1]
                i = highlight[r][k].row
                j = highlight[r][k].col
                @highlightSprites[i][j].visible = true
        return

    HighlightOff: () ->
        for i in [0..@rowNum-1]
            for j in [0..@colNum-1]
                 @highlightSprites[i][j].visible = false
        return