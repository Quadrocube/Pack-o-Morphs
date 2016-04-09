window.onload = function() {
    var Game = new Phaser.Game('100%', '100%', Phaser.CANVAS, '', {preload: onPreload, create: onCreate, update: onUpdate});
    function onPreload() {
        var images = {
            'bubble': 'arts/bubble.png',
            'hexagon': 'arts/hexagon.png',
            'hexagon_me': 'arts/hexagon_me.png',
            'hexagon_opponent': 'arts/hexagon_opponent.png',
            'marker': 'arts/marker.png',
            'button_morph_vector': 'arts/button_size/amoeba1.png',
            'button_morph_cocoon': 'arts/button_size/amoeba2.png',
            'button_morph_plant': 'arts/button_size/amoeba3.png',
            'button_morph_spawn': 'arts/button_size/amoeba4.png',
            'button_morph_daemon': 'arts/button_size/amoeba5.png',
            'button_morph_turtle': 'arts/button_size/amoeba6.png',
            'button_morph_rhino': 'arts/button_size/amoeba7.png',
            'button_morph_wasp': 'arts/button_size/amoeba8.png',
            'button_morph_spider': 'arts/button_size/amoeba9.png',
            'button_morph_cancel': 'arts/button_size/cancel.png',
            'hex_vector': 'arts/small/amoeba.png',
            'hex_cocoon': 'arts/small/amoeba2.png',
            'hex_plant': 'arts/small/amoeba3.png',
            'hex_spawn': 'arts/small/amoeba4.png',
            'hex_daemon': 'arts/small/amoeba5.png',
            'hex_turtle': 'arts/small/amoeba6.png',
        }
        var spritesheets = {
            'button_replicate': 'arts/buttons/button_replicate_spritesheet.png',
            'button_spec_ability': 'arts/buttons/button_spec_ability_spritesheet.png',
            'button_feed': 'arts/buttons/button_feed_spritesheet.png',
            'button_morph': 'arts/buttons/button_morph_spritesheet.png',
            'button_yield': 'arts/buttons/button_yield_spritesheet.png',
        }
        for (name in images)
            Game.load.image(name, images[name]);
        for (name in spritesheets)
            Game.load.spritesheet(name, spritesheets[name], 128, 128);
	};



	function genHex(Game, GameWorld, HexagonField, pos, hexType, creatureType, player, TurnState) {
        var creature = null;
        if (hexType === HexType.CREATURE) {
            if (player === undefined) {
                player = 2;
            }
            creature = newCreature(creatureType, player);
        };
        var hex = new TFieldObject(Game, GameWorld, HexagonField, hexType, creature, TurnState);
        hex.SetNewPosition(pos[0], pos[1]);
    };

    function InitBattleground(Game, GameWorld, HexagonField, TurnState) {
        var grass = [[17,12],[0,7],[1,8],[2,8],[2,7],[2,6],[1,6],[1,10],[0,11],[1,12],[2,12],[2,11],[2,10],
                     [13,11],[14,11],[15,10],[14,9],[13,9],[13,10],[13,7],[14,7],[15,6],[14,5],[13,5],[13,6]];
        var forest = [[1,8],[1,12],[14,12],[14,8]];
        var neutrals = [[6,8],[6,9],[7,9],[8,8],[7,7],[6,7],[6,11],[6,12],[6,13],[7,13],[8,12],[7,11]];
        var playerOne = [[7,0],[6,1],[7,2],[8,2],[8,1],[8,0]];
        var playerTwo = [[7,18],[6,17],[7,16],[8,16],[8,17],[8,18]];
        for (var pos of grass) {
            genHex(Game, GameWorld, HexagonField, pos, HexType.GRASS);
        }

        for (var pos of forest) {
            genHex(Game, GameWorld, HexagonField, pos, HexType.FOREST);
        }
        for (var pos of neutrals) {
            genHex(Game, GameWorld, HexagonField,  pos, HexType.CREATURE, CreatureType.VECTOR);
        }
        for (var pos of playerOne) {
            genHex(Game, GameWorld, HexagonField, pos, HexType.CREATURE, CreatureType.VECTOR, 0, TurnState);
        }
        for (var pos of playerTwo) {
            genHex(Game, GameWorld, HexagonField, pos, HexType.CREATURE, CreatureType.VECTOR, 1, TurnState);
        }
    };


	function TServer() {
        var socket = io.connect();
        var myserv = this;

        this.Send = function(mtype, mdata) {
            socket.emit(mtype, mdata);
        };

        socket.on('found-opp', function(data) {
            var order = data.order;
            InitGame(order, InitBattleground);
            Game.input.keyboard.onDownCallback = function(key) {
                if (key.keyCode == Phaser.Keyboard.SPACEBAR) {
                    myserv.Send('manual-field-send', HexagonField.Dump2JSON());
                }
            };
        });

        socket.on('disconnect', function() {
            loading('Sorry, your opponent has disconnected...', 'down');
            TurnState._PassTurn();
        });
        socket.on('new-turn', function(data) {
            assert(TurnState.state === StateType.TS_OPPONENT_MOVE, 'Received new-turn during my turn');
            HexagonField.Load4JSON(data);
            TurnState.MyTurn();
        });
    };


	function TServerMock() {
        this.Send = function(mtype, mdata) {
            return true;
        };

    };

	function onCreate() {
	    Game.stage.backgroundColor = '#B3E5FC';
        Game.world.setBounds(0, -50, Game.width, Game.height + 228); // constants should be fit for size of field that we need
        Game.camera.y += 60;

	    var GameLogic = new TGameLogic();
	    //var GameWorld = new TGameWorld(Game);
	    //var order = [0, 1];
        var HexagonField = new THexagonField(Game, GameLogic);

//        var ActionBar = new TActionBar(Game, GameWorld, undefined, 128);
//        var InfoBar = new TInfoBar(Game);
//        var StatInfoBar = new TStatInfoBar(Game);
//
//        InfoBar.create('');
//        StatInfoBar.create('');
//
//        var Server = new TServerMock();
//        var TurnState = new TTurnState(Game, GameWorld, GameLogic, HexagonField, ActionBar, StatInfoBar, Server, order[0] === 0);
//        ActionBar.callback = function(id) {
//            if (id === 'feed') {
//                if (HexagonField.DoAction(TurnState.activeObject, ActionType.REFRESH)) {
//                    TurnState._PassTurn();
//                }
//            } else if (id === 'morph') {
//                ActionBar.update(getMorphList());
//            } else if (id === 'replicate') {
//                if (HexagonField.DoAction(TurnState.activeObject, ActionType.REPLICATE, undefined, {'additional_cost': 0})) {
//                    TurnState._PassTurn();
//                }
//            } else if (id === 'yield') {
//                if (HexagonField.DoAction(TurnState.activeObject, ActionType.YIELD)) {
//                    TurnState._PassTurn();
//                }
//            } else if (id === 'spec_ability') {
//                if (!HexagonField.DoAction(TurnState.activeObject, ActionType.SPECIAL)) {
//                    console.log('spec ability is used already');
//                } else {
//                    TurnState._PassTurn();
//                }
//            } else if (id === 'morph_cancel') {
//                if (ActionBar.update(getCreatureActions(TurnState.activeObject.creature))) {
//                    TurnState._PassTurn();
//                }
//            } else if (id.substring(0, 6) == 'morph_') {
//                var target = id.substring(6);
//                if (HexagonField.DoAction(TurnState.activeObject, ActionType.MORPH, undefined, {'target': target, 'additional_cost': 0})) {
//                    ActionBar.update([]);
//                    TurnState._PassTurn();
//                }
//            } else {
//                console.log('ERROR: something other has been clickd, id=' + id);
//            }
//            //ActionBar.update(getCreatureActions(TurnState.activeObject.creature));
//        }
//
//        Game.input.keyboard.onDownCallback = function(key) {
//            if (key.keyCode === Phaser.Keyboard.ONE) {
//                TurnState.MyTurn();
//            }
//        };
//        InitBattleground(Game, GameWorld, HexagonField, TurnState);
//        Game.input.mouse.mouseDownCallback = function(e) {
//            if (Game.input.y <= window.innerHeight - GameWorld.actionBarHeight) {
//                var hex = GameWorld.FindHex();
//                var activeField = HexagonField.GetAt(hex.x, hex.y);
//                InfoBar.displayInfoCreature(activeField.creature);
//                if (activeField.objectType !== HexType.CREATURE ||
//                    activeField.creature.player !== HexagonField.PlayerId.ME) {
//                    ActionBar.update([]);
//                } else {
//                    ActionBar.update(getCreatureActions(activeField.creature));
//                }
//                TurnState.SelectField(HexagonField.GetAt(hex.x, hex.y));
//                    //Creature.SetNewPosition(hex.x, hex.y);
//            } else { // else we click on the action bar
//            }
//        }
	};

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
	};
};