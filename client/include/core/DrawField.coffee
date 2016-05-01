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

        @draggedObject = null

        # Пример
        @data.creaturesField[11][11] = new window.FieldObject(11, 11, "VECTOR")
        @data.creaturesField[10][10] = new window.FieldObject(10, 10, "VECTOR")

        # Инициализация и отрисовка начальных обектов
        @groundGroup = @game.add.group()
        @highlightGroup = @game.add.group()
        @obstaclesGroup = @game.add.group()
        @creaturesGroup = @game.add.group()
        @DrawGroup(@groundGroup, @data.groundField)
        @DrawGroup(@highlightGroup, @data.highlightField)
        @DrawGroup(@obstaclesGroup, @data.obstaclesField)
        @DrawGroup(@creaturesGroup, @data.creaturesField)

        @game.input.mouse.mouseDownCallback = (pointer) =>
            rowcol = @grid.XYToRowCol(@getGridX(pointer.x), @getGridY(pointer.y))
            row = rowcol.row
            col = rowcol.col
            if @grid.IsValidRowCol(row, col)
                object = @data.GetUpperObject(row, col)
                @HighlightOff()
                @Highlight(row, col, 0)
                buttonCallbacks = (logic) ->
                    "morph": (subject, object) =>
                        logic.Morph(subject, object)
                @actionBar.DisplayObjectActions(object, buttonCallbacks(@logic))
                @infoBar.DisplayObjectInfo(object)

    # Интерфейс.
    # ---------------------------------------------------------------------------------------------------------------
    # Подсветка области вокруг [row][col] радиусом rad.
    Highlight: (row, col, rad) ->
        @HighlightOff()
        highlight = @grid.GetBlocksInRadius(row, col, rad)
        for r in [0..highlight.length - 1]
            for k in [0..highlight[r].length - 1]
                i = highlight[r][k].row
                j = highlight[r][k].col
                @data.highlightField[i][j].isVisible = true
        @DrawGroup(@highlightGroup, @data.highlightField)
        return

    # Отключение подсветки.
    HighlightOff: () ->
        for i in [0..@rowNum-1]
            for j in [0..@colNum-1]
                @data.highlightField[i][j].isVisible = false
        @DrawGroup(@highlightGroup, @data.highlightField)
        return

    # Отрисовка объектов в field с добавлением в group.
    DrawGroup: (group, field) ->
        @resetGroup group
        for i in [0..@rowNum-1]
            for j in [0..@colNum-1]
                if field[i][j]?
                    @addToGroup(i, j, group, field, field[i][j])
        return

    # Внутренние методы.
    # ---------------------------------------------------------------------------------------------------------------
    # Расчёт перевода глобальных коородинат в коородинаты XY у @grid
    getGridX: (x) -> x - @leftBound - @grid.hexWidth / 2
    getGridY: (y) -> y - @upperBound - @grid.hexHeight / 2

    # Сброс и инициализация группы спрайтов.
    resetGroup: (group) ->
        group.removeAll(true)
        group.x = @leftBound
        group.y = @upperBound
        return

    # Отрисовка спрайта.
    drawSprite: (x, y, object) ->
        sprite = @game.add.sprite(x, y, object.spriteTag)
        sprite.visible = object.isVisible
        sprite.inputEnabled = true
        @toggleDrag(sprite, object.isDraggable)
        return sprite

    # Добавление object в ячейку field[row][col] и отрисовка его спрайта с добавлением в group.
    addToGroup: (row, col, group, field, object) ->
        field[row][col] = object
        coord = @grid.RowColToXY(row, col)
        sprite = @drawSprite(coord.x, coord.y, object)
        group.add(sprite)
        return

    # Измнение режима перетаскивания спрайта.
    toggleDrag: (sprite, value) ->
        if value
            sprite.input.enableDrag()
            sprite.events.onDragStart.add(@onDragStart, this)
            sprite.events.onDragStop.add(@onDragStop, this)
        else
            sprite.input.disableDrag()

    # Обработчик начала перетаскивания спрайта, вешается в toggleDrag.
    onDragStart: (sprite, pointer) ->
        rowcol = @grid.XYToRowCol(@getGridX(pointer.x), @getGridY(pointer.y))
        @draggedObject = @data.GetUpperObject(rowcol.row, rowcol.col)
        @highlightTimer = @game.time.create(true);
        @highlightTimer.add(100, @Highlight, this, rowcol.row, rowcol.col, @draggedObject.creature.GetMoveRange())
        @highlightTimer.start()
        return

    # Обработчик конца перетаскивания спрайта, вешается в toggleDrag.
    onDragStop: (sprite, pointer) ->
        @highlightTimer.destroy()
        begin = @draggedObject
        end = @grid.XYToRowCol(@getGridX(pointer.x), @getGridY(pointer.y))
        try
            @HighlightOff()
            if not (begin.row == end.row and begin.col == end.col)
                subject = @data.GetUpperObject(begin.row, begin.col)
                object = @data.GetUpperObject(end.row, end.col)
                @logic.DoAction(subject, object)
            else
                @Highlight(begin.row, begin.col, 0)
        catch e
            console.log(e)
        finally
            @DrawGroup(@obstaclesGroup, @data.obstaclesField)
            @DrawGroup(@creaturesGroup, @data.creaturesField)
            return