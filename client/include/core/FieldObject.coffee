# Автор: Гусев Илья.
# Описание: Класс, содержащтй данные об объекте: тип, положение на сетке, текущий спрайт.
# DrawField даёт спрайту обратную ссылку на объект: sprite.object.

class window.Creature
	constructor: (@att, @dam, @def, @hpp, @nut, @mov, @keywords = []) ->
		@effects = {}
		@attack_range = 1
		@move_range = 2

	GetAttackRange: () ->
		return @attack_range
	GetMoveRange: () ->
		return @move_range

class window.FieldObject
	constructor: (@row, @col, @type, @isVisible = true, @player = 0, @creature) ->
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

		if (not @creature?) and @IsCreature()
			toCreatures =
				"VECTOR": new window.Creature(3, 3, 2, 3, 6, 2)
				"COCOON": new window.Creature(0, 2, 0, 3, 0, 2)
				"PLANT": new window.Creature(0, 5, 0, 3, 0, 2)
				"SPAWN": new window.Creature(5, 3, 3, 3, 5, 2)
				"DAEMON": new window.Creature(6, 2, 4, 4, 5, 2)
				"TURTLE": new window.Creature(4, 3, 3, 5, 3, 2)
				"RHINO": new window.Creature(2, 3, 3, 7, 3, 3)
				"WASP": new window.Creature(4, 4, 2, 4, 4, 2)
				"SPIDER": new window.Creature(4, 4, 2, 4, 4, 2)
			@creature = toCreatures[@type]
		@isDraggable = @IsCreature()

	IsCreature: () ->
		@type not in ["EMPTY", "GRASS", "FOREST", "HIGHLIGHT"]
	IsForest: () ->
		@type == "FOREST"
	IsGrass: () ->
		@type == "GRASS"
	IsEmpty: () ->
		@type == "EMPTY"

	Verbose: () ->
		if @IsCreature()
			return "#{@type} #{@player} at row #{@row} col #{@col}"
		return "#{@type} at row #{@row} col #{@col}"
