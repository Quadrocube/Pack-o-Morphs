# Автор: Гусев Илья.
# Описание: Класс, отрисовывающий 4-слойное гексогональное поле. Первый слой - поверхность (ground).
# Второй слой - подсветка (highlight). Третий слой - препятствия (obstacles). Четвёртый слой - существа (creatures).

class window.DrawField
    constructor: (@game, @data, @grid, @logic, @turnState) ->
        @rowNum = @data.rowNum
        @colNum = @data.colNum

        @groundGroup = @game.add.group()
        @highlightGroup = @game.add.group()
        @obstaclesGroup = @game.add.group()
        @creaturesGroup = @game.add.group()

        @locked = false
        @draggedObject = null

    # Интерфейс.
    # ---------------------------------------------------------------------------------------------------------------
    Draw: () ->
        @leftBound = (@game.width - @grid.fieldWidth) / 2
        @upperBound = (@game.height - @grid.fieldHeight) / 2 - 100

        # Инициализация и отрисовка начальных обектов
        @DrawGroup(@groundGroup, @data.groundField)
        @DrawGroup(@highlightGroup, @data.highlightField)
        @DrawGroup(@obstaclesGroup, @data.obstaclesField)
        @DrawGroup(@creaturesGroup, @data.creaturesField)
    
    # Блокирование перемещений по полю
    Lock: () ->
        @locked = true
        @Draw()

    # Разблокирование перемещений по полю
    Unlock: () ->
        @locked = false
        @Draw()

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

    # Обработка нажатия (связь с барами)
    OnClick: (@actionBar, @infoBar) ->
        return @onClick


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
        if not @locked
            @toggleDrag(sprite, object.IsDraggable(@turnState.clientPlayer.id))
        else
            @toggleDrag(sprite, false)
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
        # Может быть, что по поинту не draggable, а по спрайту вполне, поэтому дополнительная проверка
        if @draggedObject.IsDraggable(@turnState.clientPlayer.id)
            @highlightTimer = @game.time.create(true)
            @highlightTimer.add(100, @Highlight, this, rowcol.row, rowcol.col, @draggedObject.creature.GetMoveRange())
            @highlightTimer.start()
        return

    # Обработчик конца перетаскивания спрайта, вешается в toggleDrag.
    onDragStop: (sprite, pointer) ->
        if @highlightTimer?
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

    # Обработчик нажатия - внутренняя часть
    onClick: (pointer) =>
        rowcol = @grid.XYToRowCol(@getGridX(pointer.x), @getGridY(pointer.y))
        row = rowcol.row
        col = rowcol.col
        if @grid.IsValidRowCol(row, col)
            object = @data.GetUpperObject(row, col)
            @HighlightOff()
            @Highlight(row, col, 0)
            @infoBar.DisplayObjectInfo(object)

            morph = (type) =>
                from = object
                to = new FieldObject(from.row, from.col, type, true, from.player)
                @logic.Morph(from, to)
                return

            morphCallbacks = () =>
                "morph_vector": () =>
                    morph("VECTOR")
                'morph_cocoon': () =>
                    morph("COCOON")
                'morph_plant': () =>
                    morph("PLANT")
                'morph_spawn': () =>
                    morph("SPAWN")
                'morph_daemon': () =>
                    morph("DAEMON")
                'morph_turtle': () =>
                    morph("TURTLE")
                #'morph_rhino': () =>
                #    morph("RHINO")
                #'morph_wasp': () =>
                #    morph("WASP")
                #'morph_spider': () =>
                #    morph("SPIDER")
                'morph_cancel': () =>
                    @actionBar.DisplayObjectActions(object, actionCallbacks())

            actionCallbacks = () =>
                "morph": () =>
                    console.log("morph")
                    @actionBar.DisplayObjectActions(object, morphCallbacks())
                "yield": () =>
                    console.log("yield")
                "replicate": () =>
                    console.log("replicate")
                "feed": () =>
                    console.log("feed")
                "spec_ability": () =>
                    console.log("spec_ability")
            if object.IsOwnedBy(@turnState.clientPlayer.id)
                @actionBar.DisplayObjectActions(object, actionCallbacks())