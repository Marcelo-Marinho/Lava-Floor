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
		
		body.dmg(1)
		if insta_kill:
			body.dmg(9999)
		
		if not piercing:
			$area.set_deferred("disable", true)
			#$area.disabled = true
			set_deferred("monitoring", false)
			
			$sprite.visible = false
	pass # Replace with function body.


func _on_death_finished() -> void:
	queue_free()
	pass # Replace with function body.
