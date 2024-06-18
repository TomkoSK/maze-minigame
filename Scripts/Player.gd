extends CharacterBody2D

@export var SPEED = 80
@export var SPRINT_SPEED = 160
@export var SPRINT_RECOVERY = 25
@export var SPRINT_CONSUMPTION = 35
var sprinting = false
var sprint = 100

func _process(delta):
	$SprintLabel.text = str(sprint)
	if(sprinting):
		sprint -= SPRINT_CONSUMPTION*delta
	else:
		sprint += SPRINT_RECOVERY*delta
	
	if(sprinting and sprint > 0):
		velocity = Input.get_vector("left", "right", "up", "down")*SPRINT_SPEED
	else:
		velocity = Input.get_vector("left", "right", "up", "down")*SPEED
	sprint=clamp(sprint, 0, 100)

	var cursorPos = get_global_mouse_position()
	$Flashlight.rotation = position.direction_to(cursorPos).angle()
	$Flashlight.global_position = position.move_toward(cursorPos, 10)

func _physics_process(_delta):
	move_and_slide()

func _input(event):
	if(event is InputEventMouseButton):
		if(event.button_index == 1 and event.is_pressed()):
			var tween = create_tween()
			tween.tween_property($Flashlight/Light, "scale", Vector2(1, 0.5), 0.2)
			tween = create_tween()
			tween.tween_property($Flashlight/Light, "energy", 3, 0.2)
		if(event.button_index == 1 and !event.is_pressed()):
			var tween = create_tween()
			tween.tween_property($Flashlight/Light, "scale", Vector2(1, 1), 0.2)
			tween = create_tween()
			tween.tween_property($Flashlight/Light, "energy", 1, 0.1)
	if(event.is_action_pressed("sprint")):
		sprinting = true
	if(event.is_action_released("sprint")):
		sprinting = false