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

var HexType = {
    CREATURE: 0,
    GRASS: 1,
    FOREST: 2,
    EMPTY: 3
};

var ActionType = {
    MOVE: 0,
    ATTACK: 1,
    RUNHIT: 2,
    REPLICATE: 3,
    MORPH: 4,
    REFRESH: 5,
    YIELD: 6,
    SPECIAL: 7
}

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
        if (creature.effects !== undefined && creature.effects['carapace'] !== undefined)
            return [CreatureAction.FEED, CreatureAction.MORPH, CreatureAction.REPLICATE, CreatureAction.YIELD];
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
            CreatureAction.MORPH_SPAWN,
            CreatureAction.MORPH_DAEMON,
            CreatureAction.MORPH_TURTLE,
            CreatureAction.MORPH_RHINO,
            CreatureAction.MORPH_WASP,
            CreatureAction.MORPH_SPIDER,
            CreatureAction.MORPH_CANCEL];
}

function GetSpriteName(type, creature) {
    if (type === HexType.EMPTY) {
        return "hexagon";
    } else if (type === HexType.FOREST) {
        return "marker";
    } else if (type === HexType.GRASS) {
        return "marker";
    } else if (type === HexType.CREATURE) {
        assert(creature, "WUT creature");
        if (creature.type === CreatureType.COCOON) {
            return 'hex_cocoon';
        } else if (creature.type === CreatureType.PLANT) {
            return 'hex_plant';
        } else if (creature.type === CreatureType.DAEMON) {
            return 'hex_daemon';
        } else if (creature.type === CreatureType.RHINO) {
            assert(false, "gemme my sprite now!");
        } else if (creature.type === CreatureType.SPAWN) {
            return 'hex_spawn';
        } else if (creature.type === CreatureType.SPIDER) {
            assert(false, "gemme my sprite now!");
        } else if (creature.type === CreatureType.TURTLE) {
            return 'hex_turtle';
        } else if (creature.type === CreatureType.VECTOR) {
            return 'hex_vector';
        } else if (creature.type === CreatureType.WASP) {
            assert(false, "gemme my sprite now!");
        } else  {
            assert(false, "WUT creature type");
        }
    } else {
        assert(false, "WUT type");
    }
};

function GetCreatureActionFuncAndButton(creatureAction) {
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
    } else if (creatureAction === CreatureAction.MORPH_VECTOR) {
        return ['morph_vector', 'button_morph_vector'];
    } else if (creatureAction === CreatureAction.MORPH_PLANT) {
        return ['morph_plant', 'button_morph_plant'];
    } else if (creatureAction === CreatureAction.MORPH_SPAWN) {
        return ['morph_spawn', 'button_morph_spawn'];
    } else if (creatureAction === CreatureAction.MORPH_DAEMON) {
        return ['morph_daemon', 'button_morph_daemon'];
    } else if (creatureAction === CreatureAction.MORPH_TURTLE) {
        return ['morph_turtle', 'button_morph_turtle'];
    } else if (creatureAction === CreatureAction.MORPH_RHINO) {
        return ['morph_rhino', 'button_morph_rhino'];
    } else if (creatureAction === CreatureAction.MORPH_WASP) {
        return ['morph_wasp', 'button_morph_wasp'];
    } else if (creatureAction === CreatureAction.MORPH_SPIDER) {
        return ['morph_spider', 'button_morph_spider'];
    } else if (creatureAction === CreatureAction.MORPH_CANCEL) {
        return ['morph_cancel', 'button_morph_cancel'];
    }

    return [];
};