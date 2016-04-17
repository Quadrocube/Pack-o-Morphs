describe "Tests for Logic", () ->
	it "Attack : typo", () ->
		logic = new window.Logic(new window.THexGrid(1000, 800, 35, 20, 16))
		subject = {}
		object = {}
		e = logic.Attack(subject, object)
		expect(e.error_code).toBe(100)		
	it "Attack : regular", () ->
		logic = new window.Logic(new window.THexGrid(1000, 800, 35, 20, 16))
		subject = {row: 0, col: 0, creature: new window.Creature(4, 4, 4, 4, 4, 4, [])}
		subject.verbose = () ->
			return 'subject'
		object = {row: 0, col: 1, creature: new window.Creature(4, 4, 4, 4, 4, 4, [])}
		e = logic.Attack(subject, object)
		expect(e.error_code).toBe(undefined)
		expect(e.subject.creature.effects.attacked).not.toBe(undefined)
	it "Attack : regular ranged", () ->
		logic = new window.Logic(new window.THexGrid(1000, 800, 35, 20, 16))
		subject = {row: 0, col: 0, creature: new window.Creature(4, 4, 4, 4, 4, 4, [])}
		subject.verbose = () ->
			return 'subject'
		subject.creature.attack_range = 3
		object = {row: 0, col: 3, creature: new window.Creature(4, 4, 4, 4, 4, 4, [])}
		e = logic.Attack(subject, object)
		expect(e.error_code).toBe(undefined)
	it "Attack : drained", () ->
		logic = new window.Logic(new window.THexGrid(1000, 800, 35, 20, 16))
		subject = {row: 0, col: 0, creature: new window.Creature(4, 4, 4, 4, 4, 4, [])}
		subject.verbose = () ->
			return 'subject'
		object = {row: 0, col: 1, creature: new window.Creature(4, 4, 4, 4, 4, 4, [])}
		subject.creature.effects = {drain: 4}
		e = logic.Attack(subject, object)
		expect(e.error_code).toBe(101)
	it "Attack : distance 0", () ->
		logic = new window.Logic(new window.THexGrid(1000, 800, 35, 20, 16))
		subject = {row: 1, col: 1, creature: new window.Creature(4, 4, 4, 4, 4, 4, [])}
		subject.verbose = () ->
			return 'subject'
		object = {row: 1, col: 1, creature: new window.Creature(4, 4, 4, 4, 4, 4, [])}
		e = logic.Attack(subject, object)
		expect(e.error_code).toBe(103)
	it "Attack : distance far", () ->
		logic = new window.Logic(new window.THexGrid(1000, 800, 35, 20, 16))
		subject = {row: 0, col: 0, creature: new window.Creature(4, 4, 4, 4, 4, 4, [])}
		subject.verbose = () ->
			return 'subject'
		object = {row: 2, col: 2, creature: new window.Creature(4, 4, 4, 4, 4, 4, [])}
		e = logic.Attack(subject, object)
		expect(e.error_code).toBe(104)
	
	it "Move : typo", () ->
		logic = new window.Logic(new window.THexGrid(1000, 800, 35, 20, 16))
		subject = {}
		object = {}
		e = logic.Move(subject, object)
		expect(e.error_code).toBe(100)
	it "Move : regular", () ->
		logic = new window.Logic(new window.THexGrid(1000, 800, 35, 20, 16))
		subject = {row: 0, col: 0, creature: new window.Creature(4, 4, 4, 4, 4, 4, [])}
		subject.verbose = () ->
			return 'subject'
		object = {row: 0, col: 1, }
		e = logic.Move(subject, object)
		expect(e.error_code).toBe(undefined)
	it "Move : immovable", () ->
		logic = new window.Logic(new window.THexGrid(1000, 800, 35, 20, 16))
		subject = {row: 0, col: 0, creature: new window.Creature(4, 4, 4, 4, 4, 4, ["immovable"])}
		subject.verbose = () ->
			return 'subject'
		object = {row: 0, col: 1, }
		e = logic.Move(subject, object)
		expect(e.error_code).toBe(105)
	it "Move : drained", () ->
		logic = new window.Logic(new window.THexGrid(1000, 800, 35, 20, 16))
		subject = {row: 0, col: 0, creature: new window.Creature(4, 4, 4, 4, 4, 4, [])}
		subject.verbose = () ->
			return 'subject'
		object = {row: 0, col: 1,}
		subject.creature.effects = {drain: 4}
		e = logic.Move(subject, object)
		expect(e.error_code).toBe(101)
	it "Move : distance 0", () ->
		logic = new window.Logic(new window.THexGrid(1000, 800, 35, 20, 16))
		subject = {row: 0, col: 0, creature: new window.Creature(4, 4, 4, 4, 4, 4, [])}
		subject.verbose = () ->
			return 'subject'
		object = {row: 0, col: 0,}
		e = logic.Move(subject, object)
		expect(e.error_code).toBe(108)
	it "Move : distance far", () ->
		logic = new window.Logic(new window.THexGrid(1000, 800, 35, 20, 16))
		subject = {row: 0, col: 0, creature: new window.Creature(4, 4, 4, 4, 4, 4, [])}
		subject.verbose = () ->
			return 'subject'
		object = {row: 2, col: 2,}
		e = logic.Move(subject, object)
		expect(e.error_code).toBe(107)
	it "Move : target hex blocked", () ->
		logic = new window.Logic(new window.THexGrid(1000, 800, 35, 20, 16))
		subject = {row: 0, col: 0, creature: new window.Creature(4, 4, 4, 4, 4, 4, [])}
		subject.verbose = () ->
			return 'subject'
		object = {row: 0, col: 1, creature: new window.Creature(4, 4, 4, 4, 4, 4, [])}
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
		logic = new window.Logic(new window.THexGrid(1000, 800, 35, 20, 16))
		subject = {row: 0, col: 0, creature: new window.Creature(4, 4, 4, 4, 4, 4, [])}
		object = {}
		e = logic.Yield(subject, object)
		expect(e.error_code).toBe(100)

		subject = {}
		object = {row: 0, col: 1, type: 'grass' }
		e = logic.Yield(subject, object)
		expect(e.error_code).toBe(100)
	it "Yield : regular", () ->
		logic = new window.Logic(new window.THexGrid(1000, 800, 35, 20, 16))
		subject = {row: 0, col: 0, creature: new window.Creature(4, 4, 4, 4, 4, 4, [])}
		subject.verbose = () ->
			return 'subject'
		object = {row: 0, col: 1, type: "grass" }
		e = logic.Yield(subject, object)
		expect(e.error_code).toBe(undefined)
	it "Yield : drained", () ->
		logic = new window.Logic(new window.THexGrid(1000, 800, 35, 20, 16))
		subject = {row: 0, col: 0, creature: new window.Creature(4, 4, 4, 4, 4, 4, [])}
		subject.verbose = () ->
			return 'subject'
		object = {row: 0, col: 1, type: "grass"}
		subject.creature.effects = {drain: 4}
		e = logic.Move(subject, object)
		expect(e.error_code).toBe(101)
	
	
	it "Keywords : infest", () ->
		logic = new window.Logic(new window.THexGrid(1000, 800, 35, 20, 16))
		subject = {row: 0, col: 0, creature: new window.Creature(4, 1, 0, 4, 4, 4, ["infest"])}
		subject.verbose = () ->
			return 'subject'
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
		logic = new window.Logic(new window.THexGrid(1000, 800, 35, 20, 16))
		subject = {row: 0, col: 0, creature: new window.Creature(4, 1, 0, 4, 4, 4, [])}
		subject.verbose = () ->
			return 'subject'
		object = {row: 0, col: 1, creature: new window.Creature(4, 1, 0, 4, 4, 4, ["leech"])}
		e = logic.Attack(subject, object)
		expect(e.object.creature.effects.damage).toBe(1)
		e = logic.Attack(e.object, e.subject)
		expect(e.subject.creature.effects.damage).toBe(0)
	it "Keywords : hidden", () ->
		logic = new window.Logic(new window.THexGrid(1000, 800, 35, 20, 16))
		subject = {row: 0, col: 0, creature: new window.Creature(4, 1, 0, 4, 4, 4, [])}
		subject.verbose = () ->
			return 'subject'
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
		logic = new window.Logic(new window.THexGrid(1000, 800, 35, 20, 16))
		att = 4
		def = 4
		subject = {row: 0, col: 0, creature: new window.Creature(att, 4, def, 4, 4, 4, ["carapace"])}
		subject.verbose = () ->
			return 'subject'
		e = logic.Special(subject)
		expect(e.error_code).toBe(undefined)
		expect(e.subject.creature.att).toBe(att - 2)
		expect(e.subject.creature.def).toBe(def + 2)
		expect(e.subject.creature.effects.carapace).not.toBe(undefined)
	it "Keywords : drain", () ->
		logic = new window.Logic(new window.THexGrid(1000, 800, 35, 20, 16))
		subject = {row: 0, col: 0, creature: new window.Creature(4, 4, 4, 4, 4, 4, ["drain"])}
		subject.verbose = () ->
			return 'subject'
		object = {row: 0, col: 1, creature: new window.Creature(4, 4, 0, 4, 4, 4, [])}
		e = logic.Attack(subject, object)
		expect(e.object.creature.effects.drain).toBe(1)

	return
