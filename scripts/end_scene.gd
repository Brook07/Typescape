extends Control

@onready var easy_label = $easy_time
@onready var medium_label = $medium_time
@onready var hard_label = $hard_time

@onready var easy_time = str(LevelCounter.level_1_completion_time)
@onready var medium_time = str(LevelCounter.level_2_completion_time)
@onready var hard_time = str(LevelCounter.level_3_completion_time)



func _ready():
	easy_label.text = easy_time
	medium_label.text = medium_time
	hard_label.text = hard_time


func _process(delta):
	pass


func _on_home_pressed():
	LevelCounter._goto_homepage()
