extends Node2D

@export var target : Node2D

var currentPos = Vector2(0, 0)
var rng = RandomNumberGenerator.new()
var distanceThreshold = 250

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	var middlePoint = currentPos/2
	var directionVector = currentPos.normalized()
	if(directionVector.x < 0):
		directionVector = directionVector.rotated(3.14/2)
	else:
		directionVector = directionVector.rotated(-3.14/2)
	var squaredDistance = (Vector2.ZERO.distance_to(currentPos)/2.0)**2
	var squaredHeight = max((distanceThreshold/2.0)**2-squaredDistance, 0)
	var height = sqrt(squaredHeight)
	middlePoint+= directionVector*height
	$Line2D.points = [to_local(currentPos), middlePoint, Vector2.ZERO]
	currentPos = get_global_mouse_position()