clone = (obj) ->
	if not obj? or typeof obj isnt 'object'
		return obj
	newInstance = new obj.constructor()
	for key of obj
		newInstance[key] = clone obj[key]
	return newInstance

describe "Tests for Logic", () ->
	grid = new window.THexGrid(35, 20, 16)
	logic = new window.Logic(grid)
	creature = new window.Creature(4, 4, 4, 4, 4, 4, [])
	defaultSubject = new window.FieldObject(0, 0, "VECTOR", true, 0, creature)

	it "Attack : typo", () ->
		expect(logic.Attack({}, {}).error_code).toBe(100)

	it "Attack : regular", () ->
		subject = clone(defaultSubject)
		object = {row: 0, col: 1, creature: creature}
		e = logic.Attack(subject, object)
		expect(e.error_code).toBe(undefined)
		expect(e.subject.creature.effects.attacked).not.toBe(undefined)

	it "Attack : regular ranged", () ->
		subject = clone(defaultSubject)
		subject.creature.attack_range = 3
		object = {row: 0, col: 3, creature: creature}
		e = logic.Attack(subject, object)
		expect(e.error_code).toBe(undefined)

	it "Attack : drained", () ->
		subject = clone(defaultSubject)
		object = {row: 0, col: 1, creature: creature}
		subject.creature.effects = {drain: 4}
		e = logic.Attack(subject, object)
		expect(e.error_code).toBe(101)

	it "Attack : distance 0", () ->
		subject = {row: 1, col: 1, creature: creature}
		object = {row: 1, col: 1, creature: creature}
		e = logic.Attack(subject, object)
		expect(e.error_code).toBe(103)

	it "Attack : distance far", () ->
		subject = clone(defaultSubject)
		object = {row: 2, col: 2, creature: creature}
		e = logic.Attack(subject, object)
		expect(e.error_code).toBe(104)

	it "Move : typo", () ->
		expect(logic.Move({}, {}).error_code).toBe(100)

	it "Move : regular", () ->
		subject = clone(defaultSubject)
		object = {row: 0, col: 1, }
		e = logic.Move(subject, object)
		expect(e.error_code).toBe(undefined)

	it "Move : immovable", () ->
		subject = new window.FieldObject(0, 0, "VECTOR", true, 0, new window.Creature(4, 4, 4, 4, 4, 4, ["immovable"]))
		console.log(subject.creature.keywords)
		object = {row: 0, col: 1, }
		e = logic.Move(subject, object)
		expect(e.error_code).toBe(105)

	it "Move : drained", () ->
		subject = clone(defaultSubject)
		object = {row: 0, col: 1,}
		subject.creature.effects = {drain: 4}
		e = logic.Move(subject, object)
		expect(e.error_code).toBe(101)

	it "Move : distance 0", () ->
		subject = clone(defaultSubject)
		object = {row: 0, col: 0,}
		e = logic.Move(subject, object)
		expect(e.error_code).toBe(108)

	it "Move : distance far", () ->
		subject = clone(defaultSubject)
		object = {row: 2, col: 2,}
		e = logic.Move(subject, object)
		expect(e.error_code).toBe(107)

	it "Move : target hex blocked", () ->
		subject = clone(defaultSubject)
		object = {row: 0, col: 1, creature: creature}
		e = logic.Move(subject, object)
		expect(e.error_code).toBe(109)

	# sooqa can't test without HexGrid.NearestNeighbour method
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
		e = logic.Yield(subject, object)
		expect(e.error_code).toBe(100)
		subject = {}
		object = {row: 0, col: 1, type: 'grass' }
		e = logic.Yield(subject, object)
		expect(e.error_code).toBe(100)

	it "Yield : regular", () ->
		subject = clone(defaultSubject)
		object = {row: 0, col: 1, type: "grass" }
		e = logic.Yield(subject, object)
		expect(e.error_code).toBe(undefined)

	it "Yield : drained", () ->
		subject = clone(defaultSubject)
		object = {row: 0, col: 1, type: "grass"}
		subject.creature.effects = {drain: 4}
		e = logic.Move(subject, object)
		expect(e.error_code).toBe(101)


	it "Keywords : infest", () ->
		subject = {row: 0, col: 0, creature: new window.Creature(4, 1, 0, 4, 4, 4, ["infest"])}
		object = {row: 0, col: 1, creature: new window.Creature(4, 1, 0, 4, 4, 4, [])}
		e = logic.Attack(subject, object)
		expect(e.object.creature.effects.infest).toBe(1)
		e = logic.Attack(e.object, e.subject)
		expect(e.object.creature.effects.damage).toBe(0)

	it "Keywords : poisoned", () ->
		return

	it "Keywords : poison", () ->
		return

	it "Keywords : leech", () ->
		subject = {row: 0, col: 0, creature: new window.Creature(4, 1, 0, 4, 4, 4, [])}
		object = {row: 0, col: 1, creature: new window.Creature(4, 1, 0, 4, 4, 4, ["leech"])}
		e = logic.Attack(subject, object)
		expect(e.object.creature.effects.damage).toBe(1)
		e = logic.Attack(e.object, e.subject)
		expect(e.subject.creature.effects.damage).toBe(0)

	it "Keywords : hidden", () ->
		subject = {row: 0, col: 0, creature: new window.Creature(4, 1, 0, 4, 4, 4, [])}
		object = {row: 0, col: 1, creature: new window.Creature(4, 1, 0, 4, 4, 4, ["hidden"])}
		e = logic.Attack(subject, object)
		expect(e.error_code).toBe(102)
		object2 = {row: 0, col: 2, creature: new window.Creature(4, 1, 0, 4, 4, 4, [])}
		e = logic.Attack(object, object2)
		expect(e.subject).not.toBe(undefined)
		object = e.subject
		e = logic.Attack(subject, object)
		expect(e.error_code).toBe(undefined)

	it "Keywords : carapace", () ->
		att = 4
		def = 4
		subject = {row: 0, col: 0, creature: new window.Creature(att, 4, def, 4, 4, 4, ["carapace"])}
		e = logic.Special(subject)
		expect(e.error_code).toBe(undefined)
		expect(e.subject.creature.att).toBe(att - 2)
		expect(e.subject.creature.def).toBe(def + 2)
		expect(e.subject.creature.effects.carapace).not.toBe(undefined)

	it "Keywords : drain", () ->
		subject = {row: 0, col: 0, creature: new window.Creature(4, 4, 4, 4, 4, 4, ["drain"])}
		object = {row: 0, col: 1, creature: new window.Creature(4, 4, 0, 4, 4, 4, [])}
		e = logic.Attack(subject, object)
		expect(e.object.creature.effects.drain).toBe(1)

	return
