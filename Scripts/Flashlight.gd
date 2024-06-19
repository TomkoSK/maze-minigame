extends Sprite2D

var player : Node2D
var shakeIntensity = 3
var shakeFrequency = 0.007

func _ready():
	player = get_parent()


func _process(delta):
	if(player.sprinting):
		shakeIntensity = 1.9
		shakeFrequency = 0.0085
	elif(player.velocity != Vector2.ZERO):
		shakeIntensity = 1.2
		shakeFrequency = 0.005
	else:
		shakeIntensity = 0
		shakeFrequency = 0

	var cursorPos = get_global_mouse_position()#All of this is supposed to gradually move the flashlight to the player's cursor, its not working :3
	var desiredDirection = player.position.direction_to(cursorPos)
	var desiredAngle = rad_to_deg(desiredDirection.angle())
	var currentDirection = player.position.direction_to(global_position)
	var currentAngle = rad_to_deg(currentDirection.angle())
	var changedAngle
	if(abs(currentAngle-desiredAngle) >= 180):
		changedAngle = move_toward(currentAngle, desiredAngle, -120*delta)
	else:
		changedAngle = move_toward(currentAngle, desiredAngle, 120*delta)

	rotation = deg_to_rad(changedAngle)
	global_position = player.position + Vector2.RIGHT.rotated(deg_to_rad(changedAngle))*8
	

	var xShakeModifier = player.position.direction_to(cursorPos).x*shakeIntensity
	var yShakeModifier = player.position.direction_to(cursorPos).y*shakeIntensity
	var offsetGlobal = Vector2(sin(float(Time.get_ticks_msec())*shakeFrequency)*xShakeModifier, sin(float(Time.get_ticks_msec())*shakeFrequency)*yShakeModifier)
	global_position += offsetGlobal

func _input(event):
	if(event is InputEventMouseButton):
		if(event.button_index == 1 and event.is_pressed()):
			var tween = create_tween()
			tween.tween_property($Light, "scale", Vector2(1, 0.5), 0.2)
			tween = create_tween()
			tween.tween_property($Light, "energy", 3, 0.2)
		if(event.button_index == 1 and !event.is_pressed()):
			var tween = create_tween()
			tween.tween_property($Light, "scale", Vector2(1, 1), 0.2)
			tween = create_tween()
			tween.tween_property($Light, "energy", 1, 0.2)