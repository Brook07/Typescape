extends Sprite2D
@onready var buttonPressed = preload("res://assets/Audio/click.wav")
func _ready():
	$AnimatedSprite2D.play()  

func _on_quit_pressed() -> void:
	audio_player.play_FX(buttonPressed)
	get_tree().quit()  
