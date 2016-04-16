class window.DrawField
    constructor: (@game, hexWidth, @rowNum, @colNum) ->
        @data = new window.FieldData(@rowNum, @colNum)
        @grid = new window.THexGrid(@game.width, @game.height, hexWidth, @rowNum, @colNum)

        @groundGroup = @DrawGroup(@groundGroup, @data.groundField)
        @highlightGroup = @DrawGroup(@highlightGroup, @data.highlightField)
        @creatureGroup = @DrawGroup(@creatureGroup, @data.creatureField)
        @obstaclesGroup = @DrawGroup(@obstaclesGroup, @data.obstaclesField)

        @Highlight(4, 4, 3)
        @Add(4, 4, "VECTOR", null)
        @Add(10, 10, "VECTOR", null)

        @Move(@data.creatureField, 4, 4, 11, 11)

    ResetGroup: (group) ->
        if group?
            group.destroy()
        group = @game.add.group()
        group.x = @grid.leftBound
        group.y = @grid.upperBound
        return group

    DrawSprite: (x, y, object) ->
        sprite = @game.add.sprite(x, y, object.spriteTag)
        sprite.visible = object.isVisible
        return sprite

    AddToGroup: (row, col, group, field, object) ->
        field[row][col] = object
        coord = @grid.RowColToXY(row, col)
        sprite = @DrawSprite(coord.x, coord.y, object)
        object.sprite = sprite
        group.add(sprite)
        return

    DrawGroup: (group, field) ->
        group = @ResetGroup group
        for i in [0..@rowNum-1]
            for j in [0..@colNum-1]
                if field[i][j]?
                    @AddToGroup(i, j, group, field, field[i][j])
        return group

    Highlight: (row, col, rad) ->
        @HighlightOff()
        highlight = @grid.GetBlocksInRadius(row, col, rad)
        for r in [0..highlight.length - 1]
            for k in [0..highlight[r].length - 1]
                i = highlight[r][k].row
                j = highlight[r][k].col
                @data.highlightField[i][j].ToogleVisibility(true)
        return

    HighlightOff: () ->
        for i in [0..@rowNum-1]
            for j in [0..@colNum-1]
                 @data.highlightField[i][j].ToogleVisibility(false)
        return

    Add: (row, col, type, owner) ->
        object = new window.FieldObject(row, col, type, true)
        if object.IsCreature()
            @AddToGroup(row, col, @creatureGroup, @data.creatureField, object)
            @EnableDrag(object)
        else
            @AddToGroup(row, col, @obstaclesGroup, @data.obstaclesField, object)

    Move : (field, row1, col1, row2, col2) ->
        object = field[row1][col1]
        field[row2][col2] = object
        field[row1][col1] = undefined

        object.row = row2
        object.col = col2

        coord = @grid.RowColToXY(row2, col2)
        object.sprite.x = coord.x
        object.sprite.y = coord.y

    EnableDrag: (object) ->
        object.sprite.inputEnabled = true
        object.sprite.input.enableDrag()
        object.sprite.events.onDragStart.add(@OnDragStart, this)
        object.sprite.events.onDragStop.add(@OnDragStop, this)

    OnDragStart : (sprite, pointer) ->
        x = @game.input.worldX-@grid.leftBound
        y = @game.input.worldY-@grid.upperBound
        rowcol = @grid.XYToRowCol(x, y)
        @HighlightOff()
        @Highlight(rowcol.row, rowcol.col, 3)

    OnDragStop : (sprite, pointer) ->
        begin = @grid.XYToRowCol(sprite.x, sprite.y)
        end = @grid.XYToRowCol(@game.input.worldX, @game.input.worldY)
        if target?
            @Move(@data.creatureField, begin.row, begin.col, end.row, end.col)
        @HighlightOff()