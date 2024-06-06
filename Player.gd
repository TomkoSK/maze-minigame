extends CharacterBody2D

@export var SPEED = 200

func _process(_delta):
	velocity = Input.get_vector("left", "right", "up", "down")*SPEED

	var cursorPos = get_viewport().get_mouse_position()
	$Flashlight.rotation = Vector2(400, 300).direction_to(cursorPos).angle()

func _physics_process(_delta):
	move_and_slide()
