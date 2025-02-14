extends Button
@onready var buttonPressed = preload("res://assets/Audio/click.wav")

func _on_Start_pressed():
	audio_player.playFX(buttonPressed)
	get_tree().change_scene_to_file("res://scenes/levels/level_3.tscn")
