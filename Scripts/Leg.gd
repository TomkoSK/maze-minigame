extends Node2D

@export var target : Node2D

var currentPos = Vector2(0, 0)
var rng = RandomNumberGenerator.new()
var distanceThreshold = rng.randi_range(170, 250)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	$Line2D.points = [to_local(currentPos), Vector2.ZERO]
	if(currentPos.distance_to(target.position) > distanceThreshold):
		currentPos = target.position + target.getDirection().rotated(rng.randf_range(-0.7, 0.7))*rng.randi_range(distanceThreshold*0.6, distanceThreshold*0.95)