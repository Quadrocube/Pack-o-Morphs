
StateType = {
	TS_NONE: 0,
	TS_SELECTED: 1,
	TS_ACTION: 2,
	TS_OPPONENT_MOVE: 3
};

class window.TurnState
	constructor: (@players) ->
		@clientPlayer = @players[0]
		@currentPlayer = 0
		@state = StateType.TS_NONE
		
