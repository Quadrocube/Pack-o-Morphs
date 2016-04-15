class window.Player
	constructor: (@nutrition, @id) ->
		return

class window.Keyword
	constructor: (@id, @args) ->
		return
	comparator: (kwd) => kwd.id 

class window.Creature
	constructor(@att, @dam, @def, @hpp, @nut, @mov, @keywords = []) ->
		@effects = []
		@player = null
		# non-essential information below
		@id = ""
	verbose () ->
		return "#{@id} of player #{@player}"
	
	getAttRange() ->
		return @attack_range
	getMoveRange() ->
		return @move_range