extends Node

@onready var level = 0
@onready var player_name = ""
func _goto_homepage() :
	get_tree().change_scene_to_file("res://scenes/Home_Page.tscn")
