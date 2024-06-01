extends CharacterBody2D

@export var SPEED = 200

func _process(_delta):
	velocity = Input.get_vector("left", "right", "up", "down")*SPEED

func _physics_process(_delta):
	move_and_slide()
