# Автор: Гусев Илья.
# Описание: Класс, отрисовывающий 4-слойное гексогональное поле. Первый слой - поверхность (ground).
# Второй слой - подсветка (highlight). Третий слой - препятствия (obstacles). Четвёртый слой - существа (creatures).

class window.DrawField
    constructor: (@game, hexWidth, @rowNum, @colNum) ->
        @data = new window.FieldData(@rowNum, @colNum)
        @grid = new window.THexGrid(hexWidth, @rowNum, @colNum)
        @leftBound = (@game.width - @grid.fieldWidth) / 2
        @upperBound = (@game.height - @grid.fieldHeight) / 2

        @groundGroup = @DrawGroup(@groundGroup, @data.groundField)
        @highlightGroup = @DrawGroup(@highlightGroup, @data.highlightField)
        @obstaclesGroup = @DrawGroup(@obstaclesGroup, @data.obstaclesField)
        @creatureGroup = @DrawGroup(@creatureGroup, @data.creatureField)

        @game.input.mouse.mouseDownCallback = () =>
            rowcol = @grid.XYToRowCol(@GetGridX(@game.input.worldX), @GetGridY(@game.input.worldY))
            row = rowcol.row
            col = rowcol.col
            if @grid.IsValidRowCol(row, col)
                object = @GetUpperObject(row, col)
                actionBar = window.ActionBar.getInstance(@game, @grid)
                if object.IsCreature()
                    actionBar.unlock()
                else
                    actionBar.lock()

        # Пример
        @Highlight(4, 4, 3)
        @Add(4, 4, "VECTOR")
        @Add(10, 10, "VECTOR")
        @Move(@data.creatureField, 4, 4, 11, 11)

    # Интерфейс.
    # ---------------------------------------------------------------------------------------------------------------
    # Добваление объекта типа type в клетку [row][col].
    Add: (row, col, type) ->
        if !@grid.IsValidRowCol(row, col)
            throw "Wrond RowCol in DrawField Add method"
        object = new window.FieldObject(row, col, type, true)
        if object.IsCreature()
            @AddToGroup(row, col, @creatureGroup, @data.creatureField, object)
            @ToogleDrag(object.sprite, true)
        else
            @AddToGroup(row, col, @obstaclesGroup, @data.obstaclesField, object)

    # Перещение объекта на поле field из [row1][col1] в [row2][col2].
    Move: (field, row1, col1, row2, col2) ->
        if !@grid.IsValidRowCol(row1, col1) || !@grid.IsValidRowCol(row2, col2)
            throw "Wrond RowCol in DrawField Move method"
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
            throw "Wrond RowCol in DrawField Remove method"
        field[row][col] = undefined
        return

    # Нахождение самого верхнего объекта
    GetUpperObject: (row, col) ->
        if !@grid.IsValidRowCol(row, col)
            throw "Wrond RowCol in DrawField GetUpperObject method"
        return @data.GetUpperObject(row, col)


    # Подсветка области вокруг [row][col] радиусом rad.
    Highlight: (row, col, rad) ->
        @HighlightOff()
        highlight = @grid.GetBlocksInRadius(row, col, rad)
        for r in [0..highlight.length - 1]
            for k in [0..highlight[r].length - 1]
                i = highlight[r][k].row
                j = highlight[r][k].col
                @ToogleVisibility(@data.highlightField[i][j], true)
        return

    # Отключение подсветки.
    HighlightOff: () ->
        for i in [0..@rowNum-1]
            for j in [0..@colNum-1]
                @ToogleVisibility(@data.highlightField[i][j], false)
        return

    # Измнение режима перетаскивания спрайта.
    ToogleDrag: (sprite, value) ->
        sprite.inputEnabled = value
        if value
            sprite.input.enableDrag()
            sprite.events.onDragStart.add(@OnDragStart, this)
            sprite.events.onDragStop.add(@OnDragStop, this)
        else
            sprite.input.disableDrag()

    # Внутренние методы.
    # ---------------------------------------------------------------------------------------------------------------
    # Расчёт перевода глобальных коородинат в коородинаты XY у @grid
    GetGridX: (x) -> x - @leftBound - @grid.hexWidth / 2
    GetGridY: (y) -> y - @upperBound - @grid.hexHeight / 2

    # Сброс и инициализация группы спрайтов.
    ResetGroup: (group) ->
        if group?
            group.destroy()
        group = @game.add.group()
        group.x = @leftBound
        group.y = @upperBound
        return group

    # Отрисовка спрайта.
    DrawSprite: (x, y, object) ->
        sprite = @game.add.sprite(x, y, object.spriteTag)
        sprite.visible = object.isVisible
        return sprite

    # Добавление object в ячейку field[row][col] и отрисовка его спрайта с добавлением в group.
    AddToGroup: (row, col, group, field, object) ->
        field[row][col] = object
        coord = @grid.RowColToXY(row, col)
        sprite = @DrawSprite(coord.x, coord.y, object)
        object.sprite = sprite
        sprite.object = object
        group.add(sprite)
        return

    # Отрисовка объектов в field с добавлением в group.
    DrawGroup: (group, field) ->
        group = @ResetGroup group
        for i in [0..@rowNum-1]
            for j in [0..@colNum-1]
                if field[i][j]?
                    @AddToGroup(i, j, group, field, field[i][j])
        return group

    # Обработчик начала перетаскивания спрайта, вешается в ToogleDrag.
    OnDragStart: (sprite, pointer) ->
        rowcol = @grid.XYToRowCol(@GetGridX(pointer.x), @GetGridY(pointer.y))
        @HighlightOff()
        @Highlight(rowcol.row, rowcol.col, 3)
        return

    # Обработчик конца перетаскивания спрайта, вешается в ToogleDrag.
    OnDragStop: (sprite, pointer) ->
        end = @grid.XYToRowCol(@GetGridX(pointer.x), @GetGridY(pointer.y))
        @Move(@data.creatureField, sprite.object.row, sprite.object.col, end.row, end.col)
        @Highlight(end.row, end.col, 3)
        return

    # Переключение видимости объекта и его спрайта.
    ToogleVisibility: (object, value) ->
        object.isVisible = value
        if object.sprite?
            object.sprite.visible = value
        return