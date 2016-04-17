class window.FieldData
    constructor: (@rowNum, @colNum) ->
        @groundField = @GenerateArray()
        @highlightField = @GenerateArray()
        @creatureField = @GenerateArray()
        @obstaclesField = @GenerateArray()
        for i in [0..@rowNum-1]
            for j in [0..@colNum-1]
                @groundField[i][j] = new window.FieldObject(i, j, "EMPTY", true)
                @highlightField[i][j] = new window.FieldObject(i, j, "HIGHLIGHT", false)

    GenerateArray: () -> new Array(@colNum) for i in [0..@rowNum-1]
