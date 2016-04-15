class window.FieldObject
	constructor: (@row, @col, @type, @creature, @sprite) ->
	    return
	verbose: () ->
		if @type == FieldObjectType.CREATURE
			return '#{@creature.verbose} at row #{@row} col #{@col}'
		return '#{@type} at row #{@row} col #{@col}'