extends TileMap

@export var MAZE_WIDTH = 35
@export var MAZE_HEIGHT = 25
var WALL_TILE = Vector2(0, 2)
var FLOOR_TILE = Vector2(0, 0)
var EMPTY_TILE = Vector2(-1, -1)
var WALL_SOURCE_ID = 0

func _ready():
	for x in range(1, MAZE_WIDTH, 2):
		for y in range(MAZE_HEIGHT):
			set_cell(0, Vector2(x, y), WALL_SOURCE_ID, WALL_TILE)
	for y in range(1, MAZE_HEIGHT, 2):
		for x in range(MAZE_WIDTH):
			set_cell(0, Vector2(x, y), WALL_SOURCE_ID, WALL_TILE)
	
	for x in range(-2,MAZE_WIDTH+2):
		set_cell(0, Vector2(x, -1), WALL_SOURCE_ID, WALL_TILE)
		set_cell(0, Vector2(x, MAZE_HEIGHT), WALL_SOURCE_ID, WALL_TILE)

		set_cell(0, Vector2(x, -2), WALL_SOURCE_ID, WALL_TILE)
		set_cell(0, Vector2(x, MAZE_HEIGHT+1), WALL_SOURCE_ID, WALL_TILE)
	for y in range(MAZE_HEIGHT):
		set_cell(0, Vector2(-1, y), WALL_SOURCE_ID, WALL_TILE)
		set_cell(0, Vector2(MAZE_WIDTH, y), WALL_SOURCE_ID, WALL_TILE)

		set_cell(0, Vector2(-2, y), WALL_SOURCE_ID, WALL_TILE)
		set_cell(0, Vector2(MAZE_WIDTH+1, y), WALL_SOURCE_ID, WALL_TILE)
	var tileStack = [Vector2(0, 0)]
	while(len(tileStack) > 0):
		var tile = tileStack[-1]
		set_cell(0, tile, 1, FLOOR_TILE)
		var neighbours = getNeighbours(tile)#order is RIGHT, BOTTOM, LEFT, TOP
		while(len(neighbours) > 0):
			var neighbour = neighbours.pick_random()
			if(Vector2(get_cell_atlas_coords(0, neighbour)) == EMPTY_TILE):
				var x = (tile.x+neighbour.x)/2
				var y = (tile.y+neighbour.y)/2
				set_cell(0, Vector2(x, y), 1, FLOOR_TILE)
				tileStack.append(neighbour)
				break
			neighbours.erase(neighbour)
		if(len(neighbours) == 0):
			tileStack.erase(tile)
	convertWalls()

func getNeighbours(coords : Vector2):
	var neighbours = []
	neighbours.append(Vector2(coords.x+2, coords.y))
	neighbours.append(Vector2(coords.x, coords.y+2))
	neighbours.append(Vector2(coords.x-2, coords.y))
	neighbours.append(Vector2(coords.x, coords.y-2))
	return neighbours

func convertWalls():#converts the wallrom the full sized boxes to the thin version
	for x in range(-1, MAZE_WIDTH+1):
		for y in range(-1, MAZE_HEIGHT+1):
			if(get_cell_source_id(0, Vector2(x, y)) == WALL_SOURCE_ID):
				var topWall = get_cell_source_id(0, Vector2(x, y-1)) == WALL_SOURCE_ID
				var bottomWall = get_cell_source_id(0, Vector2(x, y+1)) == WALL_SOURCE_ID
				var leftWall = get_cell_source_id(0, Vector2(x-1, y)) == WALL_SOURCE_ID
				var rightWall = get_cell_source_id(0, Vector2(x+1, y)) == WALL_SOURCE_ID
				if(bottomWall and leftWall and topWall and rightWall):
					set_cell(0, Vector2(x, y), WALL_SOURCE_ID, Vector2(0, 3))
				elif(bottomWall and leftWall and rightWall):
					set_cell(0, Vector2(x, y), WALL_SOURCE_ID, Vector2(3, 0))
				elif(topWall and leftWall and rightWall):
					set_cell(0, Vector2(x, y), WALL_SOURCE_ID, Vector2(4, 0))
				elif(leftWall and topWall and bottomWall):
					set_cell(0, Vector2(x, y), WALL_SOURCE_ID, Vector2(3, 1))
				elif(topWall and bottomWall and rightWall):
					set_cell(0, Vector2(x, y), WALL_SOURCE_ID, Vector2(4, 1))
				elif(topWall and bottomWall):
					set_cell(0, Vector2(x, y), WALL_SOURCE_ID, Vector2(0, 0))
				elif(leftWall and rightWall):
					set_cell(0, Vector2(x, y), WALL_SOURCE_ID, Vector2(0, 1))
				elif(bottomWall and rightWall):
					set_cell(0, Vector2(x, y), WALL_SOURCE_ID, Vector2(1, 0))
				elif(topWall and rightWall):
					set_cell(0, Vector2(x, y), WALL_SOURCE_ID, Vector2(1, 1))
				elif(leftWall and bottomWall):
					set_cell(0, Vector2(x, y), WALL_SOURCE_ID, Vector2(2, 0))
				elif(leftWall and topWall):
					set_cell(0, Vector2(x, y), WALL_SOURCE_ID, Vector2(2, 1))
				elif(rightWall):
					set_cell(0, Vector2(x, y), WALL_SOURCE_ID, Vector2(1, 2))
				elif(leftWall):
					set_cell(0, Vector2(x, y), WALL_SOURCE_ID, Vector2(2, 2))
				elif(topWall):
					set_cell(0, Vector2(x, y), WALL_SOURCE_ID, Vector2(3, 2))
				elif(bottomWall):
					set_cell(0, Vector2(x, y), WALL_SOURCE_ID, Vector2(4, 2))
				

"""
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
	for y in range(15):
		for x in range(20):
			var rightWall = !x == 19
			var bottomWall = !y == 14
			tiles.append(Tile.new(x, y, index, rightWall, bottomWall))
			index += 1
	for tile in tiles:
		if(tile.y != 0):
			tile.topNeighbour = tiles[tile.index-20]
		if(tile.y != 14):
			tile.bottomNeighbour = tiles[tile.index+20]
		if(tile.x != 0):
			tile.leftNeighbour = tiles[tile.index-1]
		if(tile.x != 19):
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
"""