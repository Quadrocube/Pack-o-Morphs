class window.FieldObject
	constructor: (@row, @col, @type, @isVisible) ->
		Sprites =
			"EMPTY": "hexagon"
			"GRASS": "marker"
			"FOREST": "marker"
			"HIGHLIGHT": "marker"
			"VECTOR": "hex_vector"
			"COCOON": "hex_cocoon"
			"PLANT": "hex_plant"
			"SPAWN": "hex_spawn"
			"DAEMON": "hex_daemon"
			"TURTLE": "hex_turtle"
			"RHINO": "gemme my sprite now!"
			"WASP": "gemme my sprite now!"
			"SPIDER": "gemme my sprite now!"
		@spriteTag = Sprites[@type]
		if not (@spriteTag?)
			throw "Wrong type in FieldObject constructor"

	verbose: () ->
		if @type == FieldObjectType.CREATURE
			return '#{@creature.verbose} at row #{@row} col #{@col}'
		return '#{@type} at row #{@row} col #{@col}'

	IsCreature: () ->
		@type not in ["EMPTY", "GRASS", "FOREST"]