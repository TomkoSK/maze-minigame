extends Area2D

@export var player : Node2D
@export var mazeManager : Node2D

var playerInArea = false

func _on_body_entered(body:Node2D):
	if(body == player):
		if(player.haloComplete):
			mazeManager.unlockExit()
		playerInArea = true

func _on_body_exited(body:Node2D):
	if(body == player):
		playerInArea = false