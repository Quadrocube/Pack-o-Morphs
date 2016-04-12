function TPlayer(initNutrition, id) {
    this.nutrition = initNutrition;
    this.id = id;
};


function THexagonField(Game, GameLogic) {
    this.hexField = [];
    this.creatureField = [];
    this.lastHighlight = [];
    this.creaturesDraggable = true;
    this.game = Game;
    this.grid = new THexGrid(Game.width, Game.height, 35, 16, 20);
    this.gameLogic = GameLogic;
    this.Init();
}

THexagonField.prototype = {
    Init : function(){
        this.grid.Test();
        for (var groupName of ["hexagonGroup", "highlightGroup", "creatureGroup", "obstaclesGroup", "oppGroup"]) {
            this[groupName] = this.game.add.group();
            this.InitGroup(groupName);
        }
        this.GenerateGrid(this.hexagonGroup, "hexagon", true);
        this.highHexes = this.GenerateGrid(this.highlightGroup, "marker", false);
        for (var i = 0; i < this.grid.rowNum; ++i) {
            for (var j = 0; j < this.grid.colNum; ++j) {
                this.hexField[j+":"+i] = {"row": i, "col": j, "objectType": HexType.EMPTY, "creature": null};
            }
        }
        this.grid.GetBlocksInRadius({col: 2, row: 3}, 2);
    },

    InitGroup : function(groupName) {
        this[groupName].x = this.grid.leftBound;
        console.log(this.grid.upperBound)
        this[groupName].y = this.grid.upperBound;
    },

    ResetGroup : function(groupName, fieldName) {
        this[groupName].destroy();
        this[groupName] = Game.add.group();
        this.InitGroup(groupName);
        if (fieldName) {
            delete this[fieldName];
            this[fieldName] = [];
        }
    },

    GenerateGrid : function(hexGroup, spriteTag, visible) {
        var totalHexes = this.grid.rowNum * this.grid.colNum;
        var hexes = [];
        for (var i = 0; i < this.grid.rowNum; i++) {
            for (var j = 0; j < this.grid.colNum; j++) {
                var coord = this.grid.ColRowToXY(j, i);
                var hexagon = this.game.add.sprite(coord.x, coord.y, spriteTag);
                hexes.push(hexagon)
                hexagon.visible = visible;
                hexGroup.add(hexagon);
            }
        }
        return hexes;
    },

    ToggleDraggable : function() {
        for (var creatureSprite of this.creatureGroup.children) {
            if (this.creaturesDraggable) {
                creatureSprite.input.disableDrag();
            } else {
                creatureSprite.input.enableDrag();
            }
        }
        this.creaturesDraggable = !this.creaturesDraggable;
    },

    Move : function(prevPos, newPos, fieldObject) {
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
    },

    Remove : function(fieldObject) {
        fieldObject.marker.destroy();
        this.Move([fieldObject.col, fieldObject.row], null, fieldObject);
    },

    Add : function (fieldObject) {
        if (fieldObject.objectType == HexType.CREATURE) {
            assert(fieldObject.creature, "missing creature over here");
            if (fieldObject.creature.player === this.PlayerId.ME) {
                this.creatureGroup.add(fieldObject.marker);
            } else {
                this.oppGroup.add(fieldObject.marker);
            }
        } else {
            this.obstaclesGroup.add(fieldObject.marker);
        }
        this.Move(null, [0, 0], fieldObject);
    },

    GetCreaturesInRadius : function(posX, posY, rad) {
        var neighborHexes = radius_with_blocks(makeColRowPair(posX, posY), rad, []);
        var neighborCreatures = new Array(neighborHexes.length);
        var ncreatures = 0;
        for (var i = 0; i < neighborHexes.length; i++) {
            var x = neighborHexes[i].col;
            var y = neighborHexes[i].row;
            if (this.grid.IsValidCoordinate(x, y)) {
                var hex = this.GetAt(x, y);
                if (hex.objectType === HexType.CREATURE) {
                    neighborCreatures[ncreatures++] = hex;
                }
            }
        }
        neighborCreatures.splice(ncreatures, neighborHexes.length);
        return neighborCreatures;
    },

    Highlight : function(posX, posY, rad) {
        // add obstacles
        this.HighlightOff();
        this.lastHighlight = radius_with_blocks(makeColRowPair(posX, posY), rad, this.GetCreaturesInRadius(posX, posY, rad));
        for (var i = 0; i < this.lastHighlight.length; i++) {
            var x = this.lastHighlight[i].col;
            var y = this.lastHighlight[i].row;
            if (this.grid.IsValidCoordinate(x, y)) {
                this.highHexes[this.grid.ColRow2Ind(x, y)].visible = true;
            }
        }
    },

    HighlightOff : function() {
        for (var i = 0; i < this.lastHighlight.length; ++i) {
            var x = this.lastHighlight[i].col;
            var y = this.lastHighlight[i].row;
            if (this.grid.IsValidCoordinate(x, y)) {
                this.highHexes[this.grid.ColRow2Ind(x, y)].visible = false;
            }
            delete this.lastHighlight[i];
        }
        this.lastHighlight = [];
    },

    GetAt : function(posX, posY) {
        var key = posX + ":" + posY;
        var units = this.creatureField[key];
        if (units && units.length > 0) {
            return units[0];
        } else {
            return this.hexField[key];
        }
    },

    /* The main link between TGameLogic and other code.
        Returns true if everything is all right.
        Writes an error msg to console.
        MOVE:
            subject is creature, object is hex
        ATTACK:
            subject and object are creatures
        MORPH or REPLICATE:
            subject is creature, args = [target: creature, additional_cost: X]
        REFRESH:
            subject is creature, args = [additional_cost: X]
        YIELD:
            subject is creature, object is bush
        SPECIAL:
            subject is TURTLE :)
    */
    DoAction : function(subject, action, object, args) {
        var logic = this.gameLogic;
        //console.log(this.creatureField);
        if (action === ActionType.MOVE) {
            var response = logic.Move(subject, object);
            if (response !== undefined && response.error !== undefined) {
                // something bad happened
                console.log('ERROR in DoAction.MOVE: ' + response['error']);
                return false;
            }
            subject.SetNewPosition(object.col, object.row);
            return true;
        } else if (action === ActionType.ATTACK) {
            var response = logic.Attack(subject, object);
            if (response !== undefined && response.error !== undefined) {
                // something bad happened
                console.log('ERROR in DoAction.ATTACK: ' + response['error']);
                return false;
            }
            if (response === undefined || response['landed'] === undefined) {
                console.log('ERROR in DoAction.ATTACK: Presentation error');
                return false;
            }
            if (response['landed'] === true && response['death'] !== undefined) {
                // attack landed
                if (response.death.obj !== undefined) {
                    // obj is dead
                    if (response.death.subj !== undefined) {
                        // both are dead, nothing happens
                        this.Remove(subject);
                        this.Remove(object);
                        return true;
                    }
                    this.Remove(object);
                    if (subject.creature.type !== CreatureType.WASP || subject.creature.type !== CreatureType.SPIDER) {
                        this.players[subject.creature.player].nutrition += object.creature.NUT;
                    }
                    return true;
                }
            }
            // attack missed or damage not lethal
            return true;
        } else if (action === ActionType.RUNHIT) {
        } else if (action === ActionType.MORPH) {
            if (args === undefined || args.target === undefined || args.additional_cost === undefined) {
                console.log('ERROR in DoAction.MORPH: Presentation error');
                return false;
            }

            var response = logic.Morph(subject, args.additional_cost);
            if (response !== undefined && response.error !== undefined) {
                // something bad happened
                console.log('ERROR in DoAction.MORPH: ' + response['error']);
                return false;
            }
            if (this.players[subject.creature.player].nutrition <= 1) {
                console.log('Not enough nutrition, need 2 have ' + this.players[subject.creature.player].nutrition);
                return false;
            }
            var target;
            if (args.target === 'vector')
                target = CreatureType.VECTOR;
            else if (args.target === 'spawn')
                target = CreatureType.SPAWN;
            else if (args.target === 'daemon')
                target = CreatureType.DAEMON;
            else if (args.target === 'turtle')
                target = CreatureType.TURTLE;
            else if (args.target === 'rhino')
                target = CreatureType.RHINO;
            else if (args.target === 'wasp')
                target = CreatureType.WASP;
            else if (args.target === 'spider')
                target = CreatureType.SPIDER;
            this.Remove(subject);

            var creature = newCreature(CreatureType.COCOON, this.PlayerId.ME);
            creature.init_effect('morph');
            creature.effects['morph'] = {'target': target, 'turns': 3 - args.additional_cost};

            var fieldObject = new TFieldObject(this.game, this.grid, this, HexType.CREATURE, creature);
            fieldObject.SetNewPosition(subject.col, subject.row);
            delete subject;

            this.players[subject.creature.player].nutrition -= 2;
            return true;
        } else if (action === ActionType.REPLICATE) {
            if (args === undefined || args.additional_cost === undefined) {
                console.log('ERROR in DoAction.REPLICATE: Presentation error');
                return false;
            }
            var response = logic.Morph(subject, args.additional_cost);
            if (response !== undefined && response.error !== undefined) {
                // something bad happened
                console.log('ERROR in DoAction.REPLICATE: ' + response['error']);
                return false;
            }
            if (this.players[subject.creature.player].nutrition <= 1) {
                console.log('Not enough nutrition, need 2 have ' + this.players[subject.creature.player].nutrition);
                return false;
            }
            this.Remove(subject);
            var creature = newCreature(CreatureType.COCOON, this.PlayerId.ME);
            creature.init_effect('morph');
            creature.effects['morph'] = {'__replicate': true, 'target': subject.creature.type, 'turns': 3 - args.additional_cost};

            fieldObject = new TFieldObject(this.game, this.grid, this, HexType.CREATURE, creature);
            fieldObject.SetNewPosition(subject.col, subject.row);
            delete subject;

            this.players[subject.creature.player].nutrition -= 2;
            return true;
        } else if (action === ActionType.REFRESH) {
            if (true) {
                if (this.players[subject.creature.player].nutrition <= 0) {
                    console.log('Not enough nutrition, need 1 have ' + this.players[subject.creature.player].nutrition);
                    return false;
                }
                subject.creature.Refresh();
                this.players[subject.creature.player].nutrition -= 1;
                return true;
            } else {
                return false;
            }
        } else if (action === ActionType.YIELD) {
            // ADD nutrition
            if (true) { // grass AVAILABLE
                return true;
            } else {
                return false;
            }
        } else if (action === ActionType.SPECIAL) {
            var response = logic.Special(subject);
            if (response !== undefined && response['error'] !== undefined) {
                console.log('ERROR in DoAction.REPLICATE: ' + response['error']);
                return false;
            }
            return true;
        }
    },

    GetAllObjects : function() {
        var objects = [];
        for (var key in this.creatureField) {
            var objs = this.creatureField[key];
            for (var obj of objs) {
                objects.push(obj);
            }
        }
        return objects;
    },

    GetMeOpponentCreatures : function() {
        var myCreatures = [];
        var opponentCreatures = [];
        for (var key in this.creatureField) {
            var objs = this.creatureField[key];
            for (var obj of objs) {
                if (obj.objectType === HexType.CREATURE) {
                    if (obj.creature.player === this.PlayerId.ME) {
                        myCreatures.push(obj);
                    } else if (obj.creature.player === this.PlayerId.NOTME) {
                        opponentCreatures.push(obj);
                    }
                }
            }
        }

        return {
            myCreatures: myCreatures,
            opponentCreatures: opponentCreatures
        };
    },

    Dump2JSON : function() {
        var jsonGameState = {};
        jsonGameState.objects = [];
        for (var obj of this.GetAllObjects()) {
            jsonGameState.objects
                .push({"l": [obj.col, obj.row], "t": obj.objectType, "c": obj.creature});
        }
        jsonGameState.players = this.players;
        return jsonGameState;
    },

    Load4JSON : function(jsonGameState) {
        this.ResetGroup("creatureGroup", "creatureField");
        this.ResetGroup("obstaclesGroup", null);
        this.ResetGroup("oppGroup", null);
        for (var object of jsonGameState.objects) {
            var obj = new TFieldObject(this.game, this.grid, this, object.t, copyCreature(object.c));
            obj.SetNewPosition(object.l[0], object.l[1]);
        }
        this.players = jsonGameState.players;
    },
}