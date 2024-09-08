extends CharacterBody2D

const SPEED = 75
var tool = "gun"
@onready var Floor = $"../floor"

@export var HP = 20
@export var quant_woods = 20
@export var ammo = 24

var temp
var count = 0
var mouse_in_area = false

var in_lava = false


# power up list
var power_ups_enabled = ["0", "0", "0"]
var pul = {
	"0": ["nothing", "does nothing"]
}

# == Power UPs ========= #
var lava_walk      = false #X
var lava_no_damage = false #X
var death_blt      = false #X
var double_blt     = false #X
var piercing_blt   = false #X
var shotgun        = false #X
var tile_lover     = false #X
var infinity_blt   = false
# ====================== #


func _ready() -> void:
	
	var file = "langs/" + Global.lang + ".json"
	var json_as_text = FileAccess.get_file_as_string(file)
	var json_as_dict = JSON.parse_string(json_as_text)
	if json_as_dict:
		#print(json_as_dict["power_ups"])
		pul = json_as_dict["power_ups"]
	power_ups_enabled = ["0", "0", "0"]
	
	$Ui/HpBar.value = HP
	$Ui/HpBar.max_value = HP

func _physics_process(_delta: float) -> void:
	
	if Input.is_action_just_pressed("debug_key"):
		power_up()
	
	
	var tile_pos = Floor.local_to_map(global_position)
	if Floor.get_cell_atlas_coords(0, tile_pos) == Vector2i.ZERO:
		if in_lava:
			#print_rich("[color=blue]chão[/color]")
			in_lava = false
			$lava_dmg_timer.stop()
			
	elif Floor.get_cell_atlas_coords(0, tile_pos) == Vector2i(1, 0):
		if not in_lava:
			$lava_dmg_timer.start(2.5)
			if lava_no_damage:
				in_lava = false
			else:
				in_lava = true
			#print_rich("[color=red]lava[/color]")
		
		
	
	
	
	$Ui/score.text = "Score: "+str(Global.last_score)
	
	var fps_show = int(Engine.get_frames_per_second())
	if fps_show >= 30:
		$Ui/Fps.text = "[b][color=green]FPS: "+str(fps_show)+"[/color][/b]"
	elif fps_show >= 15:
		$Ui/Fps.text = "[b][color=yellow]FPS: "+str(fps_show)+"[/color][/b]"
	else:
		$Ui/Fps.text = "[b][color=red]FPS: "+str(fps_show)+"[/color][/b]"
	
	var input_direction = Input.get_vector("left", "right", "up", "down")
	velocity = input_direction * SPEED
	
	if velocity != Vector2.ZERO:
		if Global.animations:
			if $anim.current_animation != "dmg":
				$anim.play("walk")
		if Global.particles:
			$particle.emitting = true
	else:
		if Global.animations:
			if $anim.current_animation != "dmg":
				$anim.play("idle")
		$particle.emitting = false
	
	if input_direction.x < 0:
		$Sprite.flip_h = true
		$Sprite/gun.flip_v = true
		$Sprite/ham.flip_h = true
	elif input_direction.x > 0:
		$Sprite.flip_h = false
		$Sprite/gun.flip_v = false
		$Sprite/ham.flip_h = false
	
	if Input.is_action_just_pressed("trade"):
		ToolChange()
		
	if Input.is_action_just_pressed("shoot"):
		Action()
	
	if not get_tree() == null:
		if not get_tree().paused:
			move_and_slide()
	
	#on update
	for x in range(26, 72 + 1):
		for y in range(19, 50 + 1):
			Floor.set_cell(1, Vector2(x,y), -1, Vector2i.ZERO)
			
	if tool == "ham":
		if mouse_in_area:
			var pos = Floor.local_to_map(get_global_mouse_position())
			if pos.x >= 26 and pos.x <= 72:
				if pos.y >= 19 and pos.y <= 50:
					Floor.set_cell(1, pos, 0, Vector2i(3, 0))
				
	if tool == "gun":
		if not get_tree() == null:
			if not get_tree().paused:
				$Sprite/gun.look_at(get_global_mouse_position())
				
				
	if Input.is_action_just_pressed("reset"):
		get_tree().change_scene_to_file("res://menu.tscn")
	
func dmg(x):
	$dmg.pitch_scale = randf_range(0.9, 1.1)
	$dmg.play()
	$anim.play("dmg")
	HP -= x
	if death_blt:
		HP -= x
	if HP <= 0:
		get_tree().call_deferred("change_scene_to_file", "res://menu.tscn")
		#get_tree().change_scene_to_file("res://menu.tscn")
	$Ui/HpBar.value = HP

func ToolChange():
	if tool == "gun":
		tool = "ham"
		$Sprite/gun.visible = false
		$Sprite/ham.visible = true
	elif tool == "ham":
		tool = "gun"
		$Sprite/gun.visible = true
		$Sprite/ham.visible = false
		
func Action():
	
	if Global.animations:
		$item.play("item_use")
		
	if tool == "gun":
		if ammo > 0:
			$shoot.pitch_scale = randf_range(0.9, 1.1)
			$shoot.play()
			#$item.play("item_use")
			#if Global.particles:
			#	$Sprite/gun/smooth.emitting = true
			var bullet = load("res://bullet.tscn")
			
			if shotgun:
				$camera.play("shake_cam")
				for i in range(0, 3):
					var obj = bullet.instantiate()
					if death_blt:
						obj.insta_kill = true
					if piercing_blt:
						obj.piercing = true
					obj.rotation = $Sprite/gun.rotation + (i * 10) - 10
					obj.global_position = get_node("Sprite/gun/aim_shotgun" + str(i+1)).global_position
					obj.direction = get_node("Sprite/gun/aim_shotgun" + str(i+1)).global_position - $Sprite/gun.global_position
					
					get_parent().call_deferred("add_child", obj)
					
					if double_blt:
						var bullet2 = bullet.instantiate()
						if death_blt:
							bullet2.insta_kill = true
						if piercing_blt:
							bullet2.piercing = true
						bullet2.rotation = $Sprite/gun.rotation
						bullet2.global_position = get_node("Sprite/gun/aim_shotgun" + str(i+1)).global_position + Vector2(-8, 0)
						bullet2.direction = get_node("Sprite/gun/aim_shotgun" + str(i+1)).global_position - $Sprite/gun.global_position
						get_parent().call_deferred("add_child", bullet2)
			
			else:
				var obj = bullet.instantiate()
				if death_blt:
					obj.insta_kill = true
				if piercing_blt:
					obj.piercing = true
				obj.rotation = $Sprite/gun.rotation
				obj.global_position = $Sprite/gun/aim.global_position
				obj.direction = $Sprite/gun/aim.global_position - $Sprite/gun.global_position
				
				get_parent().call_deferred("add_child", obj)
				
				if double_blt:
					var bullet2 = bullet.instantiate()
					if death_blt:
						bullet2.insta_kill = true
					if piercing_blt:
						bullet2.piercing = true
					bullet2.rotation = $Sprite/gun.rotation
					bullet2.global_position = $Sprite/gun/aim.global_position + Vector2(-8, 0)
					bullet2.direction = $Sprite/gun/aim.global_position - $Sprite/gun.global_position
					get_parent().call_deferred("add_child", bullet2)
			
			if not infinity_blt:
				ammo -= 1
		else:
			$no_ammo.pitch_scale = randf_range(0.9, 1.1)
			$no_ammo.play()
			ammo = 24
			$Sprite/NoBullet.emitting = true
			$item.play("reload")
		
	elif tool == "ham":
		if mouse_in_area:
			$place.pitch_scale = randf_range(0.9, 1.1)
			$place.play()
			var pos = Floor.local_to_map(get_global_mouse_position())
			if pos.x >= 26 and pos.x <= 72:
				if pos.y >= 19 and pos.y <= 50:
					#print(Floor.get_cell_atlas_coords(0, pos))
					if Floor.get_cell_atlas_coords(0, pos) == Vector2i(1,0) and quant_woods > 0:
						Floor.set_cell(0, pos, 0, Vector2i(0, 0))
						quant_woods -= 1
						$Ui/woods.text = "       x" + str(quant_woods)
						if tile_lover:
							Global.last_score += 1
	pass


func _on_lava_dmg_timer_timeout() -> void:
	dmg(1)
	$lava_dmg_timer.start(1)
	pass # Replace with function body.
	
	
func shake_cam():
	$cam.offset = Vector2(randf_range(-1, 1), randf_range(-1, 1))

func verify_power_ups():
	# == False all ===== #
	lava_walk      = false
	lava_no_damage = false
	death_blt      = false
	double_blt     = false
	piercing_blt   = false
	shotgun        = false
	tile_lover     = false
	infinity_blt   = false
	# ================== #
	
	# === Others ======= #
	$Sprite/gun.texture = load("res://imgs/pistol.png")
	set_collision_mask_value(2, true)
	$construct_area.scale = Vector2i(1, 1)
	# ================== #
	
	for i in range(0, 3):
		#print(i)
		match power_ups_enabled[i]:
			"0":
				#print("But nothing happens...")
				pass
			"1":
				lava_walk = true
				set_collision_mask_value(2, false)
			"2":
				death_blt = true
			"3":
				piercing_blt = true
			"4":
				double_blt = true
			"5":
				shotgun = true
				$Sprite/gun.texture = load("res://imgs/shotgun.png")
			"6":
				tile_lover = true
			"7":
				HP += 5
				if HP > 20:
					HP = 20
				$Ui/HpBar.value = HP
			"8":
				lava_no_damage = true
			"9":
				infinity_blt = true
			"10":
				get_wood(1)
			"11":
				$construct_area.scale = Vector2i(2,2)
			"12", "13", "14":
				pass
			_:
				print_rich("[color=red]WTF, pq deu isso?[/color]")
	pass

func get_wood(x):
	quant_woods += x
	$Ui/woods.text = "       x" + str(quant_woods)
	pass

func power_up():
	get_tree().paused = true
	$Ui/PowerUpMenu.show()
	
	var quant_power_ups = 14
	var pw1 = randi_range(0, quant_power_ups)
	var pw2 = randi_range(0, quant_power_ups)
	var pw3 = randi_range(0, quant_power_ups)
	
	$Ui/PowerUpMenu/PowerUp1.text = ".\n.\n.\n.\n.\n-----------------" + pul[str(pw1)][0]
	$Ui/PowerUpMenu/PowerUp1/card.frame = pw1
	
	$Ui/PowerUpMenu/PowerUp2.text = ".\n.\n.\n.\n.\n-----------------" + pul[str(pw2)][0]
	$Ui/PowerUpMenu/PowerUp2/card.frame = pw2
	
	$Ui/PowerUpMenu/PowerUp3.text = ".\n.\n.\n.\n.\n-----------------" + pul[str(pw3)][0]
	$Ui/PowerUpMenu/PowerUp3/card.frame = pw3
	 
	pass

func _on_power_up_1_pressed() -> void:
	
	if count == 0:
		temp = $Ui/PowerUpMenu/PowerUp1/card.frame
		set_back()
		count = 1
		
		var Game = get_parent()
		match temp:
			12:
				Game.enemies_possible.append("zombie_mine")
			13:
				Game.enemies_possible.append("sharkBuff")
			14:
				Game.enemies_possible.append("fire_imp")
		
	elif count == 1:
		$Ui/Card1.frame = temp
		power_ups_enabled[0] = str(temp)
		count = 0
		get_tree().paused = false
		$Ui/PowerUpMenu.hide()
		verify_power_ups()
	pass

func _on_power_up_2_pressed() -> void:
	if count == 0:
		temp = $Ui/PowerUpMenu/PowerUp2/card.frame
		set_back()
		count = 1
		
		var Game = get_parent()
		match temp:
			12:
				Game.enemies_possible.append("zombie_mine")
			13:
				Game.enemies_possible.append("sharkBuff")
			14:
				Game.enemies_possible.append("fire_imp")
		
	elif count == 1:
		$Ui/Card2.frame = temp
		power_ups_enabled[1] = str(temp)
		count = 0
		get_tree().paused = false
		$Ui/PowerUpMenu.hide()
		verify_power_ups()
	pass

func _on_power_up_3_pressed() -> void:
	if count == 0:
		temp = $Ui/PowerUpMenu/PowerUp3/card.frame
		set_back()
		count = 1
		
		var Game = get_parent()
		match temp:
			12:
				Game.enemies_possible.append("zombie_mine")
			13:
				Game.enemies_possible.append("sharkBuff")
			14:
				Game.enemies_possible.append("fire_imp")
		
	elif count == 1:
		$Ui/Card3.frame = temp
		power_ups_enabled[2] = str(temp)
		count = 0
		get_tree().paused = false
		$Ui/PowerUpMenu.hide()
		verify_power_ups()
	pass

func set_back():
	var pw1 = $Ui/Card1.frame
	var pw2 = $Ui/Card2.frame
	var pw3 = $Ui/Card3.frame
	
	$Ui/PowerUpMenu/PowerUp1.text = ".\n.\n.\n.\n.\n-----------------" + pul[str(pw1)][0]
	$Ui/PowerUpMenu/PowerUp1/card.frame = pw1
	
	$Ui/PowerUpMenu/PowerUp2.text = ".\n.\n.\n.\n.\n-----------------" + pul[str(pw2)][0]
	$Ui/PowerUpMenu/PowerUp2/card.frame = pw2
	
	$Ui/PowerUpMenu/PowerUp3.text = ".\n.\n.\n.\n.\n-----------------" + pul[str(pw3)][0]
	$Ui/PowerUpMenu/PowerUp3/card.frame = pw3
	pass

# tips
func _on_power_up_1_mouse_entered() -> void:
	var pw = $Ui/PowerUpMenu/PowerUp1/card.frame
	$Ui/PowerUpMenu/Info.text = pul[str(pw)][1]
	pass # Replace with function body.

func _on_power_up_2_mouse_entered() -> void:
	var pw = $Ui/PowerUpMenu/PowerUp2/card.frame
	$Ui/PowerUpMenu/Info.text = pul[str(pw)][1]
	pass # Replace with function body.

func _on_power_up_3_mouse_entered() -> void:
	var pw = $Ui/PowerUpMenu/PowerUp3/card.frame
	$Ui/PowerUpMenu/Info.text = pul[str(pw)][1]
	pass # Replace with function body.

func exited() -> void:
	$Ui/PowerUpMenu/Info.text = ""
	pass # Replace with function body.


func mouse_entered():
	mouse_in_area = true
	pass # Replace with function body.

func mouse_exited():
	mouse_in_area = false
	pass # Replace with function body.


func _on_cancel_pressed() -> void:
	count = 0
	get_tree().paused = false
	$Ui/PowerUpMenu.hide()
	verify_power_ups()
	pass
