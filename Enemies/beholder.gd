extends CharacterBody2D

var speed = 25
@onready var plyr = get_tree().root.get_node("Game").get_node("Plyr")
var HP = 10
var spawn_protection = true

var laser = false

var possible_drops = ["res://drops/card_drop.tscn", "res://drops/wood_drop.tscn"]

func _ready() -> void:
	randomize()
	if Global.animations:
		$walk.play("walk")
	if Global.particles:
		$explosion.emitting = true
	$Sprite.play("default")
	
	#var id_txt = randi_range(0, 2)
	#var txt = "res://imgs/fire_imp_"+str(id_txt)+".png"
	#$sprt.texture = load(txt)

func _process(_delta: float) -> void:
	move_and_slide()
	
	if $HP_bar.value > HP:
		if Global.animations:
			$HP_bar.visible = true
			$HP_bar.value -= 0.1
	else:
		$HP_bar.visible = false
	pass

func _on_spawn_timeout() -> void:
	if plyr != null:
		randomize()
		velocity = speed * global_position.direction_to(plyr.global_position)
		
		$laser.look_at(plyr.global_position)
		spawn_protection = false
		
		var choose = randi_range(0, 20)
		if choose == 0:
			$Sprite.play("shooting")
			$spawn.stop()
		
		if plyr.global_position.x > global_position.x:
			$sprt.flip_h = false
		elif plyr.global_position.x < global_position.x:
			$sprt.flip_h = true
	pass # Replace with function body.
	
func dmg(x):
	HP -= x
	
	
	
	if not Global.animations:
		$HP_bar.visible = true
		$HP_bar.value = HP
		await get_tree().create_timer(2).timeout
		$HP_bar.visible = false
	
	if HP <= 0:
		Global.last_score += 1
		var choose_drop = randi_range(0, len(possible_drops) - 1)
		
		var p = randi_range(0, 99)
		
		if possible_drops[choose_drop] != null and p >= 90:
			var drop = load(str(possible_drops[choose_drop]))
			var obj_drop = drop.instantiate()
			obj_drop.global_position = global_position
			get_parent().call_deferred("add_child", obj_drop)
			
		queue_free()


func _on_area_dmg_body_entered(body: Node2D) -> void:
	if body.is_in_group("plyr"):
		if spawn_protection:
			dmg(999)
		else:
			body.dmg(0)
	pass # Replace with function body.


func _on_area_dmg_area_entered(area: Area2D) -> void:
	if area.is_in_group("plyr"):
		speed = 0
		if spawn_protection:
			dmg(999)
	pass # Replace with function body.


func _on_sprite_animation_finished(anim_name: StringName) -> void:
	if anim_name == "shooting":
		$Sprite.play("default")
		$spawn.start(1.0)
	pass # Replace with function body.


func _on_area_dmg_area_exited(area: Area2D) -> void:
	if area.is_in_group("plyr"):
		speed = 25
	pass # Replace with function body.


func _on_laser_body_entered(body: Node2D) -> void:
	if body.is_in_group("plyr"):
		if spawn_protection:
			dmg(999)
		else:
			body.dmg(1)
	pass # Replace with function body.
