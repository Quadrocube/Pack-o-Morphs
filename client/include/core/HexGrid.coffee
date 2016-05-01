# Автор: Гусев Илья.
# Описание: Класс, описывающий перобразования разных коородинатных сеток гексогонального поля.
# Ссылка на статью с алгоритмами: http://www.redblobgames.com/grids/hexagons/
# Cube:
#   В единицах this.hexWidth/2, только целые числа.
#   x + y + z = 0.
#   Направления: z = |, x = /^, y = \.
# XY:
#   В пикселях, могут быть нецелые числа.
#   Направления: ->, |.
# RowCol:
#   Только целые числа, индексы двумерного массива размерности @rowNum на @colNum.

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
    IsValidRowCol: (row, col) -> (col >= 0 && row >= 0 && col < @colNum && row < @rowNum)

    # Возвращает соседа по направлению direction
    #           / \     / \
    #         /     \ /     \
    #        |   2   |   1   |
    #        |       |       |
    #       / \     / \     / \
    #     /     \ /     \ /     \
    #    |   3   | basic |   0   |
    #    |       |       |       |
    #     \     / \     / \     /
    #       \ /     \ /     \ /
    #        |   4   |   5   |
    #        |       |       |
    #         \     / \     /
    #           \ /     \ /
    #
    GetNeighbour: (basic_row, basic_col, direction = 0) ->
        directions = [
           {x: +1, y: -1, z: 0 }, 
           {x: +1, y: 0 , z: -1}, 
           {x: 0 , y: +1, z: -1}, 
           {x: -1, y: +1, z: 0 }, 
           {x: -1, y: 0 , z: +1}, 
           {x: 0, y: -1,  z: +1}, 
        ]
        direction = direction % 6
        hex = @RowColToCube(basic_row, basic_col)
        hex.x += directions[direction].x
        hex.y += directions[direction].y
        hex.z += directions[direction].z
        return @CubeToRowCol(hex.x, hex.y, hex.z)

    # Возвращает следующего соседа в нумерации @GetNeighbour
    GetNextNeighbour: (basic_row, basic_col, neigh_row, neigh_col) ->
        for i in [0..5]
            candidate = @GetNeighbour(basic_row, basic_col, i)
            console.log candidate.row, candidate.col
            if neigh_row == candidate.row and neigh_col == candidate.col
                return @GetNeighbour(basic_row, basic_col, i + 1)
        throw new Error("basic (#{basic_row}, #{basic_col}) and neigh (#{neigh_row}, #{neigh_col}) are not nearby")

    # Нахождение ближайшей к basic клетке по направлению к remote
    NearestNeighbour: (basic_row, basic_col, remote_row, remote_col) ->
        cube_lerp = (a, b, t) ->
            x: a.x + (b.x - a.x) * t
            y: a.y + (b.y - a.y) * t
            z: a.z + (b.z - a.z) * t

        N = @GetDistance basic_row, basic_col, remote_row, remote_col
        basic  = @RowColToXY(basic_row, basic_col)
        remote = @RowColToXY(remote_row, remote_col)
        basic = @XYToCube(basic.x, basic.y)
        remote = @XYToCube(remote.x, remote.y)

        lerp = cube_lerp(basic, remote, 1.0 / N)
        ans = @CubeRound(lerp.x, lerp.y, lerp.z)
        ans_rc = @CubeToRowCol(ans.x, ans.y, ans.z)

        return ans_rc