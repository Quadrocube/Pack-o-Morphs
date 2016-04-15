class window.FieldData
    constructor: (@rowNum, @colNum) ->
        @hexField = (new Array(@colNum) for i in [0..@rowNum-1])
        @creatureField = [];
        @lastHighlight = [];
        for i in [0..@rowNum-1]
            for j in [0..@colNum-1]
                @hexField[i][j] = new window.FieldObject(i, j, null, null, null)
