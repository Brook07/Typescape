extends Button
@onready var buttonPressed = preload("res://assets/Audio/click.wav")
func _ready():
	audio_player.play_music_background()
	pass

func _on_Start_pressed():
	audio_player.play_FX(buttonPressed, 3)
	get_tree().change_scene_to_file("res://scenes/levels.tscn")
