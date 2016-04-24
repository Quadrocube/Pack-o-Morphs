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
    it "NearestNeightbour regular", () ->
        minitests = [[0,0,2,2,1,0], [5,1,5,6,5,2], [6,2,8,6,6,3], [8,3,6,1,7,2]]
        for test in minitests
            x = grid.NearestNeighbour(test[0], test[1], test[2], test[3])
            expect(x.row).toBe(test[4])
            expect(x.col).toBe(test[5])
    return
