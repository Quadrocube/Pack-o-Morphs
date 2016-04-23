clone = (obj) ->
	if not obj? or typeof obj isnt 'object'
		return obj
	newInstance = new obj.constructor()
	for key of obj
		newInstance[key] = clone obj[key]
	return newInstance

describe "Tests for Logic", () ->
	grid = new window.THexGrid(35, 20, 16)
	data = new window.FieldData(20, 16)
	Add = (fo) ->
		data.creatureField[fo.row][fo.col] = fo
		return
	Remove = (field, row, col) ->
		field[row][col] = undefined
		return
	draw = {Add: Add, Remove: Remove}
	logic = new window.Logic(grid, data, draw)
	creature = new window.Creature(4, 4, 4, 4, 4, 4, [])
	defaultSubject = new window.FieldObject(0, 0, "VECTOR", true, 0, creature)
	defaultObject  = new window.FieldObject(0, 1, "VECTOR", true, 0, creature)
	
	it "Attack : typo", () ->
		expect( =>logic.Attack({}, {})).toThrowError(/not a creature/)

	it "Attack : regular", () ->
		subject = clone(defaultSubject)
		object = clone(defaultObject)
		expect( =>logic.Attack(subject, object)).not.toThrowError()
		expect(subject.creature.effects.attacked).not.toBe(undefined)

	it "Attack : regular ranged", () ->
		subject = clone(defaultSubject)
		subject.creature.attack_range = 3
		object = clone(defaultObject)
		expect( =>logic.Attack(subject, object)).not.toThrowError()
		expect(subject.creature.effects.attacked).not.toBe(undefined)

	it "Attack : death", () ->
		subject = clone(defaultSubject)
		object = clone(defaultObject)
		object.creature.def = 0
		object.creature.hpp = 1 
		data.creatureField[object.row][object.col] = object
		expect(logic.Attack(subject, object).object_dead).toBe(true)

	it "Attack : drained", () ->
		subject = clone(defaultSubject)
		object = {row: 0, col: 1, creature: creature, IsCreature: () -> return true}
		subject.creature.effects = {drain: 4}
		expect( =>logic.Attack(subject, object)).toThrowError(/completely drained/)

	it "Attack : distance 0", () ->
		subject = {row: 1, col: 1, creature: creature, IsCreature: () -> return true}
		object = {row: 1, col: 1, creature: creature, IsCreature: () -> return true}
		expect( =>logic.Attack(subject, object)).toThrowError(/distance is 0/)

	it "Attack : distance far", () ->
		subject = clone(defaultSubject)
		object = {row: 2, col: 2, creature: creature, IsCreature: () -> return true}
		expect( =>logic.Attack(subject, object)).toThrowError(/> d/)

	it "Move : typo", () ->
		expect( =>logic.Move({}, {})).toThrowError(/not a creature/)

	it "Move : regular", () ->
		subject = clone(defaultSubject)
		object = {row: 0, col: 1, }
		expect( =>logic.Move(subject, object)).not.toThrowError()

	it "Move : immovable", () ->
		subject = clone(defaultSubject)
		subject.creature.keywords = ["immovable"]
		object = {row: 0, col: 1, }
		expect( =>logic.Move(subject, object)).toThrowError(/immovable/)

	it "Move : drained", () ->
		subject = clone(defaultSubject)
		object = {row: 0, col: 1,}
		subject.creature.effects = {drain: 4}
		expect( =>logic.Move(subject, object)).toThrowError(/completely drained/)

	it "Move : distance 0", () ->
		subject = clone(defaultSubject)
		object = {row: 0, col: 0,}
		expect( =>logic.Move(subject, object)).toThrowError(/distance is 0/)

	it "Move : distance far", () ->
		subject = clone(defaultSubject)
		object = {row: 2, col: 2,}
		expect( =>logic.Move(subject, object)).toThrowError(/too far/)

	it "Move : target hex blocked", () ->
		subject = clone(defaultSubject)
		object = clone(defaultObject)
		expect( =>logic.Move(subject, object)).toThrowError(/blocked/)

	# TODO: test
	it "RunHit : regular", () ->
		return
	it "RunHit : distance 0", () ->
		return
	it "RunHit : distance 100", () ->
		return
	it "RunHit : error in Move", () ->
		return
	it "RunHit : error in Attack", () ->
		return
	it "RunHit : drained", () ->
		return

	it "Yield : typo", () ->
		subject = clone(defaultSubject)
		object = {}
		expect( =>logic.Yield(subject, object)).toThrowError(/not a GRASS/)
		subject = {}
		object = {row: 0, col: 1, type: 'GRASS' }
		expect( =>logic.Yield(subject, object)).toThrowError(/not a creature/)

	it "Yield : regular", () ->
		subject = clone(defaultSubject)
		object = {row: 0, col: 1, type: "GRASS" }
		expect( =>logic.Yield(subject, object)).not.toThrowError()

	it "Yield : drained", () ->
		subject = clone(defaultSubject)
		object = {row: 0, col: 1, type: "GRASS"}
		subject.creature.effects = {drain: 4}
		expect( =>logic.Yield(subject, object)).toThrowError(/completely drained/)

	it "Keywords : infest", () ->
		subject = {row: 0, col: 0, creature: new window.Creature(4, 1, 0, 4, 4, 4, ["infest"]), IsCreature: () -> return true}
		object = {row: 0, col: 1, creature: new window.Creature(4, 1, 0, 4, 4, 4, []), IsCreature: () -> return true}
		logic.Attack(subject, object)
		expect(object.creature.effects.infest).toBe(1)
		logic.Attack(object, subject)
		expect(subject.creature.effects.damage).toBe(0)

	it "Keywords : poisoned", () ->
		return

	it "Keywords : poison", () ->
		return

	it "Keywords : leech", () ->
		subject = {row: 0, col: 0, creature: new window.Creature(4, 1, 0, 4, 4, 4, []), IsCreature: () -> return true}
		object = {row: 0, col: 1, creature: new window.Creature(4, 1, 0, 4, 4, 4, ["leech"]), IsCreature: () -> return true}
		logic.Attack(subject, object)
		expect(object.creature.effects.damage).toBe(1)
		logic.Attack(object, subject)
		expect(object.creature.effects.damage).toBe(0)

	it "Keywords : hidden", () ->
		subject = {row: 0, col: 0, creature: new window.Creature(4, 1, 0, 4, 4, 4, []), IsCreature: () -> return true}
		object = {row: 0, col: 1, creature: new window.Creature(4, 1, 0, 4, 4, 4, ["hidden"]), IsCreature: () -> return true}
		expect( =>logic.Attack(subject, object)).toThrowError(/is Hidden/)
		object2 = {row: 0, col: 2, creature: new window.Creature(4, 1, 0, 4, 4, 4, []), IsCreature: () -> return true}
		expect( =>logic.Attack(object, object2)).not.toThrowError()

	it "Keywords : drain", () ->
		subject = {row: 0, col: 0, creature: new window.Creature(4, 1, 4, 4, 4, 4, ["drain"]), IsCreature: () -> return true}
		object = {row: 0, col: 1, creature: new window.Creature(4, 1, 0, 4, 4, 4, []), IsCreature: () -> return true}
		logic.Attack(subject, object)
		expect(object.creature.effects.drain).toBe(1)

	it "Upkeep : not my turn", () ->
		logic.state = window.StateType.TS_NONE
		expect( =>logic.Upkeep()).toThrowError(/turn/)

	createFieldObject = (row, col, effects) ->
		creature = new window.Creature(4, 4, 4, 4, 4, 4, [])
		creature.effects = effects
		subject = new window.FieldObject(row, col, "VECTOR", true, 0, creature)
		return subject

	it "Upkeep : poison death", () ->
		logic.state = window.StateType.TS_OPPONENT_MOVE
		data.creatureField[0][0] = createFieldObject(0, 0, {poison: 10,})
		data.creatureField[3][4] = createFieldObject(3, 4, {poison: 10,})
		logic.Upkeep()
		expect(data.creatureField[0][0]).toBe(undefined)
		expect(data.creatureField[3][4]).toBe(undefined)

	it "Keywords : carapace", () ->
		att = 4
		def = 4
		subject = {row: 0, col: 0, creature: new window.Creature(att, 4, def, 4, 4, 4, ["carapace"]), IsCreature: () -> return true}
		expect( =>logic.Special(subject)).not.toThrowError()
		expect(subject.creature.att).toBe(att - 2)
		expect(subject.creature.def).toBe(def + 2)
		expect(subject.creature.effects.carapace).not.toBe(undefined)
		data.creatureField[0][0] = subject
		logic.Upkeep()
		expect(subject.creature.att).toBe(att)
		expect(subject.creature.def).toBe(def)

	it "Upkeep : replicate regular", () ->
		logic.state = window.StateType.TS_OPPONENT_MOVE
		data.creatureField[1][1] = createFieldObject(1, 1, {morph: 1, morph_type: "replicate", morph_target: "VECTOR", damage: 2})
		rad = grid.GetBlocksInRadius(1, 1, 1)[1][0]
		[row, col,] = [rad.row, rad.col]
		logic.Upkeep()
		expect(data.creatureField[1][1].type).toBe("VECTOR")
		expect(data.creatureField[row][col].type).toBe("VECTOR")

	it "Upkeep : evolve regular", () ->
		logic.state = window.StateType.TS_OPPONENT_MOVE
		data.creatureField[1][1] = createFieldObject(1, 1, {morph: 1, morph_type: "evolve", morph_target: "SPAWN", damage: 2})
		logic.Upkeep()
		expect(data.creatureField[1][1].type).toBe("SPAWN")

	return
