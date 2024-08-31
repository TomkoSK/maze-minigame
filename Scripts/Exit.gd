extends Area2D

@export var player : Node2D
@export var mazeManager : Node2D

var playerInArea = false

func _on_body_entered(body:Node2D):
	if(body == player):
		if(player.keys["halo0.png"] and player.keys["halo1.png"] and player.keys["halo2.png"]):
			mazeManager.unlockExit()
			player.keys["halo0.png"] = false
			player.keys["halo1.png"] = false
			player.keys["halo2.png"] = false
			player.refreshHalos()
		playerInArea = true
		player.setHaloLights(true)


func _on_body_exited(body:Node2D):
	if(body == player):
		playerInArea = false
		player.setHaloLights(false)
	
func _input(event):
	if(event.is_action_pressed("afkTest")):
		player.setHaloLights(true)
	if(event.is_action_pressed("ui_cancel")):
		player.setHaloLights(false)