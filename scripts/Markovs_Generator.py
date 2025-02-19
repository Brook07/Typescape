import random
from collections import defaultdict

class MarkovWordGenerator:
    def __init__(self):
        self.chain = defaultdict(list)
        self.word_starts = defaultdict(list)
        self.common_patterns = defaultdict(int)
        self.short_words = set()  # Explicitly store complete short words
        
    def train(self, filename):
        """
        Train the Markov chain using words from a file with improved pattern recognition
        """
        try:
            with open(filename, 'r') as file:
                words = [word.strip().lower() for word in file.readlines() if word.strip()]
            
            # First pass: collect complete 3-letter words only
            for word in words:
                if len(word) == 3 and self.is_pronounceable(word):
                    self.short_words.add(word)
            
            print(f"Found {len(self.short_words)} three-letter words from training data")
            
            # Build letter transition patterns
            for word in words:
                if not word:
                    continue
                
                # Store word starts based on length
                if len(word) >= 3:
                    if len(word) == 3:
                        self.word_starts['easy'].append(word[0:2])  # First two letters for easy
                    if len(word) <= 5:
                        self.word_starts['medium'].append(word[:2])
                    if len(word) > 3:
                        self.word_starts['hard'].append(word[:2])
                
                # Build transition probabilities with context
                for i in range(len(word) - 1):
                    # Single letter context for better flexibility
                    self.chain[word[i]].append(word[i+1])
                    
                    # Also keep track of two-letter context for more coherent results
                    if i < len(word) - 2:
                        context = word[i:i+2]
                        next_char = word[i+2]
                        self.chain[context].append(next_char)
                    
                    # Track common patterns
                    if i < len(word) - 2:
                        pattern = word[i:i+3]
                        self.common_patterns[pattern] += 1
                
                # Add word endings
                if len(word) >= 2:
                    self.chain[word[-1:]].append(None)  # Single letter ending
                    self.chain[word[-2:]].append(None)  # Two letter ending
                
            print(f"Trained with patterns for easy: {len(self.word_starts['easy'])}, "
                  f"medium: {len(self.word_starts['medium'])}, hard: {len(self.word_starts['hard'])}")
            
        except FileNotFoundError:
            print(f"Error: Could not find file {filename}")
            return False
        return True
    
    def is_pronounceable(self, word):
        """
        Check if a word follows basic English pronunciation patterns
        """
        vowels = set('aeiou')
        consonants = set('bcdfghjklmnpqrstvwxyz')
        
        # Must contain at least one vowel
        if not any(c in vowels for c in word):
            return False
        
        # Less strict for 3-letter words
        if len(word) == 3:
            return True
            
        # Check for impossible consonant clusters
        for i in range(len(word) - 2):
            if all(c in consonants for c in word[i:i+3]):
                cluster = word[i:i+3]
                # Allow some common consonant clusters even if not in training data
                common_clusters = {'str', 'spr', 'spl', 'scr', 'thr', 'chr', 'shr', 'sch', 'phr'}
                if cluster not in common_clusters and cluster not in self.common_patterns:
                    return False
        
        return True
    
    def generate_word(self, difficulty):
        """
        Generate a pronounceable word based on difficulty level
        """
        # For easy difficulty, return a 3-letter word from our training data
        if difficulty == 'easy' and self.short_words:
            return random.choice(list(self.short_words))
            
        # Set length constraints based on difficulty
        if difficulty == 'easy':
            target_length = 3  # Fixed at exactly 3 for easy
            # If we don't have enough word starts for easy, create some
            if len(self.word_starts['easy']) < 10:
                vowels = ['a', 'e', 'i', 'o', 'u']
                consonants = ['b', 'c', 'd', 'f', 'g', 'h', 'j', 'k', 'l', 'm', 'n', 'p', 'r', 's', 't', 'v', 'w']
                for c in consonants:
                    for v in vowels:
                        self.word_starts['easy'].append(c+v)
        elif difficulty == 'medium':
            min_length = 4
            max_length = 5
        else:  # hard
            min_length = 5
            max_length = 7
            
        max_attempts = 100
        attempts = 0
        
        while attempts < max_attempts:
            if difficulty == 'easy':
                # For easy words, make sure we generate exactly 3 characters
                if not self.word_starts[difficulty]:
                    raise ValueError(f"No starting patterns available")
                
                current_start = random.choice(self.word_starts[difficulty])
                word = current_start
                
                # For easy words, we need exactly one more character to reach length 3
                if len(word) == 2:
                    if word in self.chain and self.chain[word]:
                        next_char = random.choice(self.chain[word])
                        if next_char is not None:
                            word += next_char
                
                # Ensure the word is exactly 3 characters
                if len(word) == 3 and self.is_pronounceable(word):
                    return word.lower()
            else:
                # For medium and hard difficulties, use the previous approach
                if not self.word_starts[difficulty]:
                    # Fallback to using any available start patterns
                    all_starts = []
                    for d, starts in self.word_starts.items():
                        if d != difficulty:  # avoid using the current empty list
                            all_starts.extend(starts)
                    if not all_starts:
                        raise ValueError(f"No starting patterns available")
                    current_start = random.choice(all_starts)
                else:
                    current_start = random.choice(self.word_starts[difficulty])
                
                word = current_start
                
                # Build word using transitions
                while (difficulty == 'medium' and len(word) < max_length) or \
                      (difficulty == 'hard' and len(word) < max_length):
                    # Try two-letter context first for more coherent words
                    if len(word) >= 2 and word[-2:] in self.chain and self.chain[word[-2:]]:
                        context = word[-2:]
                        next_char = random.choice(self.chain[context])
                    # Fall back to single-letter context
                    elif word[-1:] in self.chain and self.chain[word[-1:]]:
                        context = word[-1:]
                        next_char = random.choice(self.chain[context])
                    else:
                        break
                    
                    if next_char is None:
                        break
                        
                    word += next_char
                
                # Validate word length based on difficulty
                if (difficulty == 'medium' and 4 <= len(word) <= 5) or \
                   (difficulty == 'hard' and 5 <= len(word) <= 7):
                    if self.is_pronounceable(word):
                        return word.lower()
                
            attempts += 1
            
        raise RuntimeError(f"Failed to generate valid {difficulty} word after maximum attempts")

def generate_word_lists(num_words=200):
    """
    Generate word lists for each difficulty level
    """
    generator = MarkovWordGenerator()
    if not generator.train('../data/sample.txt'):
        print("Failed to train generator")
        return
    
    difficulties = {
        'easy': set(),
        'medium': set(),
        'hard': set()
    }
    
    # Generate words for each difficulty level
    for difficulty in difficulties:
        attempts = 0
        max_attempts = num_words * 30  # Further increased to give more chances
        
        print(f"Generating {difficulty} words...")
        while len(difficulties[difficulty]) < num_words and attempts < max_attempts:
            try:
                word = generator.generate_word(difficulty)
                # Double-check length for easy words
                if difficulty == 'easy' and len(word) != 3:
                    attempts += 1
                    continue
                    
                if word not in difficulties[difficulty]:
                    difficulties[difficulty].add(word)
                    if len(difficulties[difficulty]) % 50 == 0:
                        print(f"Generated {len(difficulties[difficulty])} {difficulty} words")
            except (ValueError, RuntimeError) as e:
                if attempts % 1000 == 0:  # Reduce log spam
                    print(f"Error generating {difficulty} word at attempt {attempts}: {e}")
            attempts += 1
        
        if len(difficulties[difficulty]) < num_words:
            print(f"Warning: Could only generate {len(difficulties[difficulty])} {difficulty} words after {attempts} attempts")
    
    # Save words to files
    for difficulty, words in difficulties.items():
        filename = f'../data/{difficulty}_words.txt'
        try:
            with open(filename, 'w') as f:
                f.write('\n'.join(sorted(words)))
            print(f"Successfully saved {len(words)} {difficulty} words to {filename}")
        except IOError as e:
            print(f"Error saving {difficulty} words: {e}")

if __name__ == "__main__":
    generate_word_lists()