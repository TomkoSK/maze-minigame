extends TileMap

@export var MAZE_WIDTH = 21#IF YOU CHANGE THIS, YOU NEED TO CHANGE PLAYER.GD AND MONSTER.GD TOO!!!! (search for MAZECHANGE within files)
@export var MAZE_HEIGHT = 21
var WALL_TILE = Vector2(0, 2)
var FLOOR_TILE = Vector2(0, 0)
var EMPTY_TILE = Vector2(-1, -1)
var TEST_TILE = Vector2(1, 1)
var EXIT_TILES = [Vector2i(3, 0), Vector2i(4, 0), Vector2i(3, 1), Vector2i(4, 1)]
var WALL_SOURCE_ID = 0

var exitPosition : Vector2

func _ready():
	$FloorSprite.scale = Vector2((MAZE_WIDTH+1)*160/2000.0, (MAZE_HEIGHT+1)*160/2000.0)
	var xThing = 2000/2*$FloorSprite.scale.x
	$FloorSprite.position.x += xThing
	$FloorSprite.position.y += 2000/2*$FloorSprite.scale.y
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
		if(len(neighbours) == 0):#This means tile is now a dead end
			tileStack.erase(tile)
	
	var exitSide = [0, 1].pick_random()
	var exitX
	var exitY
	if(exitSide == 0):
		var rng = RandomNumberGenerator.new()
		exitX = rng.randi_range(0, MAZE_WIDTH-1)
		while(exitX % 2 != 0):#even tiles are guaranteed to be floor tiles, so this makes it so that the exit is not right besides a wall
			exitX = rng.randi_range(0, MAZE_WIDTH-1)
		exitY = [-1, MAZE_HEIGHT].pick_random()
		if(exitY == MAZE_HEIGHT and exitX < 6):#So that the dark hallway and the exit aren't next to each other
			exitX = 12
	if(exitSide == 1):
		var rng = RandomNumberGenerator.new()
		exitX = MAZE_WIDTH
		exitY = rng.randi_range(0, MAZE_HEIGHT-1)
		while(exitY % 2 != 0):#even tiles are guaranteed to be floor tiles, so this makes it so that the exit is not right besides a wall
			exitY = rng.randi_range(0, MAZE_HEIGHT-1)
	
	exitPosition = Vector2(exitX, exitY)
	if(exitY == -1):
		set_cell(0, Vector2(exitX, exitY), 1, Vector2(3, 0))
		set_cell(0, Vector2(exitX, exitY-1), 1, EMPTY_TILE)
	elif(exitY == MAZE_HEIGHT):
		set_cell(0, Vector2(exitX, exitY), 1, Vector2(4, 0))
		set_cell(0, Vector2(exitX, exitY+1), 1, EMPTY_TILE)
	elif(exitX == -1):
		set_cell(0, Vector2(exitX, exitY), 1, Vector2(3, 1))
		set_cell(0, Vector2(exitX-1, exitY), 1, EMPTY_TILE)
	elif(exitX == MAZE_WIDTH):
		set_cell(0, Vector2(exitX, exitY), 1, Vector2(4, 1))
		set_cell(0, Vector2(exitX+1, exitY), 1, EMPTY_TILE)

	$ExitHitbox.global_position = Vector2(exitX*160+80, exitY*160+80)
	
	set_cell(0, Vector2(-1, 18), 1, EMPTY_TILE)
	set_cell(0, Vector2(-2, 18), 1, EMPTY_TILE)
	"""
	for i in range(-1, -9, -1):
		set_cell(0, Vector2(i, 17), WALL_SOURCE_ID, WALL_TILE)
		set_cell(0, Vector2(i, 19), WALL_SOURCE_ID, WALL_TILE)
	"""

	var haloPlacements = getHaloPlacements()
	for i in range(3):
		var sprite = $Halos.get_child(i)
		var tile = haloPlacements.pick_random()
		haloPlacements.erase(tile)
		sprite.global_position = Vector2(tile.x*160+80, tile.y*160+80)


	var removableWalls = []
	for x in range(3, MAZE_WIDTH-3):#11 because dark hallway got added too
		for y in range(3, MAZE_HEIGHT-3):
			if(get_cell_source_id(0, Vector2(x, y)) == WALL_SOURCE_ID):
				var topWall = get_cell_source_id(0, Vector2(x, y-1)) == WALL_SOURCE_ID or get_cell_atlas_coords(0, Vector2(x, y-1)) in EXIT_TILES
				var bottomWall = get_cell_source_id(0, Vector2(x, y+1)) == WALL_SOURCE_ID or get_cell_atlas_coords(0, Vector2(x, y+1)) in EXIT_TILES
				var leftWall = get_cell_source_id(0, Vector2(x-1, y)) == WALL_SOURCE_ID or get_cell_atlas_coords(0, Vector2(x-1, y)) in EXIT_TILES
				var rightWall = get_cell_source_id(0, Vector2(x+1, y)) == WALL_SOURCE_ID or get_cell_atlas_coords(0, Vector2(x+1, y)) in EXIT_TILES
				var removable = (leftWall and rightWall and not topWall and not bottomWall) or (topWall and bottomWall and not leftWall and not rightWall)
				if(removable):
					removableWalls.append(Vector2(x, y))
	for i in range(10):
		var wall = removableWalls.pick_random()
		removableWalls.erase(wall)
		set_cell(0, wall, 1, FLOOR_TILE)
	convertWalls()
		

func getNeighbours(coords : Vector2):
	var neighbours = []
	neighbours.append(Vector2(coords.x+2, coords.y))
	neighbours.append(Vector2(coords.x, coords.y+2))
	neighbours.append(Vector2(coords.x-2, coords.y))
	neighbours.append(Vector2(coords.x, coords.y-2))
	return neighbours

func getImmediateNeighbours(coords : Vector2):#:3
	var neighbours = []
	neighbours.append(Vector2(coords.x+1, coords.y))
	neighbours.append(Vector2(coords.x, coords.y+1))
	neighbours.append(Vector2(coords.x-1, coords.y))
	neighbours.append(Vector2(coords.x, coords.y-1))
	return neighbours

func convertWalls():#converts the walls from the full sized boxes to the thin version
	for x in range(-11, MAZE_WIDTH+11):#11 because dark hallway got added too
		for y in range(-11, MAZE_HEIGHT+11):
			if(get_cell_source_id(0, Vector2(x, y)) == WALL_SOURCE_ID):#NOTE: The exit tile check does not care for source ID, might break something later!!
				var topWall = get_cell_source_id(0, Vector2(x, y-1)) == WALL_SOURCE_ID or get_cell_atlas_coords(0, Vector2(x, y-1)) in EXIT_TILES
				var bottomWall = get_cell_source_id(0, Vector2(x, y+1)) == WALL_SOURCE_ID or get_cell_atlas_coords(0, Vector2(x, y+1)) in EXIT_TILES
				var leftWall = get_cell_source_id(0, Vector2(x-1, y)) == WALL_SOURCE_ID or get_cell_atlas_coords(0, Vector2(x-1, y)) in EXIT_TILES
				var rightWall = get_cell_source_id(0, Vector2(x+1, y)) == WALL_SOURCE_ID or get_cell_atlas_coords(0, Vector2(x+1, y)) in EXIT_TILES
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
				else:
					set_cell(0, Vector2(x, y), 1, FLOOR_TILE)
				
func getHaloPlacements():
	var placements = []
	for x in range(MAZE_WIDTH):
		for y in range(MAZE_HEIGHT):
			if(Vector2(get_cell_atlas_coords(0, Vector2(x, y))) == FLOOR_TILE):
				var wallCount = 0
				for neighbour in getImmediateNeighbours(Vector2(x, y)):
					if(Vector2(get_cell_atlas_coords(0, neighbour)) == WALL_TILE):
						wallCount += 1
				if(wallCount == 3):
					placements.append(Vector2(x, y))
	placements.erase(Vector2(0, 0))
	return placements

func unlockExit():
	set_cell(0, exitPosition, 1, FLOOR_TILE)

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