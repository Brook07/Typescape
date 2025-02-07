import nltk

# Download words dataset if not already available
nltk.download("words")

# Import the words list
from nltk.corpus import words

# Load a set of valid English words
valid_words = set(words.words())

# Categorize words based on difficulty
easy_words = {word.lower() for word in valid_words if 1 <= len(word) <= 3}
medium_words = {word.lower() for word in valid_words if 4 <= len(word) <= 5}
hard_words = {word.lower() for word in valid_words if len(word) >= 6}

# Function to save words into separate files
def save_words(filename, words):
    with open(filename, "w") as file:
        file.write("\n".join(words))

# Save words to separate text files
save_words("easy_words.txt", easy_words)
save_words("medium_words.txt", medium_words)
save_words("hard_words.txt", hard_words)

print("Words saved successfully! Files: easy_words.txt, medium_words.txt, hard_words.txt")
