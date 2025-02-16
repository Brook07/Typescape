extends Node

class_name WordManager

var jump_words = []  # Remove type hint for Array[String] as it's causing issues
var current_word = ""
var previous_word = ""
var WORDS_FILE_PATH

func _ready():
	load_words()
	pick_random_word()

func load_words():
	if LevelCounter.level == 1:
		WORDS_FILE_PATH = "res://data/easy_words.txt"
	elif LevelCounter.level == 2:
		WORDS_FILE_PATH = "res://data/medium_words.txt"
	elif LevelCounter.level == 3:
		WORDS_FILE_PATH = "res://data/hard_words.txt"
	else:
		WORDS_FILE_PATH = "res://data/jump.txt"
	
	if FileAccess.file_exists(WORDS_FILE_PATH):
		print("file found")
		var file = FileAccess.open(WORDS_FILE_PATH, FileAccess.READ)
		while !file.eof_reached():
			var line = file.get_line().strip_edges()
			if line:
				jump_words.append(line)
	else:
		push_error("Words file not found at: " + WORDS_FILE_PATH)

func pick_random_word() -> String:
	#print("picking words")
	if jump_words.is_empty():
		#print(jump_words)
		return ""
	#print(jump_words)
	var new_word = ""
	# Keep trying until we get a different word
	while new_word == "" or new_word == current_word:
		new_word = jump_words[randi() % jump_words.size()]
	
	previous_word = current_word
	current_word = new_word
	print("current words : ", current_word)
	return current_word

func check_word(input: String) -> bool:
	return input.to_lower() == current_word.to_lower()
