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
    ColRowToXY: (col, row) ->
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
    ColRowToCube: (col, row) ->
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
        @ColRowToXY(cl.col, cl.row)


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
    ColRowToXYCorner: (col, row) ->
        center = @ColRowToXY(col, row)
        x: center.x - this.edge * sin60 - this.edge / 2
        y: center.y - this.edge


    # Нахождение ColRow относительно мировой сетки.
    HexInd : (worldX, worldY) ->
        x = worldX - this.leftBound
        y = worldY - this.upperBound
        if x < 0 or y < 0
            throw "Invalid position in HexInd"
        @XYToColRow(x, y)

    # Нахождение расстояния (в гексагонах) от одного элемента до другого
    GetDistance: (first, second) ->
        fcube = @ColRowToCube(first.col, first.row)
        scube = @ColRowToCube(second.col, second.row)
        Math.max(Math.abs(fcube.x - scube.x), Math.abs(fcube.y - scube.y), Math.abs(fcube.z - scube.z))

    # Нахождения массива соседних колец
    GetBlocksInRadius: (center, radius) ->
        fringes = [] # who is reachable in k steps
        fringes.push [] for k in [0..radius]

        for dy in [-radius..radius]
            len = 2 * radius + 1 - Math.abs(dy)
            left = if (center.row % 2 == 0) then -(Math.floor(len / 2)) else -(Math.ceil(len / 2)) + 1
            for dx in [left..left+len-1]
                row = center.row + dy
                col = center.col + dx
                if col >= 0 and row >= 0
                    current = {col: col, row: row}
                    fringes[this.GetDistance(center, current)].push(current)
        fringes

describe "Tests for HexGrid", () ->
    grid = new window.THexGrid(1000, 800, 35, 20, 16)
    it "Тест на правильность выполнения 2 кругов ColRow -> ColRow", () ->
        for i in [0..grid.rowNum-1]
            for j in [0..grid.colNum-1]
                xy = grid.ColRowToXY(j, i);
                cube = grid.XYToCube(xy.x, xy.y);
                colrow = grid.CubeToColRow(cube.x, cube.y, cube.z)
                expect(colrow.col==j && colrow.row==i).toBe(true)

                cube = grid.ColRowToCube(j, i)
                colrow = grid.CubeToColRow(cube.x, cube.y, cube.z)
                expect(colrow.col==j && colrow.row==i).toBe(true)
        return
    return

