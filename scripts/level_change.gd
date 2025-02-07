extends Area2D

const FILE_BEGIN = "res://scenes/levels/level_"

func _on_body_entered(body: Node2D) -> void:
	print("changing  sd scene")
	if body.is_in_group("player"):
		print ("door collided with player")
		if LevelCounter.level == 1:
			LoadingScreen.change_scene("res://scenes/level_2.tscn")
		
		#var current_scene_file = get_tree().current_scene.scene_file_path
		#var next_scene_file = current_scene_file.to_int() + 1
		#
		#var next_level_path = FILE_BEGIN + str(next_scene_file) + ".tscn"
		#LoadingScreen.change_scene(next_level_path)
