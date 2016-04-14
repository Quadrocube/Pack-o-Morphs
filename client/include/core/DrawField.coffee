class window.DrawField
    constructor: (@game, @width, @height, @rowNum, @colNum) ->
        @data = new window.FieldData(@rowNum, @colNum)
        @grid = new window.THexGrid(@width, @height, 35, @rowNum, @colNum)
        @groundGroup = InitGroup @game.add.group()
        @highlightGroup = InitGroup @game.add.group()
        GenerateGrid(@groundGroup, "hexagon", true)
        GenerateGrid(@highlightGroup, "marker", false)

    InitGroup : (group) ->
        group.x = @grid.leftBound
        group.y = @grid.upperBound
        return group

    GenerateGrid : (group, spriteTag, visible) ->
        for i in [0..rowNum-1]
            for j in [0..colNum-1]
                coord = @grid.ColRowToXY(j, i)
                sprite = @game.add.sprite(coord.x, coord.y, spriteTag);
                hexagon.visible = visible;
                hexGroup.add(hexagon);
