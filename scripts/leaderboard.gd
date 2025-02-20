extends Control

var scores = []

# Called when the node enters the scene tree for the first time.
func _ready():
	# Set up the container and nodes for proper display
	_setup_ui()
	load_scores()
	display_leaderboard()

func _setup_ui():
	# Make sure the UI is properly centered and sized
	anchor_right = 1
	anchor_bottom = 1

	# Clear any existing children to avoid duplication
	for child in get_children():
		if child.name != "HomeButton" and child.name != "TitleLabel":
			child.queue_free()
	
	# If the main container doesn't exist, create it
	if not has_node("MainContainer"):
		var main_container = VBoxContainer.new()
		main_container.name = "MainContainer"
		main_container.anchor_right = 1
		main_container.anchor_bottom = 1
		main_container.add_theme_constant_override("margin_top", 50)
		main_container.size_flags_horizontal = SIZE_EXPAND_FILL
		main_container.size_flags_vertical = SIZE_EXPAND_FILL
		main_container.add_theme_constant_override("separation", 20)
		add_child(main_container)
		
		# Title label (if not already present)
		if not has_node("TitleLabel"):
			var title = Label.new()
			title.name = "TitleLabel"
			title.text = "LEADERBOARD"
			title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
			title.add_theme_font_size_override("font_size", 40)
			title.modulate = Color("7fff00") # Bright green color
			title.position = Vector2(200, 100)
			main_container.add_child(title)
		
		# Score container with margins
		var score_margin = MarginContainer.new()
		score_margin.name = "ScoreMarginContainer"
		score_margin.add_theme_constant_override("margin_left", 100)
		score_margin.add_theme_constant_override("margin_right", 100)
		score_margin.add_theme_constant_override("margin_top", 20)
		score_margin.add_theme_constant_override("margin_bottom", 20)
		main_container.add_child(score_margin)
		
		var score_container = VBoxContainer.new()
		score_container.name = "ScoreContainer"
		score_container.size_flags_horizontal = SIZE_EXPAND_FILL
		score_container.size_flags_vertical = SIZE_EXPAND_FILL
		score_margin.add_child(score_container)
		
		# Make the home button positioned at the bottom center if it doesn't exist
		if not has_node("HomeButton"):
			var home_button = Button.new()
			home_button.name = "HomeButton"
			home_button.text = "HOME"
			home_button.size_flags_horizontal = SIZE_SHRINK_CENTER
			home_button.custom_minimum_size = Vector2(200, 50)
			home_button.connect("pressed", _on_home_pressed)
			
			var button_margin = MarginContainer.new()
			button_margin.add_theme_constant_override("margin_bottom", 50)
			button_margin.size_flags_horizontal = SIZE_EXPAND_FILL
			button_margin.size_flags_vertical = SIZE_SHRINK_END
			button_margin.add_child(home_button)
			
			main_container.add_child(button_margin)

# Load scores from the file
func load_scores():
	scores.clear()
	
	var file = FileAccess.open("res://data/scores.txt", FileAccess.READ)
	if file:
		while !file.eof_reached():
			var line = file.get_line()
			if line.strip_edges() != "":
				var data = line.split(",", false)
				if data.size() >= 3:
					# Trim any whitespace from the data
					var name = data[0].strip_edges()
					var level = int(data[1].strip_edges())
					var time_str = data[2].strip_edges()
					
					# Parse time in MM:SS format
					var total_time = 0.0
					var time_parts = time_str.split(":")
					
					if time_parts.size() == 2:
						var minutes = int(time_parts[0])
						var seconds = int(time_parts[1])
						total_time = (minutes * 60) + seconds
					
					scores.append({
						"name": name,
						"level": level,
						"time": total_time
					})
		
		# Sort scores by level (descending) then by time (ascending)
		scores.sort_custom(func(a, b):
			if a.level != b.level:
				return a.level > b.level
			return a.time < b.time
		)

# Display the leaderboard in the UI
func display_leaderboard():
	var score_container = get_node("MainContainer/ScoreMarginContainer/ScoreContainer")
	if not score_container:
		push_error("Score container not found")
		return
	
	# Clear existing entries
	for child in score_container.get_children():
		child.queue_free()
	
	# Create panel container for score entries
	var panel = PanelContainer.new()
	panel.add_theme_stylebox_override("panel", StyleBoxFlat.new())
	panel.get_theme_stylebox("panel", "PanelContainer").bg_color = Color(0.1, 0.2, 0.1, 0.8)
	panel.get_theme_stylebox("panel", "PanelContainer").border_color = Color(0.8, 1.0, 0.8, 0.5)
	panel.get_theme_stylebox("panel", "PanelContainer").border_width_left = 2
	panel.get_theme_stylebox("panel", "PanelContainer").border_width_right = 2
	panel.get_theme_stylebox("panel", "PanelContainer").border_width_top = 2
	panel.get_theme_stylebox("panel", "PanelContainer").border_width_bottom = 2
	score_container.add_child(panel)
	
	var entries_container = VBoxContainer.new()
	entries_container.add_theme_constant_override("separation", 5)
	panel.add_child(entries_container)
	
	# Add header
	var header = create_score_row("PLAYER", "LEVEL", "TIME", true)
	entries_container.add_child(header)
	
	# Add separator
	var separator = HSeparator.new()
	separator.add_theme_constant_override("separation", 10)
	entries_container.add_child(separator)
	
	# No scores case
	if scores.size() == 0:
		var no_scores = Label.new()
		no_scores.text = "No scores available yet!"
		no_scores.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		no_scores.modulate = Color(0.8, 0.8, 0.8)
		entries_container.add_child(no_scores)
		return
	
	# Add score entries (limit to top 10 for better display)
	var max_entries = min(scores.size(), 10)
	for i in range(max_entries):
		var score = scores[i]
		var row = create_score_row(
			score.name,
			str(score.level),
			format_time(score.time)
		)
		entries_container.add_child(row)

# Create a score row with consistent styling
func create_score_row(name_text, level_text, time_text, is_header = false):
	var item = HBoxContainer.new()
	item.size_flags_horizontal = SIZE_EXPAND_FILL
	
	var name_label = Label.new()
	name_label.text = name_text
	name_label.size_flags_horizontal = SIZE_EXPAND_FILL
	name_label.size_flags_stretch_ratio = 2
	
	var level_label = Label.new()
	level_label.text = level_text
	level_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	level_label.size_flags_horizontal = SIZE_EXPAND_FILL
	level_label.size_flags_stretch_ratio = 1
	
	var time_label = Label.new()
	time_label.text = time_text
	time_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	time_label.size_flags_horizontal = SIZE_EXPAND_FILL
	time_label.size_flags_stretch_ratio = 1.5
	
	item.add_child(name_label)
	item.add_child(level_label)
	item.add_child(time_label)
	
	if is_header:
		name_label.add_theme_font_size_override("font_size", 18)
		level_label.add_theme_font_size_override("font_size", 18)
		time_label.add_theme_font_size_override("font_size", 18)
		name_label.modulate = Color(0.7, 1.0, 0.7)
		level_label.modulate = Color(0.7, 1.0, 0.7)
		time_label.modulate = Color(0.7, 1.0, 0.7)
	else:
		# Add alternating row colors
		var background = ColorRect.new()
		background.show_behind_parent = true
		background.size_flags_horizontal = SIZE_EXPAND_FILL
		background.size_flags_vertical = SIZE_EXPAND_FILL
		if (item.get_index() % 2) == 1:
			background.color = Color(0.15, 0.15, 0.15, 0.4)
		else:
			background.color = Color(0.1, 0.1, 0.1, 0.0)
		item.add_child(background)
		background.show_behind_parent = true
	
	return item

# Format time to mm:ss.ms
func format_time(time_seconds):
	var minutes = time_seconds / 60
	var seconds = time_seconds % 60
	return "%02d:%02d" % [minutes, seconds]


# Navigate back to homepage
func _on_home_pressed():
	LevelCounter._goto_homepage()
