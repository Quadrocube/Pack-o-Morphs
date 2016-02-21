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
    
    var CreatureAction = {
        FEED : 0,
        MORPH : 1,
        REPLICATE : 2,
        SPEC_ABILITY : 3,
        YIELD : 4,
        
        MORPH_VECTOR : 10,
        MORPH_COCOON : 11,
        MORPH_PLANT : 12,
        MORPH_SPAWN: 13,
        MORPH_DAEMON: 14,
        MORPH_TURTLE: 15,
        MORPH_RHINO: 16,
        MORPH_WASP: 17,
        MORPH_SPIDER: 18,
        MORPH_CANCEL: 19
    };
    
    function getCreatureActions(creature) {
        if (creature == null) {
            return [];
        }
        
        var creatureType = creature.type;
        if (creatureType === CreatureType.VECTOR) {
            return [CreatureAction.FEED, CreatureAction.MORPH, CreatureAction.REPLICATE, CreatureAction.YIELD];
        } else if (creatureType === CreatureType.COCOON) {
            return [];
        } else if (creatureType === CreatureType.PLANT) {
            return [];
        } else if (creatureType === CreatureType.SPAWN) {
            return [CreatureAction.FEED, CreatureAction.MORPH, CreatureAction.REPLICATE];
        } else if (creatureType === CreatureType.DAEMON) {
            return [CreatureAction.FEED, CreatureAction.MORPH, CreatureAction.REPLICATE];
        } else if (creatureType === CreatureType.TURTLE) {
            return [CreatureAction.FEED, CreatureAction.MORPH, CreatureAction.REPLICATE, CreatureAction.YIELD, CreatureAction.SPEC_ABILITY];
        } else if (creatureType === CreatureType.RHINO) {
            return [CreatureAction.FEED, CreatureAction.MORPH, CreatureAction.REPLICATE, CreatureAction.YIELD];
        } else if (creatureType === CreatureType.WASP) {
            return [CreatureAction.FEED, CreatureAction.MORPH, CreatureAction.REPLICATE, CreatureAction.YIELD];
        } else if (creatureType === CreatureType.SPIDER) {
            return [CreatureAction.FEED, CreatureAction.MORPH, CreatureAction.REPLICATE, CreatureAction.YIELD];
        }
        return [];
    };

    function getMorphList() {
        return [CreatureAction.MORPH_VECTOR, 
                CreatureAction.MORPH_PLANT, 
                CreatureAction.MORPH_SPAWN,
                CreatureAction.MORPH_DAEMON,
                CreatureAction.MORPH_TURTLE,
                CreatureAction.MORPH_RHINO,
                CreatureAction.MORPH_WASP,
                CreatureAction.MORPH_SPIDER,
                CreatureAction.MORPH_CANCEL];
    }

    var HexType = {
        CREATURE: 0,
        GRASS: 1,
        FOREST: 2,
        EMPTY: 3
    };
    
    function TGameLogic() {
        // return null if assertion failed, else true or result of engagement or whatever
        
        this.assert_can_attack = function(subj, obj) {
            // chk: there is enough MOV points left
            if (subj.creature.effects['drain'] >= subj.creature.MOV)
                return {'error': 'subject completely drained'};
            // chk: not Hidden
            if (obj.creature.type === CreatureType.RHINO) {
                obj.creature.init_effect('attacked');
                if (obj.creature.effects['attacked'] === 0) {
                    return {'error': 'object is Hidden'};
                }
            }
            // chk: distance
            var d = 1;
            var user_d = (new THex(0, 0, 0)).from_colrow(subj.col, subj.row).distance((new THex(0, 0, 0)).from_colrow(obj.col, obj.row));
            if (subj.creature.type === CreatureType.WASP)
                d = 2;
            if (subj.creature.type === CreatureType.SPIDER)
                d = 3;
            if (user_d <= d) 
                return {};
            else
                return {'error': 'distance is too great d=' + user_d + ' vs range=' + d };
        };
        this.attack_landed = function(subj, obj) {
            var dF = subj.creature.ATT - obj.creature.DEF;
            var d2 = function() {
                var rand = 1 - 0.5 + Math.random() * 2
                rand = Math.round(rand);
                return rand - 1;
            }
            var actual_dice_result;
            if (!(dF>=0))
                actual_dice_result = 1;
            else 
                actual_dice_result = 0;
            for (var i = 0; i < dF; i++) {
                if (dF>=0)
                    actual_dice_result += d2();
                else
                    actual_dice_result *= d2();
            }
            return (actual_dice_result > 0);
        };
        this.chk_death = function(creature) {
            console.log(creature);
            if (creature.creature.effects['damage'] >= creature.creature.HPP) {
                return {'dead': true};
            }
            return undefined;
        }
        /*
            returns:
                {'error': error}
                OR
                {'landed': ?att landed, 'death': death}
                    death is dict with:
                        'obj': 'dead' if obj is dead
                        'subj': 'dead' ...
        */
        // testing string:
        // subj = {row: 0, col: 0, creature: CreaturesExamples.SPIDER}; obj = {row: 0, col: 2, creature: CreaturesExamples.RHINO}; (new TGameLogic()).Attack(subj, obj);
        this.Attack = function(subj, obj) {
            // chk: attack is valid
            assert = this.assert_can_attack(subj, obj);
            if (assert.error !== undefined) {
                return {'error': assert.error};
            }
            
            subj.creature.init_effect('attacked');
            subj.creature.effects['attacked'] = 1;
            
            // chk: attack lands
            var landed = false;
            if (this.attack_landed(subj, obj)) {
                landed = true;
                
                obj.creature.init_effect('damage');
                subj.creature.init_effect('infest');
                obj.creature.effects['damage'] += subj.creature.DAM - subj.creature.effects['infest'];
                subj.creature.effects['infest'] = 0;
                
                if (subj.creature.type === CreatureType.SPAWN) {
                    subj.creature.init_effect('damage');
                    subj.creature.effects['damage'] = Math.max(0, subj.creature.effects['damage'] - subj.creature.DAM);
                }
                
                if (subj.creature.type === CreatureType.DAEMON || subj.creature.type === CreatureType.SPIDER) {
                    obj.creature.init_effect('drain');
                    obj.creature.effects['drain'] = Math.max(obj.creature.effects['drain'] + 1, obj.creature.MOV);
                }
                
                if (subj.creature.type === CreatureType.DAEMON) {
                    if (obj.creature.type != CreatureType.WASP) {
                        obj.creature.init_effect('poison');
                        obj.creature.effecs['poison'] += 1;
                    }
                }
                
                if (subj.creature.type === CreatureType.WASP) {
                    obj.creature.init_effect('infest');
                    obj.creature.effects['infest'] += 1;
                }
            }
            
            // chk: death
            var death_obj = this.chk_death(obj);
            var death_subj = undefined;
            if (death_obj !== undefined) {
                // poisoned
                if (obj.creature.type === CreatureType.WASP) {
                    if (subj.creature.type !== CreatureType.WASP && subj.creature.type !== CreatureType.SPIDER) {
                        subj.creature.init_effect('damage');
                        subj.creature.effects['damage'] += 1;
                    }
                    death_subj = this.chk_death(subj);
                }
            }
            var death = undefined;
            if (death_obj !== undefined) {
                death = {};
                death['obj'] = true;
            }
            if (death_subj !== undefined) {
                if (death === undefined)
                    death = {};
                death['subj'] = true;
            }
            // regular drain
            subj.creature.init_effect('drain');
            subj.creature.effects['drain'] += 1;
            console.log('---');
            console.log(subj);
            console.log(obj);
            console.log('---');
            return {'landed': landed, 'death': death};
        };
        /*
            returns:
                {'error': error}
                OR
                {}
        */
        this.Move = function(subj, obj) {
            var d = 2;
            if (subj.creature.type === CreatureType.SPAWN) {
                d *= 2;
            }
            var neigh = subj.GetCreaturesInRadius(1);
            for (var cr in neigh) {
                if (neigh[cr].creature.type === CreatureType.TURTLE) {
                    d = 1;
                }
            }
            var user_d = (new THex(0, 0, 0)).from_colrow(subj.col, subj.row).distance((new THex(0, 0, 0)).from_colrow(obj.col, obj.row));
            if (user_d > d) {
                return {'error': 'too far d=' + user_d + ' vs permitted=' + d};
            }
            if (user_d === 0) {
                return {'error': '0 movement'};
            }
            return {};
        };
        
        /*
            returns:
                {'error': error}
                OR
                see this.Attack
        */
        this.RunHit = function(subj, obj_move, obj_hit) {
            var d = this.Move(subj, obj_move, 1);
            if (d.error !== undefined)
                return d;
            return this.Attack(subj, obj_hit);
        };
        /*
            returns:
                {'error': error}
                OR
                {}
        */
        this.Morph = function(subj, additional_cost) {
            //if (subj.creature.player.NUT < 2 + additional_cost) {
            //    return {'error': 'not enough NUT'};
            //}
            return {};
        };
        /*
            returns {}
        */
        this.Yield = function(subj, obj) {
            return {};
        };
    };
    
    function TPlayer(id, _nut) {
        this.id = id;
        this.NUT = _nut;
        return this;
    };
    
    function TCreature(_type, _att, _def, _dam, _hpp, _mov, _nut) {
        this.type = _type;
        this.ATT = parseInt(_att);
        this.DEF = parseInt(_def);
        this.DAM = parseInt(_dam);
        this.HPP = parseInt(_hpp);
        this.MOV = parseInt(_mov);
        this.NUT = parseInt(_nut);
        
        this.effects = {};
        this.init_effect = function(effect_name) {
            if (this.effects === undefined) 
                this.effects = {};
            if (this.effects[effect_name] === undefined)
                this.effects[effect_name] = 0;
        };
        //return this;
    };
    
    var CreaturesExamples = {
        VECTOR: new TCreature(CreatureType.VECTOR, 3, 3, 2, 3, 6, 2),
        COCOON: new TCreature(CreatureType.COCOON, 0, 2, 0, 3, 0, 2),
        PLANT: new TCreature(CreatureType.PLANT, 0, 5, 0, 3, 0, 2),
        SPAWN: new TCreature(CreatureType.SPAWN, 5, 3, 3, 3, 5, 2),
        DAEMON: new TCreature(CreatureType.DAEMON, 6, 2, 4, 4, 5, 2),
        TURTLE: new TCreature(CreatureType.TURTLE, 4, 3, 3, 5, 3, 2),
        RHINO: new TCreature(CreatureType.RHINO, 2, 3, 3, 7, 3, 3),
        WASP: new TCreature(CreatureType.WASP, 4, 4, 2, 4, 4, 2),
        SPIDER: new TCreature(CreatureType.SPIDER, 4, 4, 2, 4, 4, 2),
        ONEHIT: new TCreature(CreatureType.COCOON, 6, 0, 2, 1, 5, 1) 
    };
