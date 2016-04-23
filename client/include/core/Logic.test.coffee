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
		expect( =>logic.Attack({}, {})).toThrowError(/not a creature/)

	it "Attack : regular", () ->
		subject = clone(defaultSubject)
		object = {row: 0, col: 1, creature: creature}
		expect( =>logic.Attack(subject, object)).not.toThrowError()
		expect(subject.creature.effects.attacked).not.toBe(undefined)

	it "Attack : regular ranged", () ->
		subject = clone(defaultSubject)
		subject.creature.attack_range = 3
		object = {row: 0, col: 3, creature: creature}
		expect( =>logic.Attack(subject, object)).not.toThrowError()
		expect(subject.creature.effects.attacked).not.toBe(undefined)

	it "Attack : drained", () ->
		subject = clone(defaultSubject)
		object = {row: 0, col: 1, creature: creature}
		subject.creature.effects = {drain: 4}
		expect( =>logic.Attack(subject, object)).toThrowError(/completely drained/)

	it "Attack : distance 0", () ->
		subject = {row: 1, col: 1, creature: creature}
		object = {row: 1, col: 1, creature: creature}
		expect( =>logic.Attack(subject, object)).toThrowError(/distance is 0/)

	it "Attack : distance far", () ->
		subject = clone(defaultSubject)
		object = {row: 2, col: 2, creature: creature}
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
		object = {row: 0, col: 1, creature: creature}
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
		subject = {row: 0, col: 0, creature: new window.Creature(4, 1, 0, 4, 4, 4, ["infest"])}
		object = {row: 0, col: 1, creature: new window.Creature(4, 1, 0, 4, 4, 4, [])}
		logic.Attack(subject, object)
		expect(object.creature.effects.infest).toBe(1)
		logic.Attack(object, subject)
		expect(subject.creature.effects.damage).toBe(0)

	it "Keywords : poisoned", () ->
		return

	it "Keywords : poison", () ->
		return

	it "Keywords : leech", () ->
		subject = {row: 0, col: 0, creature: new window.Creature(4, 1, 0, 4, 4, 4, [])}
		object = {row: 0, col: 1, creature: new window.Creature(4, 1, 0, 4, 4, 4, ["leech"])}
		logic.Attack(subject, object)
		expect(object.creature.effects.damage).toBe(1)
		logic.Attack(object, subject)
		expect(object.creature.effects.damage).toBe(0)

	it "Keywords : hidden", () ->
		subject = {row: 0, col: 0, creature: new window.Creature(4, 1, 0, 4, 4, 4, [])}
		object = {row: 0, col: 1, creature: new window.Creature(4, 1, 0, 4, 4, 4, ["hidden"])}
		expect( =>logic.Attack(subject, object)).toThrowError(/is Hidden/)
		object2 = {row: 0, col: 2, creature: new window.Creature(4, 1, 0, 4, 4, 4, [])}
		expect( =>logic.Attack(object, object2)).not.toThrowError()

	it "Keywords : carapace", () ->
		att = 4
		def = 4
		subject = {row: 0, col: 0, creature: new window.Creature(att, 4, def, 4, 4, 4, ["carapace"])}
		expect( =>logic.Special(subject)).not.toThrowError()
		expect(subject.creature.att).toBe(att - 2)
		expect(subject.creature.def).toBe(def + 2)
		expect(subject.creature.effects.carapace).not.toBe(undefined)

	it "Keywords : drain", () ->
		subject = {row: 0, col: 0, creature: new window.Creature(4, 4, 4, 4, 4, 4, ["drain"])}
		object = {row: 0, col: 1, creature: new window.Creature(4, 4, 0, 4, 4, 4, [])}
		logic.Attack(subject, object)
		expect(object.creature.effects.drain).toBe(1)

	return
