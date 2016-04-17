sin60 = Math.sqrt(3.0) * 0.5
cos60 = 0.5
sin30 = cos60
cos30 = sin60

class window.THexGrid
    constructor: (@hexWidth, @rowNum, @colNum) ->
        @edge = @hexWidth / (2 * sin60)
        @hexHeight = @hexWidth / sin60

        @fieldWidth = @hexWidth * (@colNum + 1/2)
        @fieldHeight = 3/4 * @hexHeight * (@rowNum - 1) + @hexHeight

    # Базисные функции RowCol->XY->Cube->RowCol.
    # ---------------------------------------------------------------------------------------------------------------
    # Преобразование в центр гексагона.
    RowColToXY: (row, col) ->
        x: (@hexWidth / 2) * (2 * col + (row&1))
        y: (@hexWidth / 2) * (2 * row * sin60)

    # Считаем проекции на оси x, y, z (в 1.5 * @edge).
    XYToCube: (x, y) ->
        x -= @hexWidth / 2
        y -= @hexHeight / 2
        float_cube =
            z: y  * 2/3 / @edge,
            x: ( x * cos30 - y * sin30 ) * 2/3 / @edge
        float_cube.y = -float_cube.x - float_cube.z
        @CubeRound(float_cube.x, float_cube.y, float_cube.z)

    CubeToRowCol: (x, y, z) ->
        col: x + (z - (z&1)) / 2
        row: z


    # Функции до полного набора.
    # ---------------------------------------------------------------------------------------------------------------
    RowColToCube: (row, col) ->
        # Подставил базисные, выразил явно.
        x: col - (row - (row&1)) / 2
        z: row
        y: -col - (row + (row&1)) / 2

    XYToRowCol: (x, y) ->
        cube = @XYToCube(x, y)
        @CubeToRowCol(cube.x, cube.y, cube.z)

    # Возращается x, y центра гексагона, в котором лежит точка (x, y, z).
    CubeToXY: (x, y, z) ->
        cl = @CubeToRowCol(x, y ,z)
        @RowColToXY(cl.row, cl.col)


    # Вспомогательные функции.
    # ---------------------------------------------------------------------------------------------------------------
    # Округление к целым (x, y, z).
    CubeRound: (x, y, z) ->
        rx = Math.round(x)
        ry = Math.round(y)
        rz = Math.round(z)

        x_diff = Math.abs(rx - x)
        y_diff = Math.abs(ry - y)
        z_diff = Math.abs(rz - z)

        if (x_diff > y_diff && x_diff > z_diff)
            rx = -ry-rz
        else if (y_diff > z_diff)
            ry = -rx-rz
        else
            rz = -rx-ry

        x: rx
        y: ry
        z: rz

    # Нахождение расстояния (в гексагонах) от одного элемента до другого
    GetDistance: (row1, col1, row2, col2) ->
        fcube = @RowColToCube(row1, col1)
        scube = @RowColToCube(row2, col2)
        Math.max(Math.abs(fcube.x - scube.x), Math.abs(fcube.y - scube.y), Math.abs(fcube.z - scube.z))

    # Нахождения массива соседних колец
    GetBlocksInRadius: (row, col, radius) ->
        fringes = [] # who is reachable in k steps
        fringes.push [] for k in [0..radius]

        for dy in [-radius..radius]
            len = 2 * radius + 1 - Math.abs(dy)
            left = if (row % 2 == 0) then -(Math.floor(len / 2)) else -(Math.ceil(len / 2)) + 1
            for dx in [left..left+len-1]
                current =
                    row: row + dy
                    col: col + dx
                if @IsValidRowCol(current.row, current.col)
                    fringes[@GetDistance(row, col, current.row, current.col)].push(current)
        fringes

    # Проверка на принадлежность сетке
    IsValidRowCol: (row, col) -> (col >= 0 && row >= 0 && col<@colNum && row<@rowNum)

	# Нахождение ближайшей к basic клетке по направлению к remote
	NearestNeighbour: (basic, remote) ->
		return 
