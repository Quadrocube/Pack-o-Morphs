// Автор: Гусев Илья.
// Класс, описывающий перобразования разных коородинатных сеток гексогонального поля.

// https://habrahabr.ru/post/147082/
// http://www.redblobgames.com/grids/hexagons/

// MLR:
//  В единицах this.hexWidth/2, только целые числа.
//  r + l - m = 0.
//  Направления: m = ->, l = /^, r = \.

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

    this.fieldWidth = this.hexWidth * this.colNum;
    this.fieldHeight = this.hexHeight * this.rowNum;

    this.leftBound = (width - this.fieldWidth) / 2;
    this.upperBound = (height - this.fieldHeight);
}

THexagonGrid.prototype = {
    // Базисные функции ColRow->XY->MLR->ColRow.
    // ---------------------------------------------------------------------------------------------------------------

    // Преобразование в центр гексагона.
    ColRowToXY: function (col, row) {
        return {
            x: (this.hexWidth / 2) * (2 * col + (row&1)),
            y: (this.hexWidth / 2) * (2 * row * sin60),
        };
    },

    // Считаем проекции на оси m, l и r (в половинах периода решетки, то есть в единицах this.hexWidth/2).
    XYToMLR: function (x, y) {
        return {
            m: Math.floor(2 * x / this.hexWidth),
            l: Math.floor(2 * (cos60 * x - sin60 * y) / this.hexWidth),
            r: Math.floor(2 * (cos60 * x + sin60 * y) / this.hexWidth),
        }
    },

    MLRToColRow: function (m, l, r) {
        var row = Math.floor((r - l + 1) / 3.0)
        return {
            col: Math.floor((m + l + 2) / 3.0) + Math.floor(row / 2) ,
            row: row,
        };
    },

    // Функции до полного набора.
    // ---------------------------------------------------------------------------------------------------------------

    ColRowToMLR: function (col, row) {
        // Подставил базисные, выразил явно.
        return {
            m: 2 * col  + (row&1),
            r: 1.5 * row + col + (row&1) / 2,
            l: -1.5 * row + col + (row&1) / 2,
        };
    },

    XYToColRow: function(x, y) {
        var mlr = this.XYToMLR(x, y);
        return this.MLRToColRow(mlr.m, mlr.l, mlr.r);
    },

    // Возращается x, y центра гексагона, в котором лежит точка (m, l, r).
    MLRToXY: function (m, l ,r) {
        var cl = this.MLRToColRow(m, l ,r);
        return this.ColRowToXY(cl.col, cl.row);
    },

    // Вспомогательные функции.
    // ---------------------------------------------------------------------------------------------------------------

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
        var fmlr = this.ColRowToMLR(first.col, first.row);
        var smlr = this.ColRowToMLR(second.col, second.row);
        return Math.ceil(Math.max(Math.abs(fmlr.m - smlr.m), Math.abs(fmlr.l - smlr.l), Math.abs(fmlr.r - smlr.r)) / 2);
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
        console.log(fringes);
    },

    // Тест на правильность выполнения 2 кругов ColRow -> ColRow
    Test: function () {
        for (var i = 0; i < this.rowNum; i++) {
            for (var j = 0; j < this.colNum; j++) {
                var xy = this.ColRowToXY(j, i);
                var colrow = this.XYToColRow(xy.x, xy.y);
                if (colrow.col!=j || colrow.row!=i){
                    console.log("Test failed");
                    return false;
                }

                var mlr = this.ColRowToMLR(j, i);
                colrow = this.MLRToColRow(mlr.m, mlr.l, mlr.r);
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