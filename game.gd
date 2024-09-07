extends Node2D

func _ready() -> void:
	if Global.music:
		$bgMusic.play()
	colorChange(Global.color)
	Global.last_score = 0
	
	
	#Vector2i(26, 19)
	#print($floor.get_cell_atlas_coords(0, Vector2i(26, 19)))
	pass
	
func colorChange(c):
	var cor = Color(1,1,1)
	
	if c == "Orange":
		cor = Color(0.935, 0.563, 0.09)
	elif c == "Blue":
		cor = Color(0.205, 0.737, 0.84)
	elif c == "Purple":
		cor = Color(0.666, 0.351, 0.982)
	else:
		pass
		
	modulate = cor
	$Plyr/Ui/border.modulate = cor
	$Plyr/Ui/HpBar/icon.modulate = cor
	
	if not Global.border:
		$Plyr/construct_area/border.queue_free()
	pass


func _on_timer_timeout() -> void:
	randomize()
	
	var enemies_possible = ["fire_imp", "zombie_mine", "sharkBuff"]
	enemies_possible.shuffle()
	var enemy = load("res://" + enemies_possible[0] + ".tscn")
		
	var obj = enemy.instantiate()
	var px = randi_range(26, 72)
	var py = randi_range(19, 50)
	var pos_sapwn = $floor.map_to_local(Vector2i(px, py))
	obj.global_position = pos_sapwn
	call_deferred("add_child", obj)
	
	$Timer.start(randf_range(0.5, 2.5))
	pass # Replace with function body.


func _on_bg_music_finished() -> void:
	$bgMusic.play()
	pass # Replace with function body.
