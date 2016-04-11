// Автор: Гусев Илья.
// Класс, описывающий перобразования разных коородинатных сеток гексогонального поля.

// https://habrahabr.ru/post/147082/
// http://www.redblobgames.com/grids/hexagons/

// Cube:
//  В единицах this.hexWidth/2, только целые числа.
//  x + y +z = 0.
//  Направления: z = |, x = /^, y = \.

// XY:
//  В пикселях, могут быть нецелые числа.
//  Направления: |, ->.

// ColRow:
//  Только целые числа, индексы двумерного массива размерности colNum x rowNum.

var sin60 = Math.sqrt(3.0) * 0.5;
var cos60 = 0.5;
var sin30 = cos60;
var cos30 = sin60;

function THexagonGrid(width, height, hexWidth, colNum, rowNum) {
    this.hexWidth = hexWidth;
    this.colNum = colNum;
    this.rowNum = rowNum;

    this.edge = this.hexWidth / (2 * sin60);
    this.hexHeight = this.hexWidth / sin60;

    this.fieldWidth = this.hexWidth * (this.colNum + 1/2);
    this.fieldHeight = 3/4 * this.hexHeight * (this.rowNum - 1) + this.hexHeight;

    this.leftBound = (width - this.fieldWidth) / 2;
    this.upperBound = (height - this.fieldHeight) / 2;
}

THexagonGrid.prototype = {
    // Базисные функции ColRow->XY->Cube->ColRow.
    // ---------------------------------------------------------------------------------------------------------------

    // Преобразование в центр гексагона.
    ColRowToXY: function (col, row) {
        return {
            x: (this.hexWidth / 2) * (2 * col + (row&1)),
            y: (this.hexWidth / 2) * (2 * row * sin60),
        };
    },

    // Считаем проекции на оси x, y, z (в 1.5 * this.edge).
    XYToCube: function (x, y) {
        var float_cube = {
            z: y  * 2/3 / this.edge,
            x: ( x * cos30 - y * sin30 ) * 2/3 / this.edge,
        }
        float_cube.y = -float_cube.x - float_cube.z;
        return this.CubeRound(float_cube.x, float_cube.y, float_cube.z);
    },

    CubeToColRow: function (x, y, z) {
        return {
            col: x + (z - (z&1)) / 2 ,
            row: z,
        };
    },

    // Функции до полного набора.
    // ---------------------------------------------------------------------------------------------------------------

    ColRowToCube: function (col, row) {
        // Подставил базисные, выразил явно.
        return {
            x: col - (row - (row&1)) / 2,
            z: row,
            y: -col - (row + (row&1)) / 2,
        };
    },

    XYToColRow: function(x, y) {
        var cube = this.XYToCube(x, y);
        return this.CubeToColRow(cube.x, cube.y, cube.z);
    },

    // Возращается x, y центра гексагона, в котором лежит точка (x, y, z).
    CubeToXY: function (x, y, z) {
        var cl = this.CubeToColRow(x, y ,z);
        return this.ColRowToXY(cl.col, cl.row);
    },

    // Вспомогательные функции.
    // ---------------------------------------------------------------------------------------------------------------

    // Округление к целым (x, y, z).
    CubeRound(x, y, z){
        var rx = Math.round(x)
        var ry = Math.round(y)
        var rz = Math.round(z)

        var x_diff = Math.abs(rx - x)
        var y_diff = Math.abs(ry - y)
        var z_diff = Math.abs(rz - z)

        if (x_diff > y_diff && x_diff > z_diff)
            rx = -ry-rz
        else if (y_diff > z_diff)
            ry = -rx-rz
        else
            rz = -rx-ry

        return {
            x: rx,
            y: ry,
            z: rz
        }
    },

    // Преобразование в левый верхний угол прямоугольника, описывающего гексагон.
    ColRowToXYCorner: function (col, row) {
        var center = this.ColRowToXY(col, row);
        return {
            x: center.x - this.edge * sin60 - this.edge / 2,
            y: center.y - this.edge,
        };
    },

    // Нахождение ColRow относительно мировой сетки.
    HexInd : function (worldX, worldY) {
        var x = worldX - this.leftBound;
        var y = worldY - this.upperBound;
        if (x < 0 || y < 0)
            throw "Invalid position in HexInd";
        return this.XYToColRow(x, y);
    },

    // Нахождение расстояния (в гексагонах) от одного элемента до другого
    GetDistance: function (first, second) {
        var fcube = this.ColRowToCube(first.col, first.row);
        var scube = this.ColRowToCube(second.col, second.row);
        return Math.max(Math.abs(fcube.x - scube.x), Math.abs(fcube.y - scube.y), Math.abs(fcube.z - scube.z));
    },

    // Нахождения массива соседних колец
    GetBlocksInRadius: function (center, radius) {
        var fringes = []; // who is reachable in k steps
        for (var k = 0; k <= radius; k++)
            fringes.push([]);
        for (var dy = -radius; dy <= radius; dy++){
            var len = 2 * radius + 1 - Math.abs(dy);
            var left = (center.row % 2 == 0) ? -(Math.floor(len / 2)) : -(Math.ceil(len / 2)) + 1;
            for (var dx = left; dx < left + len; dx++){
                var row = center.row + dy;
                var col = center.col + dx;
                if (col >= 0 && row >= 0) {
                    var current = {col: col, row: row};
                    fringes[this.GetDistance(center, current)].push(current);
                }
            }
        }
    },

    // Тест на правильность выполнения 2 кругов ColRow -> ColRow
    Test: function () {
        for (var i = 0; i < this.rowNum; i++) {
            for (var j = 0; j < this.colNum; j++) {
                var xy = this.ColRowToXY(j, i);
                var cube = this.XYToCube(xy.x, xy.y);
                var colrow = this.CubeToColRow(cube.x, cube.y, cube.z);
                if (colrow.col!=j || colrow.row!=i){
                    console.log(i, j, xy, cube, colrow)
                    console.log("Test failed");
                    return false;
                }

                var cube = this.ColRowToCube(j, i);
                colrow = this.CubeToColRow(cube.x, cube.y, cube.z);
                if (colrow.col!=j || colrow.row!=i){
                    console.log("Test failed");
                    return false;
                }
            }
        }
        console.log("Test passed");
        return true;
    },
}