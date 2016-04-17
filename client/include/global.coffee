class window.Player
	constructor: (@nutrition, @id) ->
		return

class window.Creature
	constructor: (@att, @dam, @def, @hpp, @nut, @mov, @keywords) ->
		@effects = {}
		@player = null
		@attack_range = 1
		@move_range = 2
		# non-essential information below
		@id = ""
	verbose:  () ->
		return "#{@id} of player #{@player}"
	
	getAttackRange: () ->
		return @attack_range
	getMoveRange: () ->
		return @move_range