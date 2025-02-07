extends Control

@onready var control = $"."  
@onready var progressbar = $ProgressBar  
@onready var tips = $tips  
var loading_status: int  
var scene_path: String  
const THREAD_LOAD_IN_PROGRESS = 0  
const THREAD_LOAD_COMPLETED = 1  
const THREAD_LOAD_FAILED = 2  

func _ready():
	control.hide()
	set_process(false)
	scene_path = ""  # Ensure scene_path is reset when the scene is ready

func load_scene(path: String) -> void:
	# Reset loading state before loading new scene
	scene_path = path  # Set the path for the new scene
	control.show()  # Show loading control
	progressbar.value = 0  # Reset progress bar
	loading_status = THREAD_LOAD_IN_PROGRESS  # Reset loading status
	set_process(true)  # Allow the _process to handle loading

	# Step 1: Change to the loading screen scene
	get_tree().change_scene_to_file("res://scenes/loading screen.tscn")  

	# Step 2: Start loading the new scene asynchronously
	print("Loading...")  
	await get_tree().create_timer(1.0).timeout  # Optional delay to show loading screen
	var error = ResourceLoader.load_threaded_request(scene_path)
	if error != OK:
		print("Error: Failed to start threaded load.")
		set_process(false)
		control.hide()
		return
	
func _process(delta):
	if scene_path == "":
		return
	loading_status = ResourceLoader.load_threaded_get_status(scene_path)
	match loading_status:
		THREAD_LOAD_IN_PROGRESS:
			progressbar.value += delta * 100  
		THREAD_LOAD_COMPLETED:
			var scene_resource = ResourceLoader.load_threaded_get(scene_path)
			if scene_resource:
				var new_scene = scene_resource.instantiate()
				var root = get_tree().root
				var current_scene = root.get_child(root.get_child_count() - 1)
				root.call_deferred("add_child", new_scene)  
				current_scene.queue_free()
				set_process(false)
				scene_path = ""
		THREAD_LOAD_FAILED:
			print("Error: Scene loading failed")
			set_process(false)
			scene_path = ""

func change_scene(path: String) -> void:
	# Ensure a clean state and reload the scene
	control.hide()  # Hide the control before switching scenes
	progressbar.value = 0  # Reset progress bar
	loading_status = THREAD_LOAD_IN_PROGRESS  # Reset loading status
	# Load the new scene
	load_scene(path)
