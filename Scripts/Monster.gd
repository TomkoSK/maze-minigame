extends CharacterBody2D

@export var target : Node2D
@export var WANDER_SPEED : float
@export var RUN_SPEED : float
@export var BLIND_CHASE_DURATION : float
var mode
var blindTime
var startDirection = null
var chaseDirection = null
var oppositeDirection = null

func _ready():
	mode = "wander"
	getPath()

func _physics_process(_delta):
	var spaceState = get_world_2d().direct_space_state
	var query = PhysicsRayQueryParameters2D.create(position, target.position)
	var result = spaceState.intersect_ray(query)
	if(result.collider == target and position.distance_to(target.position) < 600):
		startDirection = null
		mode = "chase"
	elif(mode=="chase"):
		mode = "chaseBlind"
		blindTime = Time.get_ticks_msec()
		oppositeDirection = null
		chaseDirection = null

	if(mode == "chase" or mode == "chaseBlind" or (mode == "wander" and position.distance_to($NavigationAgent2D.target_position) < 50)):
		getPath()

	var direction = $NavigationAgent2D.get_next_path_position()-position

	if(mode == "wander"):
		velocity = direction.normalized()*WANDER_SPEED
	else:
		velocity = direction.normalized()*RUN_SPEED
	move_and_slide()

func getPath():
	if(mode == "wander"):
		var rng = RandomNumberGenerator.new()
		var x = rng.randi_range(0, 35)
		var y = rng.randi_range(0, 25)
		$NavigationAgent2D.target_position = Vector2(x*40, y*40)
	if(mode == "chase"):
		$NavigationAgent2D.target_position = target.position
	if(mode == "chaseBlind"):
		if(Time.get_ticks_msec()-blindTime > BLIND_CHASE_DURATION*1000):
			mode = "wander"
			get_path()
			return
		if(position.distance_to($NavigationAgent2D.target_position) < 10):
			if(startDirection == null):
				getStartDirection()
				print(startDirection)
			if(chaseDirection):
				var pos = getTilemapPosition()
				var x = pos[0]
				var y = pos[1]
				var tilemap = get_node("../Tilemap")
				match chaseDirection:
					"up":				
						if(tilemap.get_cell_source_id(0, Vector2(x, y-1)) != 0):
							$NavigationAgent2D.target_position = Vector2(x*40+20, (y-1)*40+20)
							return
					"down":				
						if(tilemap.get_cell_source_id(0, Vector2(x, y+1)) != 0):
							$NavigationAgent2D.target_position = Vector2(x*40+20, (y+1)*40+20)
							return
					"left":				
						if(tilemap.get_cell_source_id(0, Vector2(x-1, y)) != 0):
							$NavigationAgent2D.target_position = Vector2((x-1)*40+20, y*40+20)
							return
					"right":				
						if(tilemap.get_cell_source_id(0, Vector2(x+1, y)) != 0):
							$NavigationAgent2D.target_position = Vector2((x+1)*40+20, y*40+20)
							return
		else:
			return
		getDirection()

func getDirection():
	var directions = ["up", "down", "left", "right"]
	if(startDirection):
		directions.erase(startDirection)
	if(oppositeDirection):
		directions.erase(oppositeDirection)
	var pos = getTilemapPosition()
	var x = pos[0]
	var y = pos[1]
	var tilemap = get_node("../Tilemap")
	while true:
		chaseDirection = directions.pick_random()
		match chaseDirection:
			"up":				
				if(tilemap.get_cell_source_id(0, Vector2(x, y-1)) == 0):
					directions.erase(chaseDirection)
				else:
					oppositeDirection = "down"
					break
			"down":				
				if(tilemap.get_cell_source_id(0, Vector2(x, y+1)) == 0):
					directions.erase(chaseDirection)
				else:
					oppositeDirection = "up"
					break
			"left":				
				if(tilemap.get_cell_source_id(0, Vector2(x-1, y)) == 0):
					directions.erase(chaseDirection)
				else:
					oppositeDirection = "right"
					break
			"right":				
				if(tilemap.get_cell_source_id(0, Vector2(x+1, y)) == 0):
					directions.erase(chaseDirection)
				else:
					oppositeDirection = "left"
					break
		if(len(directions) == 0):
			if(startDirection):
				chaseDirection = startDirection
			else:
				chaseDirection = oppositeDirection
			match chaseDirection:
				"up":
					oppositeDirection = "down"
				"down":
					oppositeDirection = "up"
				"left":
					oppositeDirection = "right"
				"right":
					oppositeDirection = "left"
			break
	if(startDirection):
		startDirection = false

func getTilemapPosition():#help me
	var x = int(position.x/40)
	var y = int(position.y/40)
	var tilemap = get_node("../Tilemap")
	if(tilemap.get_cell_source_id(0, Vector2(x, y)) == 0):
		if(position.x-x*40 < position.y-y*40):
			x += 1 
			if(tilemap.get_cell_source_id(0, Vector2(x, y)) == 0):
				y += 1
				if(tilemap.get_cell_source_id(0, Vector2(x, y)) == 0):
					x -= 1
		else:
			y += 1 
			if(tilemap.get_cell_source_id(0, Vector2(x, y)) == 0):
				x += 1
				if(tilemap.get_cell_source_id(0, Vector2(x, y)) == 0):
					y -= 1
	return [x, y]

func getStartDirection():
	var startPosition = $NavigationAgent2D.get_current_navigation_path()[0]
	var pos = getTilemapPosition()
	var x = pos[0]
	var y = pos[1]
	var closestDirection = "up"#will return up by default, so that it doesnt crash if all 4 tiles around are walls or something
	var smallestDistance = 1000000000
	var tilemap = get_node("../Tilemap")
	if(tilemap.get_cell_source_id(0, Vector2(x-1, y)) != 0):
		if(Vector2((x-1)*40, y*40).distance_to(startPosition) < smallestDistance):
			closestDirection = "left"
			smallestDistance = Vector2((x-1)*40, y*40).distance_to(startPosition)
	if(tilemap.get_cell_source_id(0, Vector2(x+1, y)) != 0):
		if(Vector2((x+1)*40, y*40).distance_to(startPosition) < smallestDistance):
			closestDirection = "right"
			smallestDistance = Vector2((x+1)*40, y*40).distance_to(startPosition)
	if(tilemap.get_cell_source_id(0, Vector2(x, y-1)) != 0):
		if(Vector2(x*40, (y-1)*40).distance_to(startPosition) < smallestDistance):
			closestDirection = "up"
			smallestDistance = Vector2(x*40, (y-1)*40).distance_to(startPosition)
	if(tilemap.get_cell_source_id(0, Vector2(x, y+1)) != 0):
		if(Vector2(x*40, (y+1)*40).distance_to(startPosition) < smallestDistance):
			closestDirection = "down"
			smallestDistance = Vector2(x*40, (y+1)*40).distance_to(startPosition)
	startDirection = closestDirection