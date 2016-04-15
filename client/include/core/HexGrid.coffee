sin60 = Math.sqrt(3.0) * 0.5
cos60 = 0.5
sin30 = cos60
cos30 = sin60

class window.THexGrid
    constructor: (width, height, @hexWidth, @rowNum, @colNum) ->
        @edge = @hexWidth / (2 * sin60)
        @hexHeight = @hexWidth / sin60

        @fieldWidth = @hexWidth * (@colNum + 1/2)
        @fieldHeight = 3/4 * @hexHeight * (@rowNum - 1) + @hexHeight

        @leftBound = (width - @fieldWidth) / 2
        @upperBound = (height - @fieldHeight) / 2


    # Базисные функции ColRow->XY->Cube->ColRow.
    # ---------------------------------------------------------------------------------------------------------------
    # Преобразование в центр гексагона.
    ColRowToXY: (row, col) ->
        x: (@hexWidth / 2) * (2 * col + (row&1))
        y: (@hexWidth / 2) * (2 * row * sin60)

    # Считаем проекции на оси x, y, z (в 1.5 * this.edge).
    XYToCube: (x, y) ->
        float_cube =
            z: y  * 2/3 / this.edge,
            x: ( x * cos30 - y * sin30 ) * 2/3 / this.edge
        float_cube.y = -float_cube.x - float_cube.z
        @CubeRound(float_cube.x, float_cube.y, float_cube.z)

    CubeToColRow: (x, y, z) ->
        col: x + (z - (z&1)) / 2
        row: z


    # Функции до полного набора.
    # ---------------------------------------------------------------------------------------------------------------
    ColRowToCube: (row, col) ->
        # Подставил базисные, выразил явно.
        x: col - (row - (row&1)) / 2
        z: row
        y: -col - (row + (row&1)) / 2

    XYToColRow: (x, y) ->
        cube = this.XYToCube(x, y)
        @CubeToColRow(cube.x, cube.y, cube.z)

    # Возращается x, y центра гексагона, в котором лежит точка (x, y, z).
    CubeToXY: (x, y, z) ->
        cl = this.CubeToColRow(x, y ,z)
        @ColRowToXY(cl.row, cl.col)


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

    # Преобразование в левый верхний угол прямоугольника, описывающего гексагон.
    ColRowToXYCorner: (row, col) ->
        center = @ColRowToXY(row, col)
        x: center.x - this.edge * sin60 - this.edge / 2
        y: center.y - this.edge


    # Нахождение ColRow относительно мировой сетки.
    HexInd : (worldX, worldY) ->
        x = worldX - @leftBound
        y = worldY - @upperBound
        if x < 0 or y < 0
            throw "Invalid position in HexInd"
        @XYToColRow(x, y)

    # Нахождение расстояния (в гексагонах) от одного элемента до другого
    GetDistance: (row1, col1, row2, col2) ->
        fcube = @ColRowToCube(row1, col1)
        scube = @ColRowToCube(row2, col2)
        Math.max(Math.abs(fcube.x - scube.x), Math.abs(fcube.y - scube.y), Math.abs(fcube.z - scube.z))

    # Нахождения массива соседних колец
    GetBlocksInRadius: (row, col, radius) ->
        fringes = [] # who is reachable in k steps
        fringes.push [] for k in [0..radius]

        for dy in [-radius..radius]
            len = 2 * radius + 1 - Math.abs(dy)
            left = if (row % 2 == 0) then -(Math.floor(len / 2)) else -(Math.ceil(len / 2)) + 1
            for dx in [left..left+len-1]
                current = {row: row + dy, col: col + dx}
                if col >= 0 and row >= 0
                    fringes[@GetDistance(row, col, current.row, current.col)].push(current)
        fringes

