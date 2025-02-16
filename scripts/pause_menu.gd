extends Control
signal resume_pressed
signal restart_pressed
signal quit_pressed

var buttonPressed = preload("res://assets/Audio/click.wav")
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_resume_pressed():
	audio_player.play_FX(buttonPressed)
	resume_pressed.emit()


func _on_quit_pressed():
	audio_player.play_FX(buttonPressed)
	quit_pressed.emit()


func _on_restart_pressed():
	audio_player.play_FX(buttonPressed)
	restart_pressed.emit()
