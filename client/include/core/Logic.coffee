class window.Logic
	constructor: (@grid, @data, @draw) ->
		# currentPlayer: if 0 then local, if > 0 is other
		@currentPlayer = 0
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

	# checks, whether a creature should be dead and performs necessary deletions
	# return true if fo is dead
	checkDeathCreature: (fo) ->
		# check typo
		if not fo.IsCreature()
			return false

		if fo.creature.effects.dead? or fo.creature.effects.damage >= fo.creature.hpp
			@draw.Remove(@data.creatureField, fo.row, fo.col)
			#@data.Remove(fo)
			return true
		return false
	
	Attack: (subject, object, check_distance = true) ->
		if not subject? or not subject.IsCreature? or not subject.IsCreature()
			throw new Error("Attack: subject not a creature")
		# ## check whether attack is valid
		# check: enough MOV points left
		if subject.creature.effects.drain? and subject.creature.effects.drain >= subject.creature.mov
			throw new Error("Attack: subject #{subject.Verbose()} completely drained")
		# check for Hidden
		if "hidden" in object.creature.keywords and not object.creature.effects.attacked?
			throw new Error("Attack: object is Hidden")
		# check distance
		if check_distance
			d = subject.creature.GetAttackRange()
			user_d = @grid.GetDistance subject.row, subject.col, object.row, object.col
			if user_d == 0
				throw new Error("Attack: distance is 0")
			if user_d > d
				throw new Error("Attack: user_d #{user_d} > d #{d}")

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
		# check for object's death
		object_dead = @checkDeathCreature(object)
		
		# apply poisoned
		if object_dead and "poisoned" in object.creature.keywords
			subject.creature.effects.damage ?= 0
			subject.creature.effects.damage += damage
		
		subject_dead = @checkDeathCreature(subject)
		
		# regular drain
		subject.creature.effects.drain ?= 0
		subject.creature.effects.drain += 1
		
		console.log("subject, object: #{subject_dead}, #{object_dead}")
		return {
			miss : false
			object_dead : object_dead
			subject_dead : subject_dead
		}

	Move: (subject, object) ->
		if not subject? or not subject.IsCreature? or not subject.IsCreature()
			throw new Error("Move: subject not a creature")
		if not object? or not object.col? or not object.row?
			throw new Error("Move: object haven't row & col fields")
		# ## checks whether move is valid
		# cocoons and plants
		if "immovable" in subject.creature.keywords
			throw new Error("Move: subject #{subject.Verbose()} immovable")
		# check if drained
		if subject.creature.effects.drain? and subject.creature.effects.drain >= subject.creature.mov
			throw new Error("Move: subject #{subject.Verbose()} completely drained")
		# check distance
		d = subject.creature.GetMoveRange()
		user_d = @grid.GetDistance subject.row, subject.col, object.row, object.col
		if user_d > d
			throw new Error("Move: too far #{user_d} > #{d}")
		if user_d == 0
			throw new Error("Move: distance is 0")
		if object.IsCreature? and object.IsCreature()
			throw new Error("Move: target hex blocked")
		
		# ## all is ok 
		# regular drain
		subject.creature.effects.drain ?= 0
		subject.creature.effects.drain += 1
		
		return
	
	RunHit: (subject, object) ->
		# check distance
		d = subject.creature.GetMoveRange()
		user_d = @grid.GetDistance(subject.row, subject.col, object.row, object.col)
		if user_d > d
			throw new Error("RunHit: user_d #{user_d} > d #{d}")
		
		# okay, moving
		try
			@Move(subject, @grid.NearestNeighbour(object, subject))
		catch e
			throw e
		# moved ok, attacking
		return @Attack(subject, object, false)
		
	Morph: (subject, object) ->
		# check typo
		if not subject.IsCreature()
			throw error_code: 100, error: "Morph: subject is not a creature"
		if not object.IsCreature()
			throw error_code: 115, error: "Morph: object is not a creature (prototype)" 
		# check if drained
		if subject.creature.effects.drain? and subject.creature.effects.drain >= subject.creature.mov
			throw error_code : 101, error: "Morph: subject #{subject.Verbose()} completely drained"

		# okay morphing
		
		return
		
	Yield: (subject, object) ->
		if not object? or not object.type? or object.type != 'GRASS'
			throw new Error("Yield: object not a GRASS")
		if not subject? or not subject.IsCreature? or not subject.IsCreature()
			throw new Error("Yield: subject not a creature")
		# check if drained
		if subject.creature.effects.drain? and subject.creature.effects.drain >= subject.creature.mov
			throw new Error("Yield: subject #{subject.Verbose()} completely drained")
		# refreshing!
		subject.creature.effects.drain ?= 0
		subject.creature.effects.drain -= 1
		if subject.creature.effects.drain <= 0
			delete subject.creature.effects.drain
		return 
		
	Special: (subject) ->
		if not subject? or not subject.IsCreature? or not subject.IsCreature()
			throw new Error("Special: subject is not a creature")
		if 'carapace' in subject.creature.keywords
			# check if drained
			if subject.creature.effects.drain? and subject.creature.effects.drain >= subject.creature.mov
				throw new Error("Special-carapace: subject #{subject.Verbose()} completely drained")
			if subject.creature.effects.carapace?
				throw new Error('Special-carapace: carapace already active')
			subject.creature.effects.carapace = true
			subject.creature.att -= 2
			subject.creature.def += 2

		# regular drain
		subject.creature.effects.drain ?= 0
		subject.creature.effects.drain += 1
		return

	Upkeep: () ->
		if @state != StateType.TS_OPPONENT_MOVE
			throw new Error("Upkeep: called on my turn")
		for fo_row in @data.creatureField
			for fo in fo_row
				if not fo?
					continue
				if not fo.creature?
					throw new Error("Upkeep: fo.creature is undefined")
				if not fo.creature.effects?
					continue

				# poison
				if fo.creature.effects.poison?
					fo.creature.effects.damage ?= 0
					fo.creature.effects.damage += fo.creature.effects.poison
					delete fo.creature.effects.poison
				
				@checkDeathCreature(fo)

				# carapace off
				if fo.creature.effects.carapace?
					fo.creature.att += 2
					fo.creature.def -= 2
					delete fo.creature.effects.carapace
				
				# replicate & morph
				if fo.creature.effects.morph?
					fo.creature.effects.morph -= 1
					if fo.creature.effects.morph == 0
						# time to evolve!
						if fo.creature.effects.morph_type == 'replicate'
							# create first one
							first = new window.FieldObject(fo.row, fo.col, fo.creature.effects.morph_target, true, fo.player)
							# create second one and find the right place for it
							# forsake if too crowdy :(
							second = new window.FieldObject(undefined, undefined, fo.creature.effects.morph_target, true, fo.player)
							radius = @grid.GetBlocksInRadius(fo.row, fo.col, 1)[1]
							for rc in radius
								[row, col] = [rc.row, rc.col]
								if @data.GetUpperObject(row, col).IsEmpty()
									second.row = row
									second.col = col
									break
							# remove cocoon
							fo.creature.effects.dead = true
							@checkDeathCreature(fo)
							# place new spawnlings on the field		
							@draw.Add(first)				
							if second.row? and second.col?
								@draw.Add(second)
						else if fo.creature.effects.morph_type == 'evolve'
							# create a evolved creature
							evolved = new window.FieldObject(fo.row, fo.col, fo.creature.effects.morph_target, true, fo.player)
							# remove cocoon
							fo.creature.effects.dead = true
							@checkDeathCreature(fo)
							# place new
							@draw.Add(evolved)
						else
							throw error_code: 153, error: "Upkeep: invalid morph_type = #{fo.creature.effects.morph_type}"
		return





	
	SelectAction: (subject, object) ->
		if @state == StateType.TS_OPPONENT_MOVE
			throw error_code: 150, error: "Opponent\'s move"

		if not object?
			@Special(subject)
			return "Special"

		d = @grid.GetDistance(subject.row, subject.col, object.row, object.col)
		if object.IsCreature()
			if d > subject.creature.GetAttackRange()
				@RunHit(subject, object)
				return "RunHit"
			@Attack(subject, object)
			return "Attack"
		
		if object.IsGrass()
			@Yield(subject, object)
			return "Yield"
		
		if object.IsEmpty() or object.IsForest()
			@Move(subject, object)
			return "Move"

		throw error_code: 151, error: "Unrecognized action"

		return ''


