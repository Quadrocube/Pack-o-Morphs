describe "Tests for HexGrid", () ->
    grid = new window.THexGrid(35, 20, 16)
    it "Тест на правильность выполнения 2 кругов RowCol -> RowCol", () ->
        for i in [0..grid.rowNum-1]
            for j in [0..grid.colNum-1]
                xy = grid.RowColToXY(i, j)
                cube = grid.XYToCube(xy.x, xy.y)
                rowcol = grid.CubeToRowCol(cube.x, cube.y, cube.z)
                expect(rowcol.col == j && rowcol.row == i).toBe(true)

                cube = grid.RowColToCube(i, j)
                rowcol = grid.CubeToRowCol(cube.x, cube.y, cube.z)
                expect(rowcol.col == j && rowcol.row == i).toBe(true)
        return
    return
