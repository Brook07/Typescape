extends Area2D
signal level_1_completed
signal level_2_completed
signal level_3_completed


func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		print ("door collided with player")
		if LevelCounter.level == 1:
			emit_signal("level_1_completed")
		elif LevelCounter.level == 2:
			emit_signal("level_2_completed")
		elif LevelCounter.level == 3:
			emit_signal("level_3_completed")
		else:
			print("completed")
		LevelCounter.level += 1
		if LevelCounter.level == 1:
			get_tree().change_scene_to_file("res://scenes/levels/level_1.tscn")
		elif LevelCounter.level == 2:
			get_tree().change_scene_to_file("res://scenes/levels/level_2.tscn")
		elif LevelCounter.level == 3:
			get_tree().change_scene_to_file("res://scenes/levels/level_3.tscn")
		else:
			get_tree().change_scene_to_file("res://scenes/end_scene.tscn")
