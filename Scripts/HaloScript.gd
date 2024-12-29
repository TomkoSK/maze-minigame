extends Sprite2D

@export var player : Node2D
@export var monster : Node2D

var textureName

func _ready():
	textureName = texture.resource_path.substr(6)

func _on_area_2d_body_entered(body:Node2D):
	if(body == player):
		player.keys[textureName] = true
		player.pickUpHalo(self)
		monster.speedMultiplier += 0.2
		monster.blindChaseHaloModifier += 2
		queue_free()