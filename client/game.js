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
                    && posY < gridSizeY && posX <= columns[posY % 2] - 1;
        }
        
        this.ColRow2Ind = function(posX, posY) {
            return this.GetGridSizeX() * Math.floor(posY / 2) + 2 * posX + (posY%2);
        };

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
        
        this.GetCreatureActionFuncAndButton = function (creatureAction) {
            if (creatureAction === CreatureAction.FEED) {
                return ['feed', 'button_feed'];
            } else if (creatureAction === CreatureAction.MORPH) {
                return ['morph', 'button_morph'];
            } else if (creatureAction === CreatureAction.REPLICATE) {
                return ['replicate', 'button_replicate'];
            } else if (creatureAction === CreatureAction.SPEC_ABILITY) {
                return ['spec_ability', 'button_spec_ability'];
            } else if (creatureAction === CreatureAction.YIELD) {
                return ['yield', 'button_yield'];
            }
            return [];
        };
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
        this.hexagonGroup = Game.add.group();
        this.highlightGroup = Game.add.group();
        this.creatureGroup = Game.add.group();
        this.obstaclesGroup = Game.add.group();
        this.creatureGroup.inputEnabled = true;
        this.creatureGroup.input.enableDrag();
        
        this.InitGroup = function(groupName) {
            this[groupName].x = GameWorld.GetFieldX();
            this[groupName].y = GameWorld.GetFieldY();    
        };
        
        this.ResetGroup = function(groupName, fieldName) {
            this[groupName].destroy();
            this[groupName] = Game.add.group();
            this.InitGroup(groupName);
            if (fieldName) {
                delete this[fieldName];
                this[fieldName] = [];
            }
        };
        
        for (var groupName of ["hexagonGroup", "highlightGroup", "creatureGroup", "obstaclesGroup"]) {
            this.InitGroup(groupName);
        }
        
        this.hexField = [];
        this.creatureField = [];
		Game.stage.backgroundColor = "#ffffff";
        gengrid = function(hexGroup, spriteTag, visible) {
            var totalHexes = Math.floor(GameWorld.GetGridSizeX()/2) * GameWorld.GetGridSizeY();
            var hexes = new Array(totalHexes);
            var arrlen = 0;
            for (var i = 0; i < GameWorld.GetGridSizeY() / 2; i++) {
                for (var j = 0; j < GameWorld.GetGridSizeX(); j++) {
                    if (GameWorld.GetGridSizeY() % 2 === 0 
                            || i + 1 < GameWorld.GetGridSizeY() / 2 
                            || j % 2===0) {
                        var hexagonX = GameWorld.GetHexagonWidth() * j / 2;
                        var hexagonY = GameWorld.GetHexagonHeight() * i * 1.5
                            + (GameWorld.GetHexagonHeight() / 4 * 3) * (j % 2);	
                        var hexagon = Game.add.sprite(hexagonX,hexagonY,spriteTag);
                        hexes[arrlen++] = hexagon;
                        hexagon.visible = visible;
                        hexGroup.add(hexagon);
                    }
                }
            }
            return hexes;
        };
        gengrid(this.hexagonGroup, "hexagon", true);
        this.highHexes = gengrid(this.highlightGroup, "marker", false);
        this.lastHighlight = [];
        for (var _row = 0; _row < GameWorld.GetGridSizeY(); ++_row) {
            for (var _col = 0; _col < GameWorld.GetGridSizeX() / 2; ++_col) {
                this.hexField[_col+":"+_row] = {"row": _row, "col": _col, "objectType": HexType.EMPTY, "creature": null};
            }
        }

        this.Move = function(prevPos, newPos, fieldObject) {
            var units;
            if (prevPos) {
                units = this.creatureField[prevPos[0] + ":" + prevPos[1]];
                ind = units.indexOf(fieldObject);
                units.splice(ind, 1);
            }
            if (newPos) {
                var ind = newPos[0] + ":" + newPos[1];
                if (this.creatureField[ind] === undefined) {
                    this.creatureField[ind] = [];
                }
                units = this.creatureField[ind];
                units.push(fieldObject);
                units.sort((a, b) => {return a.objectType - b.objectType;});
            }
        };
        
        this.Remove = function(fieldObject) {
            fieldObject.marker.destroy();
            this.Move([fieldObject.col, fieldObject.row], null, fieldObject);
        };
        
        this.Add = function (fieldObject) {
            if (fieldObject.objectType == HexType.CREATURE) {
                this.creatureGroup.add(fieldObject.marker);
            } else {
                this.obstaclesGroup.add(fieldObject.marker);
            }
            this.Move(null, [0, 0], fieldObject);
        };

        this.GetCreaturesInRadius = function(posX, posY, rad) {
            var neighborHexes = radius_with_blocks(makeColRowPair(posX, posY), rad, []);
            var neighborCreatures = new Array(neighborHexes.length);
            var ncreatures = 0;
            for (var i = 0; i < neighborHexes.length; i++) {
                var x = neighborHexes[i].col;
                var y = neighborHexes[i].row;
                if (GameWorld.IsValidCoordinate(x, y)) {
                    var hex = this.GetAt(x, y);
                    if (hex.objectType === HexType.CREATURE) {
                        neighborCreatures[ncreatures++] = hex;
                    }
                }
            }
            neighborCreatures.splice(ncreatures, neighborHexes.length);
            return neighborCreatures;
        };

        this.Highlight = function(posX, posY, rad) {
            // add obstacles
            this.HighlightOff();
            this.lastHighlight = radius_with_blocks(makeColRowPair(posX, posY), rad, this.GetCreaturesInRadius(posX, posY, rad));
            for (var i = 0; i < this.lastHighlight.length; i++) {
                var x = this.lastHighlight[i].col;
                var y = this.lastHighlight[i].row;
                if (GameWorld.IsValidCoordinate(x, y)) {
                    this.highHexes[GameWorld.ColRow2Ind(x, y)].visible = true;
                }
            }
        };

        this.HighlightOff = function() {
            for (var i = 0; i < this.lastHighlight.length; ++i) {
                var x = this.lastHighlight[i].col;
                var y = this.lastHighlight[i].row;
                if (GameWorld.IsValidCoordinate(x, y)) {
                    this.highHexes[GameWorld.ColRow2Ind(x, y)].visible = false;
                }
                delete this.lastHighlight[i];
            }
            this.lastHighlight = [];
        };

        this.GetAt = function(posX, posY) {
            var key = posX + ":" + posY;
            var units = this.creatureField[key];
            if (units && units.length > 0) {
                return units[0];
            } else {
                return this.hexField[key];
            }
        };
        
        /* The main link between TGameLogic and other code.
            Returns true if everything is all right.
            Writes an error msg to console.
            MOVE:  
                subject is creature, object is hex
            ATTACK:
                subject and object are creatures
            MORPH or REPLICATE:
                subject is creature, args = [additional_cost: X]
            REFRESH:
                subject is creature
            YIELD:
                subject is creature, object is bush
            SPECIAL:
                args = ['carapace': true]
        */
        this.DoAction = function(subject, action, object, args) {
            if (action === ActionType.MOVE) {
                var response = (new TGameLogic()).Move(subject, object);
                if (response.error !== undefined) {
                    // something bad happened
                    console.log('ERROR in DoAction.MOVE: ' + response['error']);
                    return false;
                }
                return true;
            } else if (action === ActionType.ATTACK) {
                var response = TGameLogic.Attack(subject, object);
                if (response.error !== undefined) {
                    // something bad happened
                    console.log('ERROR in DoAction.ATTACK: ' + response['error']);
                    return false;
                }
                if (response.landed === true && response.death !== undefined) {
                    // attack landed
                    if (response.death.obj !== undefined) {
                        // obj is dead
                        if (response.death.subj !== undefined) {
                            // both are dead, nothing happens
                            // REMOVE both
                            return true;
                        }
                        // REMOVE obj
                        if (subject.creature.type !== CreatureType.WASP || subject.creature.type !== CreatureType.SPIDER) {
                            // GET nutrition
                        }
                        return true;
                    } 
                } 
                else if (response.landed === false) {
                    // attack missed
                    return true;
                } 
                console.log('ERROR in DoAction.ATTACK: Presentation error');
                return false;
            } else if (action === ActionType.RUNHIT) {
            } else if (action === ActionType.MORPH) {
                var response = TGameLogic.Morph(subject, args.additional_cost);
                if (response.error !== undefined) {
                    // something bad happened
                    console.log('ERROR in DoAction.MORPH: ' + response['error']);
                    return false;
                }
                // INIT morphing
                return true;
            } else if (action === ActionType.REPLICATE) {
                var response = TGameLogic.Morph(subject, args.additional_cost);
                if (response.error !== undefined) {
                    // something bad happened
                    console.log('ERROR in DoAction.REPLICATE: ' + response['error']);
                    return false;
                }
                // INIT replicating
                return true;
            } else if (action === ActionType.REFRESH) {
                // REFRESH subject creature
            } else if (action === ActionType.YIELD) {
                // SPEND nutrition
                // REFRESH subject creature
            } else if (action === ActionType.SPECIAL) {
                if (args.carapace !== undefined) {
                    if (subject.creature.effects['carapace'] !== undefined) {
                        return false;
                    }
                    subject.creature.effects['carapace'] = true;
                    return true;
                }
            } else {
                return false;
            }
        };
        
        this.getAllObjects = function() {
            var objects = [];
            for (var key in this.creatureField) {
                var objs = this.creatureField[key];
                for (var obj of objs) {
                    objects.push(obj);
                }
            }
            return objects;
        };
        
        this.Dump2JSON = function() {
            var jsonGameState = {};
            jsonGameState.objects = [];
            for (var obj of this.getAllObjects()) {
                jsonGameState.objects
                    .push({"s": obj.sprite_name, "t": obj.objectType, "c": obj.creature});
            }
            //jsonGameState.players = 
            return jsonGameState;
        };
        
        this.Load4JSON = function(jsonGameState) {
            this.ResetGroup("creatureGroup", "creatureField");
            this.ResetGroup("obstaclesGroup", null);
            for (var object of jsonGameState.objects) {
                new TFieldObject(object.s, object.t, object.c);
            }
            // jsonGameState.players...
        };
    }
        
    var HexagonField;

    function TTurnState() {
        var TS_NONE = 0;
        var TS_SELECTED = 1;
        var TS_ACTION = 2;
        
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
            if (state === TS_NONE || state === TS_SELECTED) {
                creature = field;
                state = TS_SELECTED;
            } else if (state === TS_ACTION) {
                endPosition = field;
                var result = HexagonField.DoAction(creature, action, endPosition);
                this.ResetState();
                return result;
            } else {
                assert(false, "WUT TurnState");
            }
            return true;
        };
        
        this.SelectAction = function (act) {
            if (state === TS_SELECTED) {
                action = act;
                state = TS_ACTION;
                return true;
            } else {
                this.ResetState();
                return false;
            }
        };
    }
    
    var TurnState = new TTurnState();
    
    // string, HexType, TCreature
    function TFieldObject(sprite_name, type, initCreature) {
        this.marker = Game.add.sprite(0,0,sprite_name);
        // row = y, col = x
        this.row = 0;
        this.col = 0;
        this.objectType = type;
        this.creature = initCreature; 
        
        if (this.objectType === HexType.CREATURE) {
           this.OnDragStart = function (sprite, pointer) {
                var hex = GameWorld.FindHex(); 
                if (TurnState.SelectField(HexagonField.GetAt(hex.x, hex.y)) === true) {
                    if (TurnState.SelectAction(ActionType.MOVE) === true) {
                        HexagonField.HighlightOff();
                        HexagonField.Highlight(this.col, this.row, 2);
                    }
                }
            };
            
            this.OnDragStop = function (sprite, pointer) {
                var hex = GameWorld.FindHex(); 
                if (!GameWorld.IsValidCoordinate(hex.x, hex.y)) { // out of field 
                   this.SetNewPosition(this.col, this.row); 
                   TurnState.ResetState();
                } else if (TurnState.SelectField(HexagonField.GetAt(hex.x, hex.y)) === true) {
                    this.SetNewPosition(hex.x, hex.y);    
                } else {
                   this.SetNewPosition(this.col, this.row);                     
                }
                
                HexagonField.HighlightOff();
            };
            
            this.marker.events.onDragStart.add(this.OnDragStart, this);
            this.marker.events.onDragStop.add(this.OnDragStop, this);
        }

		this.marker.anchor.setTo(0.5);
		this.marker.visible = false;
		HexagonField.Add(this);
        
        this.SetNewPosition = function (posX, posY) {
            HexagonField.Move([this.col, this.row], [posX, posY], this);
            this.row = posY;
            this.col = posX;
            if (!GameWorld.IsValidCoordinate(posX, posY)) {
                this.marker.visible = false;
		    } else {
                this.marker.visible = true;
                this.marker.x = GameWorld.GetHexagonWidth() * posX + GameWorld.GetHexagonWidth()/ 2 + (GameWorld.GetHexagonWidth() / 2) * (posY % 2);
				this.marker.y = 0.75 * GameWorld.GetHexagonHeight() * posY + GameWorld.GetHexagonHeight() / 2;
            }
            
            return this;
        };
        
        this.GetCreaturesInRadius = function (radius) {
            return HexagonField.GetCreaturesInRadius(this.col, this.row, radius);
        }
    }
	
    var Creature;
    
    var ActionBar = new TActionBar(Game, GameWorld, AlertManager, 128);
    
    var InfoBar = new TInfoBar(Game, GameWorld);
    
    function mouseDownCallback(e) {
        if (Game.input.mouse.button === Phaser.Mouse.LEFT_BUTTON) { //Left Click
            if (Game.input.y <= window.innerHeight - GameWorld.GetActionBarHeight()) { 
                var hex = GameWorld.FindHex(); 
                var activeField = HexagonField.GetAt(hex.x, hex.y);
                InfoBar.displayInfoCreature(activeField.creature);
                ActionBar.update(getCreatureActions(activeField.creature));
                var result = TurnState.SelectField(HexagonField.GetAt(hex.x, hex.y));
                assert(result, 'can not select');
                //Creature.SetNewPosition(hex.x, hex.y);
            } // else we click on the action bar
		} else {
			//Right Click	
		}    
    }
    
	function onPreload() {
		Game.load.image("hexagon", "arts/hexagon.png");
		Game.load.image("marker", "arts/marker.png");
        Game.load.image('button_feed', 'arts/button_feed.png');
        Game.load.image('button_morph', 'arts/button_morph.png');
        Game.load.image('button_replicate', 'arts/button_replicate.png');
        Game.load.image('button_spec_ability', 'arts/button_spec_ability.png');
        Game.load.image('button_yield', 'arts/button_yield.png');
	}
    
    function AlertManager (id) {
        alert('Clicked on ' + id);
    }

	function onCreate() {
        GameWorld.Init();
        
        HexagonField = new THexagonField();
        var RealCreature = new TCreature(CreatureType.VECTOR, 1, 2, 3, 4, 5, 6, null);
        Creature = new TFieldObject("marker", HexType.CREATURE, RealCreature);
        Creature.SetNewPosition(10, 11);
                        
        ActionBar.create([]);
        
        InfoBar.create("Hey you!\nHahahahahah!");
        
        InfoBar.displayInfoCreature(RealCreature);
        
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
