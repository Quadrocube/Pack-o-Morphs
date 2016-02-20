    CreatureType = {
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

    HexType = {
        CREATURE: 0,
        FOREST: 1,
        EMPTY: 2
    };
    
    function TGameLogic() {
        // return null if assertion failed, else true or result of engagement or whatever
        
        this.assert_can_attack = function(subj, obj) {
            // chk: there is enough MOV points left
            if (subj.creature.effects['drain'] >= subj.creature.MOV)
                return false;
            // chk: not Hidden
            if (obj.creature.type == CreatureType.RHINO) {
                obj.creature.init_effect('attacked');
                if (obj.creature.effects['attacked'] == 0) {
                    return false;
                }
            }
            // chk: distance
            var d = 1;
            if (subj.creature.type == CreatureType.WASP)
                d = 2;
            if (subj.creature.type == CreatureType.SPIDER)
                d = 3;
            return (rowcol2hex(subj.row, subj.col).distance(rowcol2hex(obj.row, obj.col)) <= d);
        };
        this.attack_landed = function(subj, obj) {
            var dF = subj.creature.ATT - obj.creature.DEF;
            var d2 = function() {
                var rand = 1 - 0.5 + Math.random() * 2
                rand = Math.round(rand);
                return rand - 1;
            }
            var actual_dice_result = parseInt(!(dF>=0));
            for (var i = 0; i < n; i++) {
                if (dF>=0)
                    actual_dice_result += d2();
                else
                    actual_dice_result *= d2();
            }
            return (actual_dice_result > 0);
        };
        this.chk_death = function(subj, obj) {
            if (obj.creature.effect['damage'] >= obj.creature.HPP) {
                // poisoned
                if (obj.creature.type != CreatureType.WASP) {
                    if (subj.creature.type != CreatureType.WASP && subj.creature.type != CreatureType.SPIDER) {
                        subj.creature.init_effect('damage');
                        subj.creature.effects['damage'] += 1;
                }
                
                if (this.chk_death(subj, obj)) 
                    return true;
                // TODO: subj player receives obj.creature.NUT points
                return true;
            }
            return false;
        }
        this.Attack = function(subj, obj) {
            // chk: attack is valid
            if (!this.assert_can_attack(subj)) {
                return false;
            }
            
            obj.creature.init_effect('attacked');
            obj.creature.effects['attacked'] = 1;
            
            // chk: attack lands
            if (this.attack_landed(subj, obj)) {
                obj.creature.init_effect('damage');
                subj.creature.init_effect('infest');
                obj.creature.effects['damage'] += subj.DAM - subj.creature.effect['infest'];
                subj.creature.effect['infest'] = 0;
                
                if (subj.creature.type == CreatureType.SPAWN) {
                    subj.creature.init_effect('damage');
                    subj.creature.effect['damage'] = Math.max(0, subj.creature.effect['damage'] - subj.creature.DAM);
                }
                
                if (subj.creature.type == CreatureType.DAEMON || subj.creature.type == CreatureType.SPIDER) {
                    obj.creature.init_effect('drain');
                    obj.creature.effects['drain'] = Math.max(obj.creature.effects['drain'] + 1, obj.creature.MOV);
                }
                
                if (subj.creature.type == CreatureType.DAEMON) {
                    if (obj.creature.type != CreatureType.WASP) {
                        obj.creature.init_effect('poison');
                        obj.creature.effect['poison'] += 1;
                    }
                }
                
                if (subj.creature.type == CreatureType.WASP) {
                    obj.creature.init_effect('infest');
                    obj.creature.effect['infest'] += 1;
                }
            }
            
            // chk: death
            this.chk_death(subj, obj);
            
            // regular drain
            subj.creature.init_effect('drain');
            subj.creature.effect['drain'] += 1;
            return true;
        };
        this.Move = function(subj, obj, d) {
            if (d === undefined)
                d = 2;
            if (subj.creature.type == CreatureType.SPAWN) {
                d *= 2;
            }
            user_d = rowcol2hex(subj.row, subj.col).distance(rowcol2hex(obj.row, obj.col));
            if (user_d > d) {
                return null;
            }
            return true;
        };
        
        this.RunHit = function(subj, obj_move, obj_hit) {
            return this.Move(subj, obj_move, 1) + this.Attack(subj, obj_hit)
        };
        this.Evolve = function(subj, type, additional_cost) {
            
        };
        this.Replicate = function(subj, additional_cost) {
              
        };
        this.Yield = function(subj, obj) {
        };
    };
    
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
