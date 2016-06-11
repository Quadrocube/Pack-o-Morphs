# Автор: Гусев Илья.
# Описание: Класс, содержащий 4 слоя объектов гексогонального поля.

class window.FieldData
    constructor: (@rowNum, @colNum) ->
        @groundField = @generateArray()
        @highlightField = @generateArray()
        @obstaclesField = @generateArray()
        @creaturesField = @generateArray()
        for i in [0..@rowNum-1]
            for j in [0..@colNum-1]
                @groundField[i][j] = new window.FieldObject(i, j, "EMPTY", true)
                @highlightField[i][j] = new window.FieldObject(i, j, "HIGHLIGHT", false)

        grass = [[17,12],[0,7],[1,8],[2,8],[2,7],[2,6],[1,6],[1,10],[0,11],[1,12],[2,12],[2,11],[2,10],
            [13,11],[14,11],[15,10],[14,9],[13,9],[13,10],[13,7],[14,7],[15,6],[14,5],[13,5],[13,6]]
        playerOne = [[7,0],[6,1],[7,2],[8,2],[8,1],[8,0]]
        playerTwo = [[7,18],[6,17],[7,16],[8,16],[8,17],[8,18]]
        for cell in grass
            @obstaclesField[cell[1]][cell[0]] = new window.FieldObject(cell[1], cell[0], "GRASS")
        for cell in playerOne
            @creaturesField[cell[1]][cell[0]] = new window.FieldObject(cell[1], cell[0], "VECTOR")
        for cell in playerTwo
            @creaturesField[cell[1]][cell[0]] = new window.FieldObject(cell[1], cell[0], "VECTOR", true, 1)

    # Вспомогательный метод для создания двумерного массива.
    generateArray: () -> new Array(@colNum) for i in [0..@rowNum-1]

    # Нахождение самого верхнего объекта
    GetUpperObject: (row, col) ->
        if @creaturesField[row][col]?
            return @creaturesField[row][col]
        else if @obstaclesField[row][col]?
            return @obstaclesField[row][col]
        else
            return @groundField[row][col]

    IsFieldCreatureless: (row, col) ->
        return (@creaturesField[row][col] == undefined)

    Load: (newData) ->
        @rowNum = newData.rowNum
        @colNum = newData.colNum
        for i in [0..@rowNum-1]
            for j in [0..@colNum-1]
                @groundField[i][j] = new window.FieldObject(i, j, "EMPTY", true)
                @highlightField[i][j] = new window.FieldObject(i, j, "HIGHLIGHT", false)
                obstacle = newData.obstaclesField[i][j]
                if obstacle?
                    @obstaclesField[i][j] = new window.FieldObject(
                        obstacle.row, obstacle.col, obstacle.type, obstacle.isVisible, obstacle.player, (new window.Creature()).Load(obstacle.creature))
                else
                    @obstaclesField[i][j] = undefined 
                creature = newData.creaturesField[i][j]
                if creature?
                    @creaturesField[i][j] = new window.FieldObject(
                        creature.row, creature.col, creature.type, creature.isVisible, creature.player, (new window.Creature()).Load(creature.creature))
                else
                    @creaturesField[i][j] = undefined


