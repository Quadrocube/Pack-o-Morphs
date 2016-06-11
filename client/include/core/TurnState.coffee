class window.TurnState
	constructor: (@players) ->
		@clientPlayer = @players[0]
		@currentPlayer = 0
