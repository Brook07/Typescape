extends Area2D

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		print ("door collided with player")
		LevelCounter.level += 1
		if LevelCounter.level == 1:
			get_tree().change_scene_to_file("res://scenes/levels/level_1.tscn")
		if LevelCounter.level == 2:
			get_tree().change_scene_to_file("res://scenes/levels/level_2.tscn")
		if LevelCounter.level == 3:
			get_tree().change_scene_to_file("res://scenes/levels/level_3.tscn")
