# Автор: Гусев Илья.
# Описание: Класс, содержащий 4 слоя объектов гексогонального поля.

class window.FieldData
    constructor: (@rowNum, @colNum) ->
        @groundField = @generateArray()
        @highlightField = @generateArray()
        @obstaclesField = @generateArray()
        @creatureField = @generateArray()
        for i in [0..@rowNum-1]
            for j in [0..@colNum-1]
                @groundField[i][j] = new window.FieldObject(i, j, "EMPTY", true)
                @highlightField[i][j] = new window.FieldObject(i, j, "HIGHLIGHT", false)

    # Вспомогательный метод для создания двумерного массива.
    generateArray: () -> new Array(@colNum) for i in [0..@rowNum-1]

    # Нахождение самого верхнего объекта
    GetUpperObject: (row, col) ->
        if @creatureField[row][col]?
            return @creatureField[row][col]
        else if @obstaclesField[row][col]?
            return @obstaclesField[row][col]
        else
            return @groundField[row][col]


