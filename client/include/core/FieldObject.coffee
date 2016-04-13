class window.FieldObject
	constructor: (type, initCreature, sprite) ->
		@col = 0
		@row = 0
		@objectType = type
		@creature = initCreature
		@sprite = sprite
	colrow : () ->
		[@col, @row]
	