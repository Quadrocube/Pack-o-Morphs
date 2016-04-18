# Автор: Гусев Илья.
# Описание: Класс, содержащтй данные об объекте: тип, положение на сетке, текущий спрайт.
# DrawField даёт спрайту обратную ссылку на объект: sprite.object.

class window.FieldObject
	constructor: (@row, @col, @type, @isVisible, @creature) ->
		toSprites =
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
		@spriteTag = toSprites[@type]

	IsCreature: () ->
		@type not in ["EMPTY", "GRASS", "FOREST"]

	verbose: () ->
		if @IsCreature()
			return '#{@creature.verbose} at row #{@row} col #{@col}'
		return '#{@type} at row #{@row} col #{@col}'