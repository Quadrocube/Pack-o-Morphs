class window.Player
	constructor: (@nutrition, @id) ->
		return

window.StateType = {
	TS_NONE: 0,
	TS_SELECTED: 1,
	TS_ACTION: 2,
	TS_OPPONENT_MOVE: 3
};