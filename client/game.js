window.onload = function() {	
    var Game = new Phaser.Game("100%", "100%", Phaser.CANVAS, "", {preload: onPreload, create: onCreate, update: onUpdate});

    function TGameLogic() {
        // return null if assertion failed, else true or result of engagement or whatever
        this.Attack = function(subj, obj) {
            //assert(); // Distance is 1, etc...
        };
        this.Move = function(subj, obj) {
        };
    }

    function TGameWorld() {
        var hexagonWidth = 35;
        var hexagonHeight = 40;
        var gridSizeX = 52;
        var gridSizeY = 26;
        var columns = [Math.ceil(gridSizeX / 2),Math.floor(gridSizeX / 2)];
        var sectorWidth = hexagonWidth;
        var sectorHeight = hexagonHeight / 4 * 3;
        var gradient = (hexagonHeight / 4) / (hexagonWidth / 2);
        var gameLogic = TGameLogic();
        
        var fieldPosX;
        var fieldPosY;
    
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
        
        this.Init = function () {
        	Game.world.setBounds(-500, -500, 4000, 2000); // constants should be fit for size of field that we need

            fieldPosX = (Game.width - this.GetHexagonWidth() * Math.ceil(this.GetGridSizeX() / 2)) / 2;
       	    if (this.GetGridSizeX() % 2 === 0) {
        	   fieldPosX -= this.GetHexagonWidth() / 4;
            }
            
            fieldPosY = (Game.height - Math.ceil(this.GetGridSizeY() / 2) * this.GetHexagonHeight() - Math.floor(this.GetGridSizeY() / 2)*this.GetHexagonHeight()/2)/2;
            if (GameWorld.GetGridSizeY() % 2 === 0) {
        	   fieldPosY -= this.GetHexagonHeight() / 8;
            }
        }
        
        this.GetFieldX = function () {
            return fieldPosX;
        };
        
        this.GetFieldY = function () {
            return fieldPosY;
        };
        
        this.FindHex = function () {
            var candidateX = Math.floor((Game.input.worldX - this.GetFieldX()) / this.GetSectorWidth());
            var candidateY = Math.floor((Game.input.worldY- this.GetFieldY()) / this.GetSectorHeight());
            var deltaX = (Game.input.worldX - this.GetFieldX()) % this.GetSectorWidth();
            var deltaY = (Game.input.worldY - this.GetFieldY()) % this.GetSectorHeight(); 
            if(candidateY%2===0){
            	if (deltaY < ((this.GetHexagonHeight() / 4) - deltaX * this.GetGradient())){
                    candidateX--;
                    candidateY--;
                }
                if(deltaY < ((-this.GetHexagonHeight() / 4) + deltaX * this.GetGradient())){
                    candidateY--;
                }
            } else {
                if(deltaX >= this.GetHexagonWidth() / 2){
                    if(deltaY < (this.GetHexagonHeight() / 2 - deltaX * this.GetGradient())){
                	   candidateY--;
                    }
                } else {
                    if(deltaY < deltaX * this.GetGradient()){
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
    };
    
    var GameWorld = new TGameWorld();
    
    var ActionType = {
        MOVE : 0,
        ATTACK : 1,
        RUNHIT : 2,
        REPLICATE: 3,
        MORPH: 4,
        REFRESH: 5,
        YIELD: 6,
        SPECIAL: 7
    }

    function THexagonField() {
        var hexagonField = Game.add.group();
		Game.stage.backgroundColor = "#ffffff";
	    for (var i = 0; i < GameWorld.GetGridSizeY() / 2; i++) {
			for (var j = 0; j < GameWorld.GetGridSizeX(); j++) {
				if (GameWorld.GetGridSizeY() % 2 === 0 
                    || i + 1 < GameWorld.GetGridSizeY() / 2 
                    || j % 2===0) {
					var hexagonX = GameWorld.GetHexagonWidth() * j / 2;
					var hexagonY = GameWorld.GetHexagonHeight() * i * 1.5
                                    + (GameWorld.GetHexagonHeight() / 4 * 3) * (j % 2);	
					var hexagon = Game.add.sprite(hexagonX,hexagonY,"hexagon");
					hexagonField.add(hexagon);
				}
			}
		}
        
		hexagonField.x = GameWorld.GetFieldX();
		hexagonField.y = GameWorld.GetFieldY();
        
        this.Add = function (marker) {
            hexagonField.add(marker);
        }

        this.Highlight = function(hex, rad) {
        }

        this.HighlightOff = function() {
        };

        this.GetAt = function(posX, posY) {
        };

        this.DoAction = function(subject, action, object) {
            if (action === ActionType.MOVE) {
                assert(GameWorld.gameLogic.Move(subject, object), "Move failed");
            } else if (action === ActionType.ATTACK) {
                var damage = GameWorld.gameLogic.Attack(subject, object);
                assert(damage, "Attack failed");
            } else if (action === ActionType.RUNHIT) {
            } else if (action === ActionType.MORPH) {
            } else if (action === ActionType.REFRESH) {
            } else if (action === ActionType.YIELD) {
            } else if (action === ActionType.SPECIAL) {
            } else {
                assert(false, "Unknown ActionType");
            }
        };
    }
    
    var HexagonField;

    var CreatureType = {
        VECTOR : 0,
        COCOON : 1,
        PLANT : 2,
        SPAWN: 3,
        DAEMON: 4,
        TURTLE: 5,
        RHINO: 6,
        WASP: 7,
        SPIDER: 8
    };

    var HexType = {
        CREATURE: 0,
        FOREST: 1,
        EMPTY: 2
    };

    function TCreature(_type, _mov, _hpp) {
        var type = _type;
        var MOV = _mov;
        var HPP = _hpp;
    };
    
    // string, HexType, TCreature
    function TFieldObject(sprite_name, type, initCreature) {
        var marker = Game.add.sprite(0,0,sprite_name);
        // row = y, column = x
        var row = 0;
        var column = 0;
        var objectType = type;
        if (objectType === HexType.CREATURE)
        
        var creature = initCreature;
       

		marker.anchor.setTo(0.5);
		marker.visible = false;
		HexagonField.Add(marker);
        
        this.SetNewPosition = function (posX, posY) {
            row = posY;
            column = posX;
            if (!GameWorld.IsValidCoordinate(posX, posY)) {
                marker.visible = false;
		    } else {
                marker.visible = true;
                marker.x = GameWorld.GetHexagonWidth() * posX + GameWorld.GetHexagonWidth()/ 2 + (GameWorld.GetHexagonWidth() / 2) * (posY % 2);
				marker.y = 0.75 * GameWorld.GetHexagonHeight() * posY + GameWorld.GetHexagonHeight() / 2;
            }
        };
    }
	
    var Marker;
    
    function TTurnState() {
        var TS_NONE = 0;
        var TS_SELECTED = 1;
        var TS_ACTION = 2;
        var TS_DONE = 3;
        
        var state;
        var creature;
        var action;
        var endPosition;
        
        this.ResetState = function () {
            state = TS_NONE;
            creature = undefined;
            action = undefined;
            endPosition = undefined;
        };
        
        this.ResetState();
        
        this.SelectField = function (field) {
            if (state === TS_NONE) {
                creature = field;
                state = TS_SELECTED;
            } else if (state === TS_ACTION) {
                endPosition = field;
                state = TS_DONE;
                
                HexagonField.DoAction(creature, action, endPosition);
                this.ResetState();
            } else {
                this.ResetState();
            }
        };
        
        this.SelectAction = function (act) {
            if (state === TS_SELECTED) {
                action = act;
                state = TS_ACTION;
            } else {
                this.ResetState();
            }
        };
    }
    
    var TurnState = new TTurnState();
    
    function mouseDownCallback(e) {
        if (Game.input.mouse.button === Phaser.Mouse.LEFT_BUTTON) { //Left Click
			var hex = GameWorld.FindHex(); 
            TurnState.SelectField(HexagonField.GetAt(hex.x, hex.y));
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
        GameWorld.Init();
        
        HexagonField = new THexagonField();
        Marker = new TFieldObject("marker", HexType.EMPTY, null);
        
        Game.input.mouse.mouseDownCallback = mouseDownCallback;
	}
	
	function onUpdate() {
		var camSpeed = 4;
		
		if (Game.input.keyboard.isDown(Phaser.Keyboard.LEFT)) {
		    Game.camera.x -= camSpeed;
		} else if (Game.input.keyboard.isDown(Phaser.Keyboard.RIGHT)) {
		    Game.camera.x += camSpeed;
		}

		if (Game.input.keyboard.isDown(Phaser.Keyboard.UP)) {
		    Game.camera.y -= camSpeed;
		} else if (Game.input.keyboard.isDown(Phaser.Keyboard.DOWN)) {
		    Game.camera.y += camSpeed;
		}
	}
}
