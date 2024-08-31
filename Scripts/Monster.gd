extends CharacterBody2D

@export var target : Node2D
@export var WANDER_SPEED : float
@export var RUN_SPEED : float
@export var BLIND_CHASE_DURATION : float

var speedMultiplier = 1.0#Changed by halo pieces when picked up, 1 by default

var mode
var stunned
var blindTime
var startDirection = null
var chaseDirection = null
var oppositeDirection = null

func _ready():
	mode = "wander"
	getPath()

func _physics_process(_delta):
	if(mode == "chase" and position.distance_to(target.position) < 85):#game over if monster catches player
		get_tree().change_scene_to_file("res://Scenes/CatchEnding.tscn")
		return
		
	var spaceState = get_world_2d().direct_space_state
	var query = PhysicsRayQueryParameters2D.create(position, target.position)
	var result = spaceState.intersect_ray(query)
	if(result and result.collider == target and position.distance_to(target.position) < 900):
		startDirection = null
		if(mode == "wander"):#the 2 second scream pause
			mode = "chase"
			stun(5)
		mode = "chase"
	elif(mode=="chase"):
		mode = "chaseBlind"
		blindTime = Time.get_ticks_msec()
		oppositeDirection = null
		chaseDirection = null

	if(mode == "chase" or mode == "chaseBlind" or (mode == "wander" and position.distance_to($NavigationAgent2D.target_position) < 160+10)):
		getPath()

	var direction = $NavigationAgent2D.get_next_path_position()-position

	if(mode == "wander"):
		velocity = direction.normalized()*WANDER_SPEED*speedMultiplier
	else:
		velocity = direction.normalized()*RUN_SPEED*speedMultiplier
	
	if(mode == "chase" or mode =="chaseBlind"):
		if(not $StepSound.playing and not stunned):
			$StepSound.play()
	move_and_slide()

func getPath():
	if(mode == "wander"):
		var rng = RandomNumberGenerator.new()
		var x = rng.randi_range(0, 19)#MAZECHANGE
		var y = rng.randi_range(0, 19)
		$NavigationAgent2D.target_position = Vector2(x*160, y*160)
	if(mode == "chase"):
		$NavigationAgent2D.target_position = target.position
	if(mode == "chaseBlind"):
		if(Time.get_ticks_msec()-blindTime > BLIND_CHASE_DURATION*1000):
			mode = "wander"
			get_path()
			return
		if(position.distance_to($NavigationAgent2D.target_position) < 160):
			if(startDirection == null):
				getStartDirection()
			if(chaseDirection):
				var pos = getTilemapPosition()
				var x = pos[0]
				var y = pos[1]
				var tilemap = get_node("../Tilemap")
				match chaseDirection:
					"up":				
						if(tilemap.get_cell_source_id(0, Vector2(x, y-1)) != 0):
							$NavigationAgent2D.target_position = Vector2(x*160+80, (y-1)*160+80)
							return
					"down":				
						if(tilemap.get_cell_source_id(0, Vector2(x, y+1)) != 0):
							$NavigationAgent2D.target_position = Vector2(x*160+80, (y+1)*160+80)
							return
					"left":				
						if(tilemap.get_cell_source_id(0, Vector2(x-1, y)) != 0):
							$NavigationAgent2D.target_position = Vector2((x-1)*160+80, y*160+80)
							return
					"right":				
						if(tilemap.get_cell_source_id(0, Vector2(x+1, y)) != 0):
							$NavigationAgent2D.target_position = Vector2((x+1)*160+80, y*160+80)
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
	var x = int(position.x/160)
	var y = int(position.y/160)
	var tilemap = get_node("../Tilemap")
	if(tilemap.get_cell_source_id(0, Vector2(x, y)) == 0):
		if(position.x-x*160 < position.y-y*160):
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
		if(Vector2((x-1)*160, y*160).distance_to(startPosition) < smallestDistance):
			closestDirection = "left"
			smallestDistance = Vector2((x-1)*160, y*160).distance_to(startPosition)
	if(tilemap.get_cell_source_id(0, Vector2(x+1, y)) != 0):
		if(Vector2((x+1)*160, y*160).distance_to(startPosition) < smallestDistance):
			closestDirection = "right"
			smallestDistance = Vector2((x+1)*160, y*160).distance_to(startPosition)
	if(tilemap.get_cell_source_id(0, Vector2(x, y-1)) != 0):
		if(Vector2(x*160, (y-1)*160).distance_to(startPosition) < smallestDistance):
			closestDirection = "up"
			smallestDistance = Vector2(x*160, (y-1)*160).distance_to(startPosition)
	if(tilemap.get_cell_source_id(0, Vector2(x, y+1)) != 0):
		if(Vector2(x*160, (y+1)*160).distance_to(startPosition) < smallestDistance):
			closestDirection = "down"
			smallestDistance = Vector2(x*160, (y+1)*160).distance_to(startPosition)
	startDirection = closestDirection

func stun(duration):
	stunned = true
	$SightedEffect.play()
	var tempWalkSpeed = WANDER_SPEED
	var tempRunSpeed = RUN_SPEED
	RUN_SPEED = 0
	WANDER_SPEED = 0
	await get_tree().create_timer(duration).timeout
	RUN_SPEED = tempRunSpeed
	WANDER_SPEED = tempWalkSpeed
	stunned = false