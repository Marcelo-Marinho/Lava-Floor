extends Area2D

func _ready() -> void:
	$anim.play("start")
	pass

func _on_time_to_delete_timeout() -> void:
	queue_free()
	pass

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("plyr"):
		var qntd = randi_range(1, 5)
		body.get_wood(qntd)
		queue_free()
	pass

func _on_anim_animation_finished(anim_name: StringName) -> void:
	if anim_name == "start":
		$anim.play("idle")
	pass
