class window.Logic
	constructor: (@grid) ->
		return
	
	d2: () ->
		if Math.random() > 0.5
			return 1
		return 0
		
	rollAttack: (att, def) ->
		if def == 0
			return true
		stat = 0
		if att - def < 0
			stat = 1
		for i in [0..Math.abs(att - def)]
			if att - def >= 0
				stat += @d2()
			else
				stat *= @d2()
		return (stat > 0)
	
	Attack: (subject, object, check_distance = true) ->
		if not subject.creature?
			throw error_code : 100, error: "Attack: subject not a creature"
		# ## check whether attack is valid
		# check: enough MOV points left
		if subject.creature.effects.drain? and subject.creature.effects.drain >= subject.creature.mov
			throw error_code : 101, error: "Attack: subject #{subject.Verbose()} completely drained"
		# check for Hidden
		if "hidden" in object.creature.keywords and not object.creature.effects.attacked?
			throw error_code : 102, error: "Attack: object is Hidden"
		# check distance
		if check_distance
			d = subject.creature.GetAttackRange()
			user_d = @grid.GetDistance subject.row, subject.col, object.row, object.col
			if user_d == 0
				throw error_code : 103, error: "Attack: distance is 0"
			if user_d > d
				throw error_code : 104, error: "Attack: user_d #{user_d} > d #{d}"

		# ## roll the dice
		# mark subject as attacked this turn
		subject.creature.effects.attacked = true
		
		landed = @rollAttack(subject.creature.att, object.creature.def)
		if not landed
			return {
				miss: true
			}
		
		# ## assign damage and effects
		# execute infest
		infest = 0
		if subject.creature.effects.infest?
			infest += subject.creature.effects.infest
			delete subject.creature.effects.infest

		# apply damage
		damage = subject.creature.dam - infest
		object.creature.effects.damage ?= 0
		object.creature.effects.damage += damage
		
		# leech
		if "leech" in subject.creature.keywords
			if subject.creature.effects.damage?
				subject.creature.effects.damage = Math.max(0, subject.creature.effects.damage - damage)
		
		# assign drain to object
		if "drain" in subject.creature.keywords
			object.creature.effects.drain ?= 0
			if object.creature.effects.drain + 1 <= object.creature.mov
				object.creature.effects.drain += 1
		
		# assign poison
		if "poison" in subject.creature.keywords and not "poisoned" in object.creature.keywords
			object.creature.effects.poison ?= 0
			object.creature.effects.poison += 1
		
		# assign infest
		if "infest" in subject.creature.keywords
			object.creature.effects.infest ?= 0
			object.creature.effects.infest += 1
		
		# ## aftermath
		# check for object"s death
		object_dead = (object.creature.effects.damage > object.creature.hpp)
		
		# apply poisoned
		if object_dead and "poisoned" in object.creature.keywords
			subject.creature.effects.damage ?= 0
			subject.creature.effects.damage += damage
		subject_dead = (subject.creature.effects.damage > subject.creature.hpp)
		
		# regular drain
		subject.creature.effects.drain ?= 0
		subject.creature.effects.drain += 1
		
		return {
			miss : false
			object_dead : object_dead
			subject_dead : subject_dead
		}

	Move: (subject, object) ->
		if not subject.creature?
			throw error_code : 100, error: "Move: subject not a creature" 
		# ## checks whether move is valid
		# cocoons and plants
		if "immovable" in subject.creature.keywords
			throw error_code : 105, error: "Move: subject #{subject.Verbose()} immovable"
		# check if drained
		if subject.creature.effects.drain? and subject.creature.effects.drain >= subject.creature.mov
			throw error_code : 101, error: "Move: subject #{subject.Verbose()} completely drained"
		# check distance
		d = subject.creature.GetMoveRange()
		user_d = @grid.GetDistance subject.row, subject.col, object.row, object.col
		if user_d > d
			throw error_code : 107, error: "Move: too far #{user_d} > #{d}"
		if user_d == 0
			throw error_code : 108, error: "Move: distance is 0"
		if object.creature?
			throw error_code : 109, error: "Move: target hex blocked"
		
		# ## all is ok 
		# regular drain
		subject.creature.effects.drain ?= 0
		subject.creature.effects.drain += 1
		
		return
	
	RunHit: (subject, object) ->
		# check distance
		d = subject.creature.GetMoveRange()
		user_d = @grid.GetDistance subject.row, subject.col, object.row, object.col
		if user_d > d
			throw error_code : 110, error: "RunHit: user_d #{user_d} > d #{d}"
		
		# okay, moving
		try
			@Move(subject, @grid.NearestNeighbour(object, subject))
		catch e
			throw error_code : 111, error: e.error
		# moved ok, attacking
		return @Attack(subject, object, false)
		
	Morph: (subject) ->
		# nothing to check here yet
		return
		
	Yield: (subject, object) ->
		if object.type != 'GRASS'
			# TODO: HexType enumerator in global
			throw error_code: 100, error: "Yield: object not a GRASS"
		if not subject.creature?
			throw error_code: 100, error: "Yield: subject not a creature"
		# check if drained
		if subject.creature.effects.drain? and subject.creature.effects.drain >= subject.creature.mov
			throw error_code : 101, error: "Yield: subject #{subject.Verbose()} completely drained"
		# refreshing!
		subject.creature.effects.drain ?= 0
		subject.creature.effects.drain -= 1
		if subject.creature.effects.drain <= 0
			delete subject.creature.effects.drain
		return 
		
	Special: (subject) ->
		if 'carapace' in subject.creature.keywords
			# check if drained
			if subject.creature.effects.drain? and subject.creature.effects.drain >= subject.creature.mov
				throw error_code : 113, error: "Special-carapace: subject #{subject.Verbose()} completely drained"
			if subject.creature.effects.carapace?
				throw error_code : 114, error: 'Special-carapace: carapace already active'
			subject.creature.effects.carapace = true
			subject.creature.att -= 2
			subject.creature.def += 2

		# regular drain
		subject.creature.effects.drain ?= 0
		subject.creature.effects.drain += 1
		
		return 
	
	SelectAction: (subject, object) ->
		if not object?
			@Special(subject)
			return 'Special'

		d = @grid.GetDistance subject.row, subject.col, object.row, object.col
		if object.IsCreature()
			if d > subject.creature.GetAttackRange()
				@RunHit(subject, object)
				return 'RunHit'
			@Attack(subject, object)
			return 'Attack'
		
		if object.type == 'GRASS'
			@Yield(subject, object)
			return 'Yield'
		
		if object.type == 'EMPTY'
			@Move(subject, object)
			return 'Move'


