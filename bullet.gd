extends Area2D

const SPEED = 75
var direction = Vector2.RIGHT

var insta_kill = false
var piercing   = false

func _ready() -> void:
	if Global.particles:
		$smooth.emitting = true

func _process(delta: float) -> void:
	translate(direction * SPEED * delta)
	pass


func _on_not_screen_exited() -> void:
	call_deferred("queue_free")
	pass # Replace with function body.


func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("Enemy"):
		$death.pitch_scale = randf_range(0.9, 1.1)
		$death.play()
		
		var dmg_blt = [1, 1, 1, 1, 2, 1, 1, 1, 2, 5]
		dmg_blt.shuffle()
		var damage = dmg_blt[0]
		body.dmg(damage)
		if insta_kill:
			damage = 999
			body.dmg(999)
		
		if damage == 1:
			$dmg.texture = load("res://imgs/dmg0.png")
		elif damage == 2:
			$dmg.texture = load("res://imgs/dmg1.png")
		elif damage == 5:
			$dmg.texture = load("res://imgs/dmg2.png")
		elif damage == 999:
			$dmg.texture = load("res://imgs/dmg3.png")
		$dmg.emitting = true
		
		if not piercing:
			$area.set_deferred("disable", true)
			#$area.disabled = true
			set_deferred("monitoring", false)
			
			$sprite.visible = false
	pass # Replace with function body.


func _on_death_finished() -> void:
	queue_free()
	pass # Replace with function body.
