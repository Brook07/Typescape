extends AudioStreamPlayer2D

const background_music = preload("res://assets/Audio/main menu.wav")

func _play_music(music:AudioStream, volume = 0.0):
	if stream == music:
			return
	stream = music
	volume_db = volume 
	play()

func play_music_background():
	_play_music(background_music)

func play_FX(stream:AudioStream, volume = 0.0):
	var fx_player = AudioStreamPlayer2D.new()
	fx_player.stream = stream
	fx_player.name = "FX_PLAYER"
	fx_player.volume_db = volume
	add_child(fx_player)	
	fx_player.play()
	await fx_player.finished 
	fx_player.queue_free()
