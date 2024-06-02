extends Node2D

class Tile:
	var x
	var y
	var topNeighbour = null
	var bottomNeighbour = null
	var leftNeighbour = null
	var rightNeighbour = null
	var rightWall
	var bottomWall
	var index
	func _init(xArg, yArg, indexArg, rightWallArg = true, bottomWallArg = true) -> void:
		self.x = xArg
		self.y = yArg
		self.index = indexArg
		self.rightWall = rightWallArg
		self.bottomWall = bottomWallArg

#This might not be understandable whatsoever I deeply apologize (it makes a maze using recursive backtracking)
func _ready():
	var tiles = []
	var index = 0
	for y in range(20, 600, 40):
		for x in range(20, 800, 40):
			var rightWall = !x == 780
			var bottomWall = !y == 580
			tiles.append(Tile.new(x, y, index, rightWall, bottomWall))
			index += 1
	for tile in tiles:
		if(tile.y != 20):
			tile.topNeighbour = tiles[tile.index-20]
		if(tile.y != 580):
			tile.bottomNeighbour = tiles[tile.index+20]
		if(tile.x != 20):
			tile.leftNeighbour = tiles[tile.index-1]
		if(tile.x != 780):
			tile.rightNeighbour = tiles[tile.index+1]

	var visitedTiles = [tiles[0]]
	var stack = [tiles[0]]
	var rng = RandomNumberGenerator.new()
	while len(visitedTiles) < 300:
		var tile = stack[-1]
		var generatedNumbers = []
		var neighbour = null
		var neighbourNumber = rng.randi_range(0, 3)
		while !neighbour:
			if(len(generatedNumbers) > 3):
				if(!tile in visitedTiles):
					visitedTiles.append(tile)
				stack.pop_back()
				break
			while(neighbourNumber in generatedNumbers):
				neighbourNumber = rng.randi_range(0, 3)
			match neighbourNumber:
				0:
					if(tile.topNeighbour != null and !tile.topNeighbour in visitedTiles):
						neighbour = tile.topNeighbour
					else:
						generatedNumbers.append(0)
				1:
					if(tile.bottomNeighbour and !tile.bottomNeighbour in visitedTiles):
						neighbour = tile.bottomNeighbour
					else:
						generatedNumbers.append(1)
				2:
					if(tile.leftNeighbour and !tile.leftNeighbour in visitedTiles):
						neighbour = tile.leftNeighbour
					else:
						generatedNumbers.append(2)
				3:
					if(tile.rightNeighbour and !tile.rightNeighbour in visitedTiles):
						neighbour = tile.rightNeighbour
					else:
						generatedNumbers.append(3)
		if(!neighbour):
			continue
		stack.append(neighbour)
		if(!tile in visitedTiles):
			visitedTiles.append(tile)
		match neighbourNumber:
			0:
				tiles[tile.index-20].bottomWall = false
			1:
				tile.bottomWall = false
			2:
				tiles[tile.index-1].rightWall = false
			3:
				tile.rightWall = false
				
	for tile in tiles:
		if(tile.rightWall):
			var line = Line2D.new()
			line.add_point(Vector2(tile.x+20, tile.y-20))
			line.add_point(Vector2(tile.x+20, tile.y+20))
			line.width = 3
			var shape = RectangleShape2D.new()
			shape.set_size(Vector2(3, 40))
			var collider = CollisionShape2D.new()
			collider.set_shape(shape)
			var staticbody = StaticBody2D.new()
			staticbody.add_child(collider)
			staticbody.set_position(Vector2(tile.x+20, tile.y))
			line.add_child(staticbody)
			$LineObject.add_child(line)
		if(tile.bottomWall):
			var line = Line2D.new()
			line.add_point(Vector2(tile.x-20, tile.y+20))
			line.add_point(Vector2(tile.x+20, tile.y+20))
			line.width = 3
			var shape = RectangleShape2D.new()
			shape.set_size(Vector2(40, 3))
			var collider = CollisionShape2D.new()
			collider.set_shape(shape)
			var staticbody = StaticBody2D.new()
			staticbody.add_child(collider)
			staticbody.set_position(Vector2(tile.x, tile.y+20))
			line.add_child(staticbody)
			$LineObject.add_child(line)
		$LineObject.modulate = Color(0.8, 0, 0, 1)

func pulseLines():
	var tween = create_tween()
	tween.tween_property($LineObject, "modulate", Color(0.8, 0, 0, 1), 1.6).set_trans(Tween.TRANS_LINEAR)
	await get_tree().create_timer(1.7).timeout
	tween = create_tween()
	tween.tween_property($LineObject, "modulate", Color(0.4, 0, 0, 1), 1.6).set_trans(Tween.TRANS_LINEAR)
	await get_tree().create_timer(3.5).timeout
	pulseLines()