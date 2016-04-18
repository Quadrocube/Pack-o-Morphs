# Автор: Гусев Илья.
# Описание: Класс, содержащий 4 слоя объектов гексогонального поля.

class window.FieldData
    constructor: (@rowNum, @colNum) ->
        @groundField = @GenerateArray()
        @highlightField = @GenerateArray()
        @obstaclesField = @GenerateArray()
        @creatureField = @GenerateArray()
        for i in [0..@rowNum-1]
            for j in [0..@colNum-1]
                @groundField[i][j] = new window.FieldObject(i, j, "EMPTY", true)
                @highlightField[i][j] = new window.FieldObject(i, j, "HIGHLIGHT", false)

    # Вспомогательный метод для создания двумерного массива.
    GenerateArray: () -> new Array(@colNum) for i in [0..@rowNum-1]
