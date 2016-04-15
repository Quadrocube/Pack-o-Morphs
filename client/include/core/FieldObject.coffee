class window.FieldObject
	constructor: (@type, @isVisible, @owner) ->
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

	IsCreature: () ->
		@type not in ["EMPTY", "GRASS", "FOREST"]

	ToogleVisibility: (value) ->
		@isVisible = value
		if @sprite?
			@sprite.visible = @isVisible
