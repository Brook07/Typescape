extends Node

@onready var level = 0
@onready var player_name = ""
@onready var level_1_completion_time = "00:00"
@onready var level_2_completion_time = "00:00"
@onready var level_3_completion_time = "00:00"

func _goto_homepage() :
	get_tree().change_scene_to_file("res://scenes/Home_Page.tscn")
