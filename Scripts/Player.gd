extends CharacterBody2D

@export var SPEED = 80
@export var SPRINT_SPEED = 160
@export var SPRINT_RECOVERY = 25
@export var SPRINT_CONSUMPTION = 35

@export var monster : Node2D
@export var MONSTER_STUN_COOLDOWN = 6000#in milliseconds

@export var WALK_SOUND_DELAY = 350
@export var RUN_SOUND_DELAY = 260

var lastSoundEffectTime = -1000
var footNumber = 1

var sprinting = false
var sprint = 100
var lastInputAt = 0
var afkLength = 30000.0#length before AFK darkening begins (in milliseconds)
var afkDarkenTime = 20000.0#the time during which the screen completely darkens when AFK (in milliseconds)
var darkening = false
var monsterInFlashlightHitbox = false
var lastStunnedAt = -MONSTER_STUN_COOLDOWN#so that you can stun immediately after game starts
var haloComplete = false

var keys = {"halo0.png" : false, "halo1.png" : false, "halo2.png" : false}#changed by HaloScript.gd when player acquires pieces of halo

var inDarkHallway = false

func getDirection():#remove later just for spider leg fun
	return velocity.normalized()

func _process(delta):
	if(position.x < -9*160-80 or position.x > (21+2)*160+80 or position.y < -2*160-80 or position.y > (21+2)*160+80):#MAZECHANGE
		if(position.x < -9*160-80):
			get_tree().quit()#this is dark hallway ending
		else:
			get_tree().quit()#normal ending

	if(sprinting):
		sprint -= SPRINT_CONSUMPTION*delta
	else:
		sprint += SPRINT_RECOVERY*delta
	
	if(sprinting and sprint > 0):
		velocity = Input.get_vector("left", "right", "up", "down")*SPRINT_SPEED
	else:
		velocity = Input.get_vector("left", "right", "up", "down")*SPEED
	sprint=clamp(sprint, 0, 130)

	if(inDarkHallway):
		if(velocity.x < 0 and (keys["halo0.png"] == false or keys["halo1.png"] == false or keys["halo2.png"] == false)):
			velocity.x = remap(position.x, -800, 0, 0, velocity.x)
			#if(position.x < -700 and velocity.x < 0):#hard limit so that player cant truly get through the hallway without halo
				#velocity.x = 0.01#its 0.01 so that footstep sounds are still active
		$Flashlight.flashlightEnergyMultiplier = -75/min(position.x, -75)
		$PlayerLight.texture_scale = -75*3/min(position.x, -75)#NOTE: does not work together with AFK player light size change, FIX IT!
	else:
		$Flashlight.flashlightEnergyMultiplier = 1
		$PlayerLight.texture_scale = 3
	

	if(monsterInFlashlightHitbox and $Flashlight/Light.energy >= 4.1 and Time.get_ticks_msec()-lastStunnedAt >= MONSTER_STUN_COOLDOWN and monster.RUN_SPEED > 0):
		lastStunnedAt = Time.get_ticks_msec()
		monster.stun(2.5, true)

	if(Time.get_ticks_msec()-lastInputAt > afkLength and not inDarkHallway):
		darkening = true
		var darkProgress = 1-((Time.get_ticks_msec()-lastInputAt-afkLength)/afkDarkenTime)#how far the darkening progress is
		if(darkProgress <= 0):#IF SCREEN GETS COMPLETELY DARKENED, GAME OVER
			get_tree().quit()
		#STARTS AT 1 GOES TO 0
		$Flashlight/Light.color.a = darkProgress
		$Flashlight/Light.scale.y = darkProgress

		$PlayerLight.color.a = darkProgress
		$PlayerLight.texture_scale = max(darkProgress*3, 0.9)#minimum size of playerlight will be 0.9, and the default one is 3
		
		$Hand.modulate.a = 1-darkProgress

		var cursorDirection = position.direction_to(get_global_mouse_position())
		cursorDirection = -cursorDirection#the position of the hand is opposite of the flashlight pointing direction
		$Hand.global_position = position+cursorDirection*darkProgress*250
	else:
		if(darkening):
			darkening = false
			var tween = create_tween()
			tween.tween_property($Flashlight/Light, "color", Color(1, 1, 1, 1), 0.2)
			tween = create_tween()
			tween.tween_property($Flashlight/Light, "scale", Vector2(1, 1), 0.2)

			tween = create_tween()
			tween.tween_property($PlayerLight, "color", Color(1, 1, 1, 1), 0.2)
			tween = create_tween()
			tween.tween_property($PlayerLight, "texture_scale", 3, 0.2)

			tween = create_tween()
			tween.tween_property($Hand, "modulate", Color(1, 1, 1, 0), 0.2)
			var cursorDirection = position.direction_to(get_global_mouse_position())
			cursorDirection = -cursorDirection#the position of the hand is opposite of the flashlight pointing direction
			tween = create_tween()
			tween.tween_property($Hand, "global_position", cursorDirection*250, 0.2)
	
	if(velocity != Vector2.ZERO):
		if(sprinting and sprint > 0 and Time.get_ticks_msec()-RUN_SOUND_DELAY > lastSoundEffectTime):#if sprinting
			if(footNumber == 1):
				$Footstep1.pitch_scale = 1.6
				$Footstep1.play()
				footNumber = 2
			elif(footNumber == 2):
				$Footstep2.pitch_scale = 1.6
				$Footstep2.play()
				footNumber = 1
			lastSoundEffectTime = Time.get_ticks_msec()
		elif(Time.get_ticks_msec()-WALK_SOUND_DELAY > lastSoundEffectTime):#if walking
			if(footNumber == 1):
				$Footstep1.pitch_scale = 1.2
				$Footstep1.play()
				footNumber = 2
			elif(footNumber == 2):
				$Footstep2.pitch_scale = 1.2
				$Footstep2.play()
				footNumber = 1
			lastSoundEffectTime = Time.get_ticks_msec()
	else:
		footNumber = 1


func _physics_process(_delta):
	move_and_slide()

func _input(event):
	lastInputAt = Time.get_ticks_msec()
	if(event.is_action_pressed("sprint")):
		sprinting = true
	if(event.is_action_released("sprint")):
		sprinting = false

func pickUpHalo(halo):#called by HaloScript.gd
	if(halo.textureName == "halo0.png"):
		$Halo0.show()
		keys["halo0.png"] = true
	elif(halo.textureName == "halo1.png"):
		$Halo1.show()
		keys["halo1.png"] = true
	elif(halo.textureName == "halo2.png"):
		$Halo2.show()
		keys["halo2.png"] = true
	if(keys["halo0.png"] and keys["halo1.png"] and keys["halo2.png"]):
		await get_tree().create_timer(0.4).timeout
		var tween = create_tween()
		$Halo.show()
		tween.tween_property($Halo, "modulate", Color(1, 1, 1, 1), 1)
		tween = create_tween()
		tween.tween_property($Halo0, "modulate", Color(1, 1, 1, 0), 1)
		tween = create_tween()
		tween.tween_property($Halo1, "modulate", Color(1, 1, 1, 0), 1)
		tween = create_tween()
		tween.tween_property($Halo2, "modulate", Color(1, 1, 1, 0), 1)
		haloComplete = true
		$HaloLight.show()

func _on_area_2d_body_exited(body:Node2D):
	if(body == monster):
		monsterInFlashlightHitbox = false

func _on_area_2d_body_entered(body:Node2D):
	if(body == monster):
		monsterInFlashlightHitbox = true

func _on_dark_hallway_enter(body:Node2D):
	if(body == self):
		inDarkHallway = true

func _on_dark_hallway_exit(body:Node2D):
	if(body == self):
		inDarkHallway = false