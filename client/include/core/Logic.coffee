class window.Logic
	constructor: (@grid) ->
		return
	
	rollAttack(att, def) ->
		d2 = () ->
            rand = 1 - 0.5 + Math.random() * 2
            rand = Math.round(rand);
            return rand - 1;
		stat = 0
		if att - def < 0
			stat = 1
		for i in [0..Math.abs(att - def)]
			if att - def >= 0
				stat += d2()
			else
				stat *= d2()
		return (stat > 0)
	
	Attack: (subject, object, check_distance = true) ->
		if not subject.creature?
			error: "Attack: subject not a creature"
			return 
		# ## check whether attack is valid
		# check: enough MOV points left
		if subject.creature.effects.drain >= subject.creature.MOV
			error: "Attack: subject #{subject.verbose()} completely drained"
			return
		# check for Hidden
		if "hidden" in object.creature.keywords and not object.creature.effects.attacked?
			error: "Attack: object is Hidden"
			return
		# check distance
		if not check_distance
			d = subject.creature.getAttRange()
			user_d = @grid.GetDistance subject.row, subject.col, object.row, object.col
			if user_d == 0
				error: "Attack: distance is 0"
				return
			if user_d > d
				error: "Attack: user_d #{user_d} > d #{d}"
				return

		# ## roll the dice
		# mark subject as attacked this turn
		subject.creature.effects.attacked = true
		
		landed = @rollAttack(subject.att, object.def)
		if not landed
			miss: true
			return
		
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
				subject.creature.effects.damage = max(0, subject.creature.effects.damage - damage)
		
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
		
		miss : false
		object_dead : object_dead
		subject_dead : subject_dead
	
	Move: (subject, hex) ->
		# ## checks whether move is valid
		# cocoons and plants
		if "immovable" in subject.creature.keywords
			error: "Move: subject #{subject.verbose()} immovable"
			return
		# check if drained
		if subject.creature.effects.drain >= subject.creature.mov
			error: "Move: subject #{subject.verbose()} completely drained"
			return
		# check distance
		d = subject.creature.getMoveRange()
		user_d = @grid.GetDistance subject.row, subject.col, hex.row, hex.col
		if user_d > d
			error: "Move: too far #{user_d} > #{d}"
			return
		if user_d == 0
			error: "Move: distance is 0"
			return
		if hex.objectType == HexType.CREATURE
			error: "Move: target hex blocked"
			return
		
		# ## all is ok 
		# regular drain
		subject.creature.effects.drain ?= 0
		subject.creature.effects.drain += 1
	
	RunHit: (subject, object) ->
		# check distance
		d = subject.creature.getAttRange()
		user_d = @grid.GetDistance subject.row, subject.col, object.row, object.col
		if user_d > d
			error: "RunHit: user_d #{user_d} > d #{d}"
			return 
		
		# okay, moving
		e = @Move(subject, @grid.NearestNeighbour(object, subject))
		if e.error?
			error: e.error
			return
		# moved ok, attacking
		return @Attack(subject, object, false)
		
	Morph: (subject) ->
		# nothing to check here yet
		return
		
	Yield: (subject) ->
		# check if drained
		if subject.creature.effects.drain >= subject.creature.mov
			error: "Yield: subject #{subject.verbose()} completely drained"
			return
		# refreshing!
		subject.creature.effects.drain ?= 0
		subject.creature.effects.drain -= 1
		if subject.creature.effects.drain <= 0
			delete subject.creature.effects.drain
	
	Special: (subject) ->
		if 'carapace' in subject.creature.keywords
			# check if drained
			if subject.creature.effects.drain >= subject.creature.mov
				error: "Special-carapace: subject #{subject.verbose()} completely drained"
				return
			if subject.creature.effects.carapace?
				error: 'Special-carapace: carapace already active'
				return
			subject.creature.effects.carapace = true
			subject.creature.att -= 2
			subject.creature.def += 2

		# regular drain
		subject.creature.effects.drain ?= 0
		subject.creature.effects.drain += 1
