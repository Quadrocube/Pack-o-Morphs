window.onload = function() {	
    var Game = new Phaser.Game("100%", "100%", Phaser.CANVAS, "", {preload: onPreload, create: onCreate});

    function TGameWorld() {
        var hexagonWidth = 35;
        var hexagonHeight = 40;
        var gridSizeX = 52;
        var gridSizeY = 26;
        var columns = [Math.ceil(gridSizeX / 2),Math.floor(gridSizeX / 2)];
        var sectorWidth = hexagonWidth;
        var sectorHeight = hexagonHeight / 4 * 3;
        var gradient = (hexagonHeight / 4) / (hexagonWidth / 2);
    
        this.GetHexagonWidth = function () {
            return hexagonWidth;
        };
    
        this.GetHexagonHeight = function () {
            return hexagonHeight;
        };
    
        this.GetGridSizeX = function () {
            return gridSizeX;
        };
    
        this.GetGridSizeY = function () {
            return gridSizeY;
        };
        
        this.GetColumns = function () {
            return columns;
        };
        
        this.GetSectorWidth = function () {
            return sectorWidth;
        };
        
        this.GetSectorHeight = function () {
            return sectorHeight;
        };
        
        this.GetGradient = function () {
            return gradient;
        };
        
        this.IsValidCoordinate = function (posX, posY) {
            return posX >= 0 && posY >= 0 
                    && posY <= gridSizeY && posX <= columns[posY % 2] - 1;
        }
    };
    
    var GameWorld = new TGameWorld();
    
    function THexagonField() {
        var hexagonGroup = Game.add.group();
		Game.stage.backgroundColor = "#ffffff";
	    for (var i = 0; i < GameWorld.GetGridSizeY() / 2; i++) {
			for (var j = 0; j < GameWorld.GetGridSizeX(); j++) {
				if (GameWorld.GetGridSizeY() % 2 == 0 
                    || i + 1 < GameWorld.GetGridSizeY() / 2 
                    || j % 2==0) {
					var hexagonX = GameWorld.GetHexagonWidth() * j / 2;
					var hexagonY = GameWorld.GetHexagonHeight() * i * 1.5
                                    + (GameWorld.GetHexagonHeight() / 4 * 3) * (j % 2);	
					var hexagon = Game.add.sprite(hexagonX,hexagonY,"hexagon");
					hexagonGroup.add(hexagon);
				}
			}
		}
        
		hexagonGroup.x = (Game.width - GameWorld.GetHexagonWidth() * Math.ceil(GameWorld.GetGridSizeX() / 2)) / 2;
       	if (GameWorld.GetGridSizeX() % 2 == 0) {
        	hexagonGroup.x -= GameWorld.GetHexagonWidth() / 4;
        }
       
		hexagonGroup.y = (Game.height - Math.ceil(GameWorld.GetGridSizeY() / 2) * GameWorld.GetHexagonHeight() - Math.floor(GameWorld.GetGridSizeY() / 2)*GameWorld.GetHexagonHeight()/2)/2;
        if (GameWorld.GetGridSizeY() % 2 == 0) {
        	hexagonGroup.y -= GameWorld.GetHexagonHeight() / 8;
        }
        
        this.Add = function (marker) {
            hexagonGroup.add(marker);
        }
        
        this.FindHex = function () {
            var candidateX = Math.floor((Game.input.worldX - hexagonGroup.x) / GameWorld.GetSectorWidth());
            var candidateY = Math.floor((Game.input.worldY-hexagonGroup.y) / GameWorld.GetSectorHeight());
            var deltaX = (Game.input.worldX-hexagonGroup.x) % GameWorld.GetSectorWidth();
            var deltaY = (Game.input.worldY-hexagonGroup.y) % GameWorld.GetSectorHeight(); 
            if(candidateY%2==0){
            	if(deltaY<((GameWorld.GetHexagonHeight()/4)-deltaX*GameWorld.GetGradient())){
                    candidateX--;
                    candidateY--;
                }
                if(deltaY<((-GameWorld.GetHexagonHeight()/4)+deltaX*GameWorld.GetGradient())){
                    candidateY--;
                }
            } else {
                if(deltaX>=GameWorld.GetHexagonWidth()/2){
                    if(deltaY<(GameWorld.GetHexagonHeight()/2-deltaX*GameWorld.GetGradient())){
                	   candidateY--;
                    }
                } else {
                    if(deltaY<deltaX*GameWorld.GetGradient()){
                	   candidateY--;
                    } else {
                       candidateX--;
                    }
                }
            }
            return {
                x: candidateX, 
                y: candidateY
            };
        }
    }
    
    var HexagonField;
    
    function TFieldObject(sprite_name) {
        var marker = Game.add.sprite(0,0,sprite_name);
		marker.anchor.setTo(0.5);
		marker.visible = false;
		HexagonField.Add(marker);
        
        this.SetNewPosition = function (posX, posY) {
            if (!GameWorld.IsValidCoordinate(posX, posY)) {
                marker.visible = false;
		    } else {
                marker.visible = true;
                marker.x = GameWorld.GetHexagonWidth() * posX;
                marker.y = GameWorld.GetHexagonHeight() / 4 * 3 * posY 
                            + GameWorld.GetHexagonHeight() / 2;
                if (posY % 2 == 0) {
                    marker.x += GameWorld.GetHexagonWidth() / 2;
                } else {
                    marker.x += GameWorld.GetHexagonWidth();
                }
            }
        };
    }
	
    var Marker;
    
    function mouseDownCallback(e) {
        if (Game.input.mouse.button == Phaser.Mouse.LEFT_BUTTON) { //Left Click
			var hex = HexagonField.FindHex(); 
			Marker.SetNewPosition(hex.x, hex.y); 
		} else {
			//Right Click	
		}    
    }
    
	function onPreload() {
		Game.load.image("hexagon", "arts/hexagon.png");
		Game.load.image("marker", "arts/marker.png");
	}

	function onCreate() {
        HexagonField = new THexagonField();
        Marker = new TFieldObject("marker");
        
        Game.input.mouse.mouseDownCallback = mouseDownCallback;
	}
}
