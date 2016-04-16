describe "Tests for Logic", () ->
    logic = new window.Logic(new window.THexGrid(1000, 800, 35, 20, 16))
	target = new window.Creature(4, 4, 4, 4, 4, 4, [])
	
	it "Logic.test : Attack : typo", () ->
		return
	it "Logic.test : Attack : regular", () ->
		return
	it "Logic.test : Attack : drained", () ->
		return
	it "Logic.test : Attack : distance 0", () ->
		return
	it "Logic.test : Attack : distance 100", () ->
		return
	
	it "Logic.test : Move : typo", () ->
		return
	it "Logic.test : Move : regular", () ->
		return
	it "Logic.test : Move : immovable", () ->
		return
	it "Logic.test : Move : drained", () ->
		return
	it "Logic.test : Move : distance 0", () ->
		return
	it "Logic.test : Move : distance 100", () ->
		return
	it "Logic.test : Move : target hex blocked", () ->
		return
		
	it "Logic.test : RunHit : regular", () ->
		return
	it "Logic.test : RunHit : distance 0", () ->
		return
	it "Logic.test : RunHit : distance 100", () ->
		return
	it "Logic.test : RunHit : error in Move", () ->
		return
	it "Logic.test : RunHit : error in Attack", () ->
		return
	it "Logic.test : RunHit : drained", () ->
		return
	
	it "Logic.test : Yield : regular", () ->
		return
	it "Logic.test : Yield : drained", () ->
		return

	it "Logic.test : Keywords : infest", () ->
		return
	it "Logic.test : Keywords : poisoned", () ->
		return
	it "Logic.test : Keywords : poison", () ->
		return
	it "Logic.test : Keywords : leech", () ->
		return
	it "Logic.test : Keywords : hidden", () ->
		return
	it "Logic.test : Keywords : carapace", () ->
		return
	it "Logic.test : Keywords : drain", () ->
		return

	return
