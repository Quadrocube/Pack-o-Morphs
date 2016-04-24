# Автор: Гусев Илья.
# Описание: Класс, отрисовывающий 4-слойное гексогональное поле. Первый слой - поверхность (ground).
# Второй слой - подсветка (highlight). Третий слой - препятствия (obstacles). Четвёртый слой - существа (creatures).

class window.DrawField
    constructor: (@game, hexWidth, @rowNum, @colNum) ->
        @data = new window.FieldData(@rowNum, @colNum)
        @grid = new window.THexGrid(hexWidth, @rowNum, @colNum)
        @logic = new window.Logic(@grid, @data, @)
        @leftBound = (@game.width - @grid.fieldWidth) / 2
        @upperBound = (@game.height - @grid.fieldHeight) / 2 - 100

        @actionBar = window.ActionBar.instance = new window.ActionBar(@game, @grid)
        @infoBar = window.InfoBar.instance = new window.InfoBar(@game)
        @playerBar = window.PlayerBar.instance = new window.PlayerBar(@game)

        @groundGroup = @drawGroup(@groundGroup, @data.groundField)
        @highlightGroup = @drawGroup(@highlightGroup, @data.highlightField)
        @obstaclesGroup = @drawGroup(@obstaclesGroup, @data.obstaclesField)
        @creatureGroup = @drawGroup(@creatureGroup, @data.creatureField)

        @game.input.mouse.mouseDownCallback = () =>
            rowcol = @grid.XYToRowCol(@getGridX(@game.input.worldX), @getGridY(@game.input.worldY))
            row = rowcol.row
            col = rowcol.col
            if @grid.IsValidRowCol(row, col)
                object = @GetUpperObject(row, col)
                @actionBar.DisplayObjectActions(object)
                @infoBar.DisplayObjectInfo(object)

        # Пример
        @Add(4, 4, "VECTOR")
        @Add(10, 10, "VECTOR")
        @Move(@data.creatureField, 4, 4, 11, 11)

    # Интерфейс.
    # ---------------------------------------------------------------------------------------------------------------
    # Добавление объекта fieldObject в его клетку
    Add: (fieldObject) ->
        if not @grid.IsValidRowCol(fieldObject.row, fieldObject.col)
            throw "Wrong RowCol in DrawField Add(fieldObject) method"
        if object.IsCreature()
            @addToGroup(fieldObject.row, fieldObject.col, @creatureGroup, @data.creatureField, fieldObject)
            @ToogleDrag(fieldObject.sprite, true)
        else
            @addToGroup(fieldObject.row, fieldObject.col, @obstaclesGroup, @data.obstaclesField, fieldObject)

    # Добавление объекта типа type в клетку [row][col].
    Add: (row, col, type) ->
        if !@grid.IsValidRowCol(row, col)
            throw "Wrond RowCol in DrawField Add(row, col, type) method"
        object = new window.FieldObject(row, col, type, true)
        if object.IsCreature()
            @addToGroup(row, col, @creatureGroup, @data.creatureField, object)
            @ToogleDrag(object.sprite, true)
        else
            @addToGroup(row, col, @obstaclesGroup, @data.obstaclesField, object)

    # Перещение объекта на поле field из [row1][col1] в [row2][col2].
    Move: (field, row1, col1, row2, col2) ->
        if !@grid.IsValidRowCol(row1, col1) || !@grid.IsValidRowCol(row2, col2)
            throw "Wrong RowCol in DrawField Move method"
        if field[row2][col2]? && field[row2][col2] != field[row1][col1]
            throw "[row2][col2] in DrawField Move method was already filled"
        object = field[row1][col1]
        field[row1][col1] = undefined
        field[row2][col2] = object

        if object?
            object.row = row2
            object.col = col2
            coord = @grid.RowColToXY(row2, col2)
            object.sprite.x = coord.x
            object.sprite.y = coord.y
        return

    # Удаление объекта с клетки [row][col].
    Remove: (field, row, col) ->
        if !@grid.IsValidRowCol(row, col)
            throw new Error("Wrong RowCol in DrawField Remove method")
        field[row][col].sprite.destroy()
        field[row][col] = undefined
        return

    # Нахождение самого верхнего объекта
    GetUpperObject: (row, col) ->
        if !@grid.IsValidRowCol(row, col)
            throw new Error("Wrong RowCol in DrawField GetUpperObject method")
        return @data.GetUpperObject(row, col)


    # Подсветка области вокруг [row][col] радиусом rad.
    Highlight: (row, col, rad) ->
        @HighlightOff()
        highlight = @grid.GetBlocksInRadius(row, col, rad)
        for r in [0..highlight.length - 1]
            for k in [0..highlight[r].length - 1]
                i = highlight[r][k].row
                j = highlight[r][k].col
                @toogleVisibility(@data.highlightField[i][j], true)
        return

    # Отключение подсветки.
    HighlightOff: () ->
        for i in [0..@rowNum-1]
            for j in [0..@colNum-1]
                @toogleVisibility(@data.highlightField[i][j], false)
        return

    # Измнение режима перетаскивания спрайта.
    ToogleDrag: (sprite, value) ->
        if value
            sprite.input.enableDrag()
            sprite.events.onDragStart.add(@onDragStart, this)
            sprite.events.onDragStop.add(@onDragStop, this)
        else
            sprite.input.disableDrag()

    # Внутренние методы.
    # ---------------------------------------------------------------------------------------------------------------
    # Расчёт перевода глобальных коородинат в коородинаты XY у @grid
    getGridX: (x) -> x - @leftBound - @grid.hexWidth / 2
    getGridY: (y) -> y - @upperBound - @grid.hexHeight / 2

    # Сброс и инициализация группы спрайтов.
    resetGroup: (group) ->
        if group?
            group.destroy()
        group = @game.add.group()
        group.x = @leftBound
        group.y = @upperBound
        return group

    # Отрисовка спрайта.
    drawSprite: (x, y, object) ->
        sprite = @game.add.sprite(x, y, object.spriteTag)
        sprite.visible = object.isVisible
        return sprite

    # Добавление object в ячейку field[row][col] и отрисовка его спрайта с добавлением в group.
    addToGroup: (row, col, group, field, object) ->
        field[row][col] = object
        coord = @grid.RowColToXY(row, col)
        sprite = @drawSprite(coord.x, coord.y, object)
        object.sprite = sprite
        sprite.object = object
        sprite.inputEnabled = true
        group.add(sprite)
        return

    # Отрисовка объектов в field с добавлением в group.
    drawGroup: (group, field) ->
        group = @resetGroup group
        for i in [0..@rowNum-1]
            for j in [0..@colNum-1]
                if field[i][j]?
                    @addToGroup(i, j, group, field, field[i][j])
        return group

    # Обработчик начала перетаскивания спрайта, вешается в ToogleDrag.
    onDragStart: (sprite, pointer) ->
        rowcol = @grid.XYToRowCol(@getGridX(pointer.x), @getGridY(pointer.y))
        @HighlightOff()
        @Highlight(rowcol.row, rowcol.col, sprite.object.creature.GetMoveRange())
        return

    # Обработчик конца перетаскивания спрайта, вешается в ToogleDrag.
    onDragStop: (sprite, pointer) ->
        begin = {row: sprite.object.row, col: sprite.object.col}
        end = @grid.XYToRowCol(@getGridX(pointer.x), @getGridY(pointer.y))
        subject = @GetUpperObject(begin.row, begin.col)
        object = @GetUpperObject(end.row, end.col)
        action = ""

        try
            action = @logic.SelectAction(subject, object)
        catch e
            console.log(e)
            @Move(@data.creatureField, begin.row, begin.col, begin.row, begin.col)
            return
        
        if action == "Move"
            @Move(@data.creatureField, begin.row, begin.col, end.row, end.col)
        else if action == "RunHit"
            moveto = @grid.NearestNeighbour(object, subject)
            @Move(@data.creatureField, begin.row, begin.col, moveto.row, moveto.col)
        else
            @Move(@data.creatureField, begin.row, begin.col, begin.row, begin.col)
        
        @HighlightOff()
        return

    # Переключение видимости объекта и его спрайта.
    toogleVisibility: (object, value) ->
        object.isVisible = value
        if object.sprite?
            object.sprite.visible = value
        return