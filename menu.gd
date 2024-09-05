extends Control

var file = "langs/" + Global.lang + ".json"
var json_as_text = FileAccess.get_file_as_string(file)
var json_as_dict = JSON.parse_string(json_as_text)

func _ready() -> void:
	
	if json_as_dict:
		#print(json_as_dict["Hud"]["Score"])
		pass
	
	
	if Global.last_score <= Global.best_score:
		$Score.text = "Last Score: "+str(Global.last_score)+"
Best Score: "+str(Global.best_score)
	else:
		Global.best_score = Global.last_score
		$yeeey.emitting = true
		$Score.text = "Last Score: "+str(Global.last_score)+"
[rainbow]Best Score: "+str(Global.best_score)+"[/rainbow]"

	$Particles.button_pressed = Global.particles
	$Border.button_pressed = Global.border
	$Animations.button_pressed = Global.animations
	$Music.button_pressed = Global.music
	pass

func _on_color_item_selected(index: int) -> void:
	Global.color = $Color.get_item_text(index)
	color(Global.color)
	pass # Replace with function body.

func color(c):
	if c == "Orange":
		$preview.self_modulate = Color(0.935, 0.563, 0.09)
	elif c == "Blue":
		$preview.self_modulate = Color(0.205, 0.737, 0.84)
	elif c == "Purple":
		$preview.self_modulate = Color(0.666, 0.351, 0.982)
	else:
		$preview.self_modulate = Color(1,1,1)
	pass


func _on_particles_pressed() -> void:
	Global.particles = $Particles.button_pressed
	pass # Replace with function body.


func _on_play_pressed() -> void:
	get_tree().change_scene_to_file("res://game.tscn")
	pass # Replace with function body.


func _on_lights_pressed() -> void:
	Global.border = $Border.button_pressed
	pass # Replace with function body.


func _on_animations_pressed() -> void:
	print("pressed")
	Global.animations = $Animations.button_pressed
	pass # Replace with function body.


func _on_music_pressed() -> void:
	Global.music = $Music.button_pressed
	pass # Replace with function body.
