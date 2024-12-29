extends Node2D

@export var target : Node2D

var currentPos = Vector2(0, 0)
var wishedPos = Vector2(0, 0)
var rng = RandomNumberGenerator.new()
var distanceThreshold = rng.randi_range(200, 300)
var defensiveRotationOffset = rng.randf_range(-1.6, 1.6)
var legSpeed = 3000

var stunned = false

func stun(duration:float):#puts the leg in stunned protective mode for x seconds
	stunned = true
	legSpeed = 1000
	await get_tree().create_timer(duration).timeout
	legSpeed = 3000
	stunned = false

func legPlaced():#sus
	if(rng.randf() > 2):#for spider footsteps later
		$Footstep.play()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):	
	if(wishedPos.distance_to(target.position) > distanceThreshold or (stunned and wishedPos.distance_to(target.position) > distanceThreshold*0.6)):
		if(stunned):
			wishedPos = target.position + target.getDirection().rotated(rng.randf_range(-1,1))*rng.randi_range(distanceThreshold*0.4, distanceThreshold*0.5)
		else:
			wishedPos = target.position + target.getDirection().rotated(rng.randf_range(-1,1))*rng.randi_range(distanceThreshold*0.9, distanceThreshold)
	var targetPos = to_local(wishedPos)
	var middlePoint = targetPos/2
	var	directionVector = targetPos.normalized()
	var rightVector = directionVector.rotated(-3.14/2)
	var leftVector = directionVector.rotated(3.14/2)
	var monsterDirection
	monsterDirection = target.getDirection()
	if(abs(monsterDirection.angle()-leftVector.angle()) < abs(monsterDirection.angle()-rightVector.angle())):
		directionVector = leftVector
		if(stunned):
			directionVector = rightVector
	else:
		directionVector = rightVector
		if(stunned):
			directionVector = leftVector
	var squaredDistance = (Vector2.ZERO.distance_to(targetPos)/2.0)**2
	var squaredHeight = max((distanceThreshold/2.4)**2-squaredDistance, 0)
	var height = sqrt(squaredHeight)
	middlePoint += directionVector*height
	var desiredPoints = [targetPos, middlePoint, Vector2.ZERO]
	for i in range(3):
		$Line2D.points[i] = $Line2D.points[i].move_toward(desiredPoints[i], legSpeed*delta)