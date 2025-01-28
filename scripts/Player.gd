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


var gravity = 500
var jump_velocity = -125
var player_speed = 100
var is_jumping = false
var word_manager
var command_handler
var countdown_time = 3
var is_sliding = false
	
func _ready():
	# Initial setup
	command_input.visible = false
	word_label.visible = false
	
	# Setup wall detector
	wall_detector.enabled = true
	
	# Setup countdown
	set_physics_process(false)  # Disable physics initially
	set_process_input(false)   # Disable input initially
	countdown_label.text = str(countdown_time)
	countdown_label.visible = true
	
	_setup_managers()
	start_countdown()
	
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
	word_label.visible = true
	if !word_label.text:
		update_word_display()

func _hide_jump_prompt():
	word_label.visible = false
	command_input.visible = false

func _input(event):
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
	if not is_on_floor():
		sprite.play("jump")
	elif velocity.x != 0 and not is_sliding:
		sprite.play("run")
	elif is_sliding and velocity.x != 0:
		sprite.play("slide")
	else:
		sprite.play("idle")

func jump():
	print("jumping")
	if is_on_floor():
		velocity.y = jump_velocity
		is_jumping = true
		audio_player.play_FX(JumpAudio, 12)
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

	
