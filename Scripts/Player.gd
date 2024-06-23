extends CharacterBody2D

@export var SPEED = 80
@export var SPRINT_SPEED = 160
@export var SPRINT_RECOVERY = 25
@export var SPRINT_CONSUMPTION = 35
var sprinting = false
var sprint = 100

func _process(delta):
	if(sprinting):
		sprint -= SPRINT_CONSUMPTION*delta
	else:
		sprint += SPRINT_RECOVERY*delta
	
	if(sprinting and sprint > 0):
		velocity = Input.get_vector("left", "right", "up", "down")*SPRINT_SPEED
	else:
		velocity = Input.get_vector("left", "right", "up", "down")*SPEED
	sprint=clamp(sprint, 0, 100)

func _physics_process(_delta):
	move_and_slide()

func _input(event):
	if(event.is_action_pressed("sprint")):
		sprinting = true
	if(event.is_action_released("sprint")):
		sprinting = false