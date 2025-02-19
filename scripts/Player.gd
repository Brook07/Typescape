# Player.gd
extends CharacterBody2D
@onready var JumpAudio = preload("res://assets/Audio/jump.wav")
@onready var sprite = $AnimatedSprite2D
@onready var command_input = $CommandInputField
@onready var wall_detector = $WallDetector
@onready var ceiling_detector = $CeilingDetector
@onready var word_label = $WordLabel
@onready var timer = $Timer
@onready var startup_timer = $Timer
@onready var countdown_label = $CountdownLabel
@onready var slider_coillsion = $slider_collision
@onready var normal_collider = $CollisionShape2D
@onready var pause_menu_display = $"Pause Menu"
@onready var game_timer_label = $CanvasLayer/GameTimerLabel
@onready var game_timer = $CanvasLayer/gametimer
@onready var canvas_layer = $CanvasLayer

var gravity = 500
var jump_velocity = -125
var player_speed = 100
var is_jumping = false
var word_manager
var command_handler
var countdown_time = 3
var is_sliding = false
var is_paused = false
var elapsed_time = 0
var player_name = LevelCounter.player_name

func _ready():
	audio_player.play_music_background()
	
	# Initial setup
	command_input.visible = false
	word_label.visible = false
	
	# Setup wall detector
	wall_detector.enabled = true
	
	# Setup countdown
	set_physics_process(false)  
	set_process_input(false)   
	countdown_label.text = str(countdown_time)
	countdown_label.visible = true
	game_timer_label.visible = false
	game_timer.timeout.connect(_on_gametimer_timeout)
	
	#pause menu setup
	pause_menu_display.resume_pressed.connect(on_resume_clicked)
	pause_menu_display.quit_pressed.connect(on_quit_pressed)
	pause_menu_display.restart_pressed.connect(_on_restart_pressed)
	
	var level_change = get_node("../Area2d") 
	if level_change:
		level_change.level_1_completed.connect(_on_level_completed.bind(1))
		level_change.level_2_completed.connect(_on_level_completed.bind(2))
		level_change.level_3_completed.connect(_on_level_completed.bind(3))
	
	game_timer.wait_time = 1.0 
	game_timer.one_shot = false
	game_timer_label.text = "Time: 0"
	elapsed_time = 0


	_setup_managers()
	start_countdown()

func _on_level_completed(level_number: int):
	var score_file = FileAccess.open("res://data/scores.txt", FileAccess.READ_WRITE)
	if score_file == null:
		score_file = FileAccess.open("res://data/scores.txt", FileAccess.WRITE)
	
	# Move to end of file for appending
	score_file.seek_end()
	 # Format time as MM:SS
	var minutes = elapsed_time / 60
	var seconds = elapsed_time % 60
	var time_str = "%02d:%02d" % [minutes, seconds]
	if level_number == 1:
		LevelCounter.level_1_completion_time = time_str 
	if level_number == 2:
		LevelCounter.level_2_completion_time = time_str
	if level_number == 3:
		LevelCounter.level_3_completion_time = time_str
	# Write score in format: PlayerName,Level,Time
	var score_line = "%s,Level %d,%s\n" % [player_name, level_number, time_str]
	score_file.store_string(score_line)
	
	score_file.close()

func _on_gametimer_timeout():
	elapsed_time += 1
	var minutes = elapsed_time / 60
	var seconds = elapsed_time % 60
	game_timer_label.text = "Time: %02d:%02d" % [minutes, seconds]

func on_resume_clicked():
		Engine.time_scale = 1
		pause_menu_display.hide()
		set_process_input(true)  
		is_paused = false

func _on_restart_pressed():
	Engine.time_scale = 1
	pause_menu_display.hide()
	set_process_input(true)  
	if LevelCounter.level == 1:
		get_tree().change_scene_to_file("res://scenes/levels/level_1.tscn")
	if LevelCounter.level == 2:
		get_tree().change_scene_to_file("res://scenes/levels/level_2.tscn")
	if LevelCounter.level == 3:
		get_tree().change_scene_to_file("res://scenes/levels/level_3.tscn")

func on_quit_pressed():	
	Engine.time_scale = 1
	pause_menu_display.hide()
	set_process_input(true) 
	#LoadingScreen.load_scene("res://scenes/Home_Page.tscn")
	LevelCounter._goto_homepage()  

func start_countdown():
	startup_timer.wait_time = 1
	startup_timer.start()

func _on_timer_timeout():
	countdown_time -= 1
	
	if countdown_time > 0:
		countdown_label.text = str(countdown_time)
		startup_timer.start()
	else:
		countdown_label.text = "GO!"
		await get_tree().create_timer(0.5).timeout
		# Enable player control
		set_physics_process(true)
		set_process_input(true)
		countdown_label.visible = false
		game_timer_label.visible = true
		game_timer.start() 
		startup_timer.stop()

func _setup_managers():
	word_manager = preload("res://scripts/WordManager.gd").new()
	command_handler = preload("res://scripts/CommandHandler.gd").new()
	command_handler.set_player(self)
	add_child(word_manager)
	word_manager._ready()
	update_word_display()

func _physics_process(delta):
	
	_apply_gravity(delta)
	_handle_movement()
	_show_jump_prompt()
	_check_wall_ahead()
	move_and_slide()
	_update_animation()

func check_pause_menu():
	if Input.is_action_pressed("pause"):
		if is_paused:
			set_process_input(false)   
			pause_menu_display.hide()
			Engine.time_scale = 1
		else:
			set_process_input(false)   
			pause_menu_display.show()
			Engine.time_scale = 0
		is_paused = !is_paused
	
	
	
func _apply_gravity(delta):
	if not is_on_floor():
		velocity.y += gravity * delta

func _handle_movement():
	velocity.x = player_speed	

func _check_wall_ahead():
	if wall_detector.is_colliding() :
		var collider = wall_detector.get_collider()
		return true
	else:
		return false

func _check_ceiling_ahead():
	if ceiling_detector.is_colliding() :
		var collider = ceiling_detector.get_collider()
		return true
	else:
		return false

func _show_jump_prompt():
	if is_paused:
		return
	word_label.visible = true
	if !word_label.text:
		update_word_display()

func _hide_jump_prompt():
	if is_paused:
		return
	word_label.visible = false
	command_input.visible = false

func _input(event):
	check_pause_menu()
	if event.is_action_pressed("ui_accept"):
		_toggle_command_input()

func _toggle_command_input():
	command_input.visible = !command_input.visible
	if command_input.visible:
		command_input.grab_focus()
	else:
		if command_input.text:
			command_handler.process_command(command_input.text)
			command_input.text = ""

func _update_animation():
	if is_paused:
		sprite.play("idle")
	if not is_on_floor():
		sprite.play("jump")
	elif velocity.x != 0 and not is_sliding:
		sprite.play("run")
	elif is_sliding and velocity.x != 0:
		sprite.play("slide")
	else:
		sprite.play("idle")

func jump():
	if is_paused:
		return
	print("jumping")
	if is_on_floor():
		velocity.y = jump_velocity
		is_jumping = true
		audio_player.play_FX(JumpAudio, 3)
		sprite.play("jump")

func slide():
	print("sliding")
	if is_on_floor():
		is_sliding = true
		slider_coillsion.disabled = false
		normal_collider.disabled = true
		sprite.play("slide")
		
		# Create a timer to reset sliding after some second
		var slide_timer = get_tree().create_timer(0.6)
		slide_timer.timeout.connect(func():
			is_sliding = false
			slider_coillsion.disabled = true
			normal_collider.disabled = false
			sprite.play("run") 
		)
	
func update_word_display():
	var new_word = word_manager.pick_random_word()
	word_label.text = new_word
