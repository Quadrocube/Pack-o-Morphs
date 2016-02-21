window.onload = function() {	
    var Game = new Phaser.Game("100%", "100%", Phaser.CANVAS, "", {preload: onPreload, create: onCreate, update: onUpdate});
    
    // test winbreaks
    
    

    function TGameWorld() {
        var hexagonWidth = 35;
        var hexagonHeight = 40;
        var gridSizeX = 52;
        var gridSizeY = 26;
        var columns = [Math.ceil(gridSizeX / 2),Math.floor(gridSizeX / 2)];
        var sectorWidth = hexagonWidth;
        var sectorHeight = hexagonHeight / 4 * 3;
        var gradient = (hexagonHeight / 4) / (hexagonWidth / 2);
        var gameLogic = new TGameLogic();
        
        var fieldPosX;
        var fieldPosY;
        
        var actionBarHeight = 128; // must be changed if buttons change
    
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
        
        this.GetFieldSizeX = function () {
            var sizeX = this.GetHexagonWidth() * Math.ceil(this.GetGridSizeX() / 2);
            if (this.GetGridSizeX() % 2 === 0) {
        	   sizeX += this.GetHexagonWidth() / 2;
            }
            return sizeX;
        };
        
        this.GetActionBarHeight = function () {
            return actionBarHeight;
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
        var highlightField = Game.add.group();
        var field = [];
		Game.stage.backgroundColor = "#ffffff";
        var gengrid = function(hexGroup, spriteTag) {
            for (var i = 0; i < GameWorld.GetGridSizeY() / 2; i++) {
                for (var j = 0; j < GameWorld.GetGridSizeX(); j++) {
                    if (GameWorld.GetGridSizeY() % 2 === 0 
                            || i + 1 < GameWorld.GetGridSizeY() / 2 
                            || j % 2===0) {
                        var hexagonX = GameWorld.GetHexagonWidth() * j / 2;
                        var hexagonY = GameWorld.GetHexagonHeight() * i * 1.5
                            + (GameWorld.GetHexagonHeight() / 4 * 3) * (j % 2);	
                        var hexagon = Game.add.sprite(hexagonX,hexagonY,spriteTag);
                        hexGroup.add(hexagon);
                    }
                }
            }

            hexGroup.x = GameWorld.GetFieldX();
            hexGroup.y = GameWorld.GetFieldY();
        }
        gengrid(hexagonField, "hexagon");
        gengrid(highlightField, "marker");

        this.Move = function(prevPos, newPos, fieldObject) {
            var units;
            if (prevPos) {
                units = field[prevPos[0] + ":" + prevPos[1]];
                ind = units.indexOf(fieldObject);
                units.splice(ind, 1);
            } 
            var ind = newPos[0] + ":" + newPos[1];
            if (field[ind] === undefined) {
                field[ind] = [];
            }
            units = field[ind]
            units.push(fieldObject);
            units.sort((a, b) => {return a.objectType - b.objectType;});
        };
        
        this.Add = function (fieldObject) {
            hexagonField.add(fieldObject);
            //this.Move(null, [0, 0], fieldObject);
        };

        this.Highlight = function(posX, posY, rad) {
        };

        this.HighlightOff = function() {
        };

        this.GetAt = function(posX, posY) {
            var units = field[posX + ":" + posY];
            if (units && units.length > 0) {
                return units[0];
            }
            return null;
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
                
                var result = HexagonField.DoAction(creature, action, endPosition);
                this.ResetState();
                return result;
            } else {
                this.ResetState();
            }
            
            return true;
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

    function TCreature(_type, _mov, _hpp) {
        var type = _type;
        var MOV = _mov;
        var HPP = _hpp;
        
        var abilities = MySet();
        var effects = {};
        
        this.init_effect = function(effect_name) {
            if (obj.effects.damage === undefined)
                obj.effects.damage = 0;
        };
    };
    
    // string, HexType, TCreature
    function TFieldObject(sprite_name, type, initCreature) {
        var marker = Game.add.sprite(0,0,sprite_name);
        // row = y, col = x
        var row = 0;
        var col = 0;
        var objectType = type;
        var creature = initCreature; 
        
        if (objectType === HexType.CREATURE) {
            marker.inputEnabled = true;
            marker.input.enableDrag();
            
            this.OnDragStart = function (sprite, pointer) {
                HexagonField.HighlightOff();
                HexagonField.Highlight(col, row, 2);
            };
            
            this.OnDragStop = function (sprite, pointer) {
                var hex = GameWorld.FindHex(); 
                if (TurnState.SelectField(HexagonField.GetAt(hex.x, hex.y))) {
                    this.SetNewPosition(hex.x, hex.y);    
                } else {
                    this.SetNewPosition(col, row);
                }
                
                HexagonField.HighlightOff();
            };
            
            marker.events.onDragStart.add(this.OnDragStart, this);
            marker.events.onDragStop.add(this.OnDragStop, this);
        }

		marker.anchor.setTo(0.5);
		marker.visible = false;
		HexagonField.Add(marker);
        
        this.SetNewPosition = function (posX, posY) {
            //field.Move([col, row], [posY, posX], this);
            row = posY;
            col = posX;
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
    var Creature;
    
    function mouseDownCallback(e) {
        if (Game.input.mouse.button === Phaser.Mouse.LEFT_BUTTON) { //Left Click
            if (Game.input.y <= window.innerHeight - GameWorld.GetActionBarHeight()) { 
                var hex = GameWorld.FindHex(); 
                var result = TurnState.SelectField(HexagonField.GetAt(hex.x, hex.y));
                assert(result);
                Marker.SetNewPosition(hex.x, hex.y);
            } // else we click on the action bar
		} else {
			//Right Click	
		}    
    }
    
	function onPreload() {
		Game.load.image("hexagon", "arts/hexagon.png");
		Game.load.image("marker", "arts/marker.png");
        Game.load.image('button1', 'arts/ab-button.png');
        Game.load.image('button2', 'arts/ab-button2.png');
        Game.load.image('button3', 'arts/ab-button3.png');

	}

    var ActionBar = new TActionBar(Game, GameWorld, AlertManager, 128);

    function AlertManager (id) {
        alert('Clicked on ' + id);
    }

	function onCreate() {
        GameWorld.Init();
        
        HexagonField = new THexagonField();
        Marker = new TFieldObject("marker", HexType.EMPTY, null);
        Creature = new TFieldObject("marker", HexType.CREATURE, null);
        Creature.SetNewPosition(10, 11);
                        
        ActionBar.create([['first','button1'], ['second', 'button2'], ['third', 'button3']]);

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
