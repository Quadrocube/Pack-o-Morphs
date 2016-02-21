
function MySet() {
    this.carry = [];
    this.has = function(obj) {
        for (i = 0; i < this.carry.length; i++) {
            if (this.carry[i].equals(obj))
                return true;
        }
        return false;
    }
    this.get = function(obj) {
        for (i = 0; i < this.carry.length; i++) {
            if (this.carry[i].equals(obj))
                return this.carry[i];
        }
        return null;
    }
    this.add = function (obj) {
        if (!this.has(obj)) {
            this.carry.push(obj);
            return false;
        }
        return true;
    }
}

var THex_directions = [
        new THex(+1, -1,  0), new THex(+1,  0, -1), new THex( 0, +1, -1),
        new THex(-1, +1,  0), new THex(-1,  0, +1), new THex( 0, -1, +1)
];

function THex(x, y, z) {
    this.x = parseInt(x);
    this.y = parseInt(y);
    this.z = parseInt(z);
    this.__type__ = "T_hex";

    this.equals = function (another) {
        return (this.x == another.x && this.y == another.y && this.z == another.z);
    };
    
    this.from_colrow = function (col, row) {
        this.x = col - (row - (row&1)) / 2;
        this.z = row;
        this.y = -this.x - this.z;
        return this;
    };
    this.to_colrow = function () {
        return [this.x + (this.z - (this.z & 1)) / 2, this.z, ];
    };
    
    this.getx = function () {
        return this.x;
    };
    this.gety = function () {
        return this.y;
    };
    this.getz = function () {
        return this.z;
    };

    this.add = function (hex) {
        return new THex(this.getx() + hex.getx(), this.gety() + hex.gety(), this.getz() + hex.getz());
    };
    
    this.neigh = function(direction) {
        return this.add(THex_directions[direction]);
    };
    
    this.distance = function (another) {
        if (!another || another.__type__ != "T_hex")
            return null;
        return Math.max(Math.abs(this.getx() - another.getx()), Math.abs(this.gety() - another.gety()), Math.abs(this.getz() - another.getz()));
    };
    
    this.radius = function (radius) {
        radius = parseInt(radius);
        if (isNaN(radius)) 
            return null;
        var result = [];
        for (var dx = -radius; dx <= radius; dx++) {
            for (var dy = Math.max(-radius, -radius-dx); dy <= Math.min(radius, radius-dx); dy++) {
                result.push(this.add(new THex(dx, dy, -dx - dy)));
            }
        }
        return result;
    };
    
    this.radius_with_blocks = function (radius, _blocked) {
        var visited = new MySet();
        var blocked = new MySet();
        blocked.carry = _blocked;
        
        visited.add(this);
        var fringes = []; // who is reachable in k steps
        fringes.push([this]);
    
        for (var k = 1; k <= radius; k++) {
            fringes.push([]);
            for (var i = 0; i < fringes[k-1].length; i++) {
                var cube = fringes[k-1][i];
                for (var dir = 0; dir < 6; dir++) {
                    var neighbour = cube.neigh(dir);
                    if (!(visited.has(neighbour)) && !(blocked.has(neighbour))) {
                        visited.add(neighbour);
                        fringes[k].push(neighbour);
                    }
                }
            }
        }
        return visited.carry;
    };
}

// column = x, row = y
function ColRowPair (col, row) {
    this.row = row;
    this.col = col;
} 

function makeColRowPair (col, row) {
    return new ColRowPair (col, row);
}

function radius_with_blocks(center, radius, blocked) {
    var blocked_hex = []
    for (var i = 0; i < blocked.length; i++) {
        var hex = new THex(0,0,0);
        blocked_hex.push(hex.from_colrow(blocked.col, blocked.row));
    }
    
    var center_hex = (new THex(0,0,0)).from_colrow(center.col, center.row);
    var result_hex = center_hex.radius_with_blocks(radius, blocked_hex);
    
    var result = [];
    for (var j = 0; j < result_hex.length; j++) {
        result.push(makeColRowPair(result_hex[j].to_colrow()[0], result_hex[j].to_colrow()[1]));
    }
    return result;
}
