# Автор: Гусев Илья.
# Описание: Текущее состояние хода и игрока.

class window.Player
	constructor: (@nutrition, @id) ->
		return

class window.TurnState
	constructor: (order) ->
		initialNutrition = 15
		@clientPlayer = new window.Player(initialNutrition, order[0])
		@currentPlayerId = 0

	IsClientTurn: () ->
		return @currentPlayerId == @clientPlayer.id

	ChangeTurn: () ->
		@currentPlayerId = ( @currentPlayerId + 1 ) % 2
