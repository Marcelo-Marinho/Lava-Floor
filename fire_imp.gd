extends CharacterBody2D

const SPEED = 50
@onready var plyr = get_tree().root.get_node("Game").get_node("Plyr")
var HP = 1

func _ready() -> void:
	randomize()
	if Global.animations:
		$walk.play("walk")
	if Global.particles:
		$explosion.emitting = true
	$Sprite.play("default")
	
	var id_txt = randi_range(0, 2)
	var txt = "res://imgs/fire_imp_"+str(id_txt)+".png"
	$sprt.texture = load(txt)

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
		velocity = SPEED * global_position.direction_to(plyr.global_position)
		
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
		queue_free()


func _on_area_dmg_body_entered(body: Node2D) -> void:
	if body.is_in_group("plyr"):
		body.dmg(2.5)
	pass # Replace with function body.
