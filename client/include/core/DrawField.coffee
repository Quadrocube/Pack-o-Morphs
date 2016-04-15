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
        object = new window.FieldObject(type, true, owner)
        if object.IsCreature()
            @AddToGroup(row, col, @creatureGroup, @data.creatureField, object)
        else
            @AddToGroup(row, col, @obstaclesGroup, @data.obstaclesField, object)

#    Move : (prevPos, newPos, object) ->
#        var units;
#        if (prevPos) {
#            units = this.creatureField[prevPos[0] + ":" + prevPos[1]];
#            ind = units.indexOf(fieldObject);
#            units.splice(ind, 1);
#        }
#        if (newPos) {
#            var ind = newPos[0] + ":" + newPos[1];
#            if (this.creatureField[ind] === undefined) {
#                this.creatureField[ind] = [];
#            }
#            units = this.creatureField[ind];
#            units.push(fieldObject);
#            units.sort((a, b) => {return a.objectType - b.objectType;});

#    OnDragStart : () ->
#        var hex = this.gameWorld.FindHex()
#        if (this.turnState.SelectField(this.hexagonField.GetAt(hex.x, hex.y)) === true) {
#            this.hexagonField.HighlightOff()
#            this.hexagonField.Highlight(this.col, this.row, this.MoveRange())
#        }
#    },
#
#    OnDragStop : function (sprite, pointer) {
#        var hex = this.gameWorld.FindHex()
#        if (!this.gameWorld.IsValidCoordinate(hex.x, hex.y)) { // out of field
#           this.SetNewPosition(this.col, this.row)
#        } else {
#            var target = this.hexagonField.GetAt(hex.x, hex.y)
#            if (target.objectType === HexType.CREATURE &&
#                this.turnState.SelectAction(ActionType.ATTACK) === true &&
#                this.turnState.SelectField(target) === true) {
#                this.SetNewPosition(this.col, this.row)
#            } else if (this.turnState.SelectAction(ActionType.MOVE) === true &&
#                       this.turnState.SelectField(target) === true) {
#                // moved as side-effect
#            } else {
#                this.SetNewPosition(this.col, this.row)
#            }
#            this.turnState.SelectField(this)
#        }
#
#        this.hexagonField.HighlightOff()
#    },