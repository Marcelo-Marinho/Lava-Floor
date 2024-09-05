extends CharacterBody2D

var SPEED = 20
@onready var plyr = get_tree().root.get_node("Game").get_node("Plyr")
@onready var tile = get_tree().root.get_node("Game").get_node("floor")
var pos = Vector2.ZERO
var HP = 2

func _ready() -> void:
	if Global.animations:
		$walk.play("walk")
	if Global.particles:
		$explosion.emitting = true
	$Sprite.play("default")

func _process(_delta: float) -> void:
	
	if $Sprite.current_animation == "default":
		$col.disabled = true
	else:
		$col.disabled = false
	
	pos = tile.local_to_map(global_position)
	if tile.get_cell_atlas_coords(0, pos) == Vector2i.ZERO:
		SPEED = 0
		$Sprite.play("mining")
	else:
		SPEED = 20
		
	if $HP_bar.value > HP:
		if Global.animations:
			$HP_bar.visible = true
			$HP_bar.value -= 0.1
	else:
		$HP_bar.visible = false
		
	move_and_slide()
	pass

func _on_spawn_timeout() -> void:
	if plyr != null:
		velocity = SPEED * global_position.direction_to(plyr.global_position)
		
		if plyr.global_position.x > global_position.x:
			$sprt.flip_h = false
		elif plyr.global_position.x < global_position.x:
			$sprt.flip_h = true
	pass # Replace with function body.





func _on_area_dmg_body_entered(body: Node2D) -> void:
	if body.is_in_group("plyr"):
		body.dmg(5)
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
		queue_free()


func _on_sprite_animation_finished(anim_name: StringName) -> void:
	if anim_name == "mining":
		
		$Sprite.play("default")
		tile.set_cell(0, pos, 0, Vector2i(1, 0))
	pass # Replace with function body.
