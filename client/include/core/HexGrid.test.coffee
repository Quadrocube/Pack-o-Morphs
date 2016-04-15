describe "Tests for HexGrid", () ->
    grid = new window.THexGrid(1000, 800, 35, 20, 16)
    it "Тест на правильность выполнения 2 кругов ColRow -> ColRow", () ->
        for i in [0..grid.rowNum-1]
            for j in [0..grid.colNum-1]
                xy = grid.ColRowToXY(i, j);
                cube = grid.XYToCube(xy.x, xy.y);
                colrow = grid.CubeToColRow(cube.x, cube.y, cube.z)
                expect(colrow.col==j && colrow.row==i).toBe(true)

                cube = grid.ColRowToCube(i, j)
                colrow = grid.CubeToColRow(cube.x, cube.y, cube.z)
                expect(colrow.col==j && colrow.row==i).toBe(true)
        return
    return
