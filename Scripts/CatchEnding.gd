extends Node2D

func _on_flash_timer_timeout():
	$FlashTimer.wait_time = 1
	if($White.visible):
		$White.visible = false
	else:
		$White.visible = true
