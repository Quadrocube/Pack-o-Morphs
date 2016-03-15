var StateType = {
    TS_NONE: 0,
    TS_SELECTED: 1,
    TS_ACTION: 2,
    TS_OPPONENT_MOVE: 3
};

function TTurnState(Game, GameWorld, GameLogic, HexagonField, ActionBar, StatInfoBar, Server, weStart) {
    this.state = StateType.TS_NONE;
    this.activeObject = undefined;
    this.action = undefined;
    this.endPosition = undefined;
    this.hexagonField = HexagonField;
    this.actionBar = ActionBar;
    this.statInfoBar = StatInfoBar;
    this.server = Server;
    this.game = Game;
    this.gameWorld = GameWorld;
    this.gameLogic = GameLogic;
    this.Init(weStart);
}

TTurnState.prototype = {
    Init : function (weStart) {
        this._ResetState();
        if (!weStart) {
            this._PassTurn(true);
        } else {
            this.UpdateStatInfo();
        }
    },
    
    UpdateStatInfo: function () {
        var creatures = this.hexagonField.GetMeOpponentCreatures();
        this.statInfoBar.displayStatInfo(this.hexagonField.GetMe().nutrition,
                                    this.hexagonField.GetOpp().nutrition,
                                    creatures.myCreatures.length,
                                    creatures.opponentCreatures.length);
    },

    _ResetState : function () {
        this.state = StateType.TS_NONE;
        this.activeObject = undefined;
        this.action = undefined;
        this.endPosition = undefined;
        this.actionBar.update([]);
    },

    _PassTurn : function(dontSend) {
        this._ResetState();
        this.state = StateType.TS_OPPONENT_MOVE;
        this.actionBar.lock();
        this.UpdateStatInfo();
        this.hexagonField.ToggleDraggable();
        if (dontSend === true) {
            // I hate js handling of undefined, null and stuff
        } else {
            this.server.Send('new-turn', this.hexagonField.Dump2JSON());
        }
    },

    _CancelMove : function () {
        if (this.activeObject != null) {
            this.state = StateType.TS_SELECTED;
        } else {
            this.state = StateType.TS_NONE;
        }
        this.action = undefined;
        this.endPosition = undefined;
    },

    SelectField : function (field) {
        if (this.state === StateType.TS_OPPONENT_MOVE) {
            return false;
        }

        if (this.state === StateType.TS_NONE || this.state === StateType.TS_SELECTED) {
            this.activeObject = field;
            this.state = StateType.TS_SELECTED;
        } else if (this.state === StateType.TS_ACTION) {
            this.endPosition = field;
            var result = this.hexagonField.DoAction(this.activeObject, this.action, this.endPosition);
            if (result) {
                this._ResetState();
                this._PassTurn();
            } else {
                this._CancelMove();
            }
            return result;
        } else {
            assert(false, "WUT TurnState");
        }
        return true;
    },

    SelectAction : function (act) {
        if (this.state === StateType.TS_OPPONENT_MOVE) {
            return false;
        }
        if (this.state === StateType.TS_SELECTED) {
            this.action = act;
            this.state = StateType.TS_ACTION;
            return true;
        } else if (this.state === StateType.TS_ACTION) {
            this.action = act;
            return true;
        } else {
            this._ResetState();
            return false;
        }
    },

    MyTurn : function () {
        assert(this.state === StateType.TS_OPPONENT_MOVE, "MyTurn() called on my turn");
        this.hexagonField.ToggleDraggable();
        this.actionBar.unlock();
        this.actionBar.update([]);
        this._ResetState();

        var objects = this.hexagonField.GetAllObjects();
        for (var i in objects) {
            if (objects[i].objectType === HexType.CREATURE) {
                if (objects[i].creature.effects === undefined)
                    continue;

                // poison
                if (objects[i].creature.effects['poison'] !== undefined) {
                    objects[i].creature.init_effect('damage');
                    objects[i].creature.effects['damage'] += objects[i].effects['poison'];
                    objects[i].creature.effects['poison'] = undefined;
                }
                // carapace
                if (objects[i].creature.effects['carapace'] !== undefined) {
                    objects[i].creature.effects['carapace'] -= 1;
                    if (objects[i].creature.effects['carapace'] === 0) {
                        objects[i].creature.ATT += 2;
                        objects[i].creature.DEF -= 2;
                        objects[i].creature.effects['carapace'] = undefined;
                    }
                }
                // replicate & morph
                if (objects[i].creature.effects['morph'] !== undefined) {
                    objects[i].creature.effects['morph']['turns'] -= 1;
                    if (objects[i].creature.effects['morph']['turns'] === 0) {
                        // time to evolve!
                        if (objects[i].creature.effects['morph']['__replicate'] === true) {
                            // replicate
                            // remove cocoon
                            this.hexagonField.Remove(objects[i]);
                            // place first one
                            var creature = newCreature(objects[i].creature.effects['morph']['target'], objects[i].creature.player);
                            var fieldObject = new TFieldObject(this.game, this.gameWorld, this.hexagonField, HexType.CREATURE, creature, this);
                            fieldObject.SetNewPosition(objects[i].col, objects[i].row);
                            // find the right place for the second one
                            // forsake if too crowdy
                            var radius1 = radius_with_blocks(makeColRowPair(objects[i].col, objects[i].row), 1, []);
                            for (var j in radius1) {
                                if (this.hexagonField.GetAt(radius1[j].col, radius1[j].row).objectType === HexType.EMPTY) {
                                    var creature2 = newCreature(objects[i].creature.effects['morph']['target'], objects[i].creature.player);
                                    var fieldObject2 = new TFieldObject(this.game, this.gameWorld, this.hexagonField, HexType.CREATURE, creature2, this);
                                    fieldObject2.SetNewPosition(radius1[j].col, radius1[j].row);
                                    break;
                                }
                            }
                            // free
                            delete objects[i];
                        } else {
                            // morph
                            // remove cocoon
                            this.hexagonField.Remove(objects[i]);
                            // place first one
                            var creature = newCreature(objects[i].creature.effects['morph']['target'], objects[i].creature.player);
                            var fieldObject = new TFieldObject(this.game, this.gameWorld, this.hexagonField, HexType.CREATURE, creature, this);
                            fieldObject.SetNewPosition(objects[i].col, objects[i].row);
                            // free
                            delete objects[i];
                        }
                    }
                }

                // death?
                if (objects[i] !== undefined && this.gameLogic.chk_death(objects[i]) !== undefined) {
                    this.hexagonField.Remove(objects[i]);
                }
            }
        }

        // win?
    },
}