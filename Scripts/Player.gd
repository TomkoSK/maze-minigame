extends CharacterBody2D

@export var SPEED = 200

func _process(_delta):
	velocity = Input.get_vector("left", "right", "up", "down")*SPEED

	var cursorPos = get_viewport().get_mouse_position()
	$Flashlight.rotation = Vector2(400, 300).direction_to(cursorPos).angle()

func _physics_process(_delta):
	move_and_slide()

func _input(event):
	if(event is InputEventMouseButton):
		if(event.button_index == 1 and event.is_pressed()):
			var tween = create_tween()
			tween.tween_property($Flashlight, "scale", Vector2(1, 0.5), 0.1)
			tween = create_tween()
			tween.tween_property($Flashlight, "energy", 3, 0.1)
		if(event.button_index == 1 and !event.is_pressed()):
			var tween = create_tween()
			tween.tween_property($Flashlight, "scale", Vector2(1, 1), 0.1)
			tween = create_tween()
			tween.tween_property($Flashlight, "energy", 1, 0.1)