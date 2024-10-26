extends Node2D

@export var enemies_possible = ["fire_imp"]

var first_power_up = false

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
	elif c == "Green":
		cor = Color(0.38, 0.584, 0)
	else:
		pass
		
	modulate = cor
	$Plyr/Ui/border.modulate = cor
	$Plyr/Ui/HpBar/icon.modulate = cor
	$Plyr/Ui/woods/icon.modulate = cor
	
	$Plyr/Ui/Card1.modulate = cor
	$Plyr/Ui/Card2.modulate = cor
	$Plyr/Ui/Card3.modulate = cor
	
	$Plyr/Ui/PowerUpMenu/PowerUp1/card.modulate = cor
	$Plyr/Ui/PowerUpMenu/PowerUp2/card.modulate = cor
	$Plyr/Ui/PowerUpMenu/PowerUp3/card.modulate = cor
	
	$Plyr/Ui/PowerUpMenu/PowerUp1/subcard.modulate = cor
	$Plyr/Ui/PowerUpMenu/PowerUp2/subcard.modulate = cor
	$Plyr/Ui/PowerUpMenu/PowerUp3/subcard.modulate = cor
	$Plyr/Ui/tool.modulate = cor
	
	if not Global.border:
		$Plyr/construct_area/border.queue_free()
	pass


func _on_timer_timeout() -> void:
	randomize()
	
	enemies_possible.shuffle()
	var enemy = load("res://Enemies/" + enemies_possible[0] + ".tscn")
		
	var obj = enemy.instantiate()
	var px = randi_range(26, 72)
	var py = randi_range(19, 50)
	var pos_sapwn = $floor.map_to_local(Vector2i(px, py))
	obj.global_position = pos_sapwn
	call_deferred("add_child", obj)
	
	if Global.last_score < 25:
		$Timer.start(randf_range(0.5, 2.5))
		
	elif Global.last_score >= 25 and Global.last_score < 50:
		$Timer.start(randf_range(0.5, 2))
		if not first_power_up:
			$Plyr.power_up()
			first_power_up = true
		
	elif Global.last_score >= 50 and Global.last_score < 100:
		$Timer.start(randf_range(0.5, 1.75))
		if not enemies_possible.has("zombie_mine"):
			enemies_possible.append("zombie_mine")
			
	elif Global.last_score >= 100 and Global.last_score < 500:
		$Timer.start(randf_range(0.25, 1.75))
		if not enemies_possible.has("sharkBuff"):
			enemies_possible.append("sharkBuff")
		
	elif Global.last_score >= 500 and Global.last_score < 1000:
		$Timer.start(randf_range(0.25, 1.5))
		
	elif Global.last_score >= 1000 and Global.last_score < 1500:
		$Timer.start(randf_range(0.25, 1.25))
		if not enemies_possible.has("beholder"):
			enemies_possible.append("beholder")
			
	else:
		$Timer.start(randf_range(0.25, 1.0))
		
	pass # Replace with function body.


func _on_bg_music_finished() -> void:
	$bgMusic.play()
	pass # Replace with function body.


func _on_menu_music_finished() -> void:
	$menuMusic.play()
	pass # Replace with function body.
