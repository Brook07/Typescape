import random
from collections import defaultdict

class MarkovWordGenerator:
    def __init__(self):
        self.chain = defaultdict(list)
        self.starting_letters = []
        
    def train(self, words):
        # Train the Markov chain with input words
        for word in words:
            self.starting_letters.append(word[0])
            for i in range(len(word) - 1):
                current = word[i]
                next_char = word[i + 1]
                self.chain[current].append(next_char)
            # Add word endings
            self.chain[word[-1]].append(None)
    
    def generate_word(self, min_length, max_length):
        while True:
            word = random.choice(self.starting_letters)
            current = word[-1]
            
            while True:
                if not self.chain[current]:
                    break
                    
                next_char = random.choice(self.chain[current])
                if next_char is None:
                    break
                    
                word += next_char
                current = next_char
                
                if len(word) >= max_length:
                    break
            
            if min_length <= len(word) <= max_length:
                return word.lower()

def load_sample_words():
    return [
        "cat", "dog", "rat", "bat", "hat", "mat", "sat", "pat",
        "cake", "take", "make", "lake", "wake", "bake",
        "table", "cable", "fable", "maple", "plane", "crane",
        "simple", "sample", "temple", "handle", "candle",
        "strange", "change", "orange", "bridge", "pledge"
    ]

def generate_word_lists(num_words=50):
    generator = MarkovWordGenerator()
    words = load_sample_words()
    generator.train(words)
    
    easy_words = set()
    medium_words = set()
    hard_words = set()
    
    while len(easy_words) < num_words:
        easy_words.add(generator.generate_word(3, 3))
    
    while len(medium_words) < num_words:
        medium_words.add(generator.generate_word(4, 5))
    
    while len(hard_words) < num_words:
        hard_words.add(generator.generate_word(5, 7))
    
    # Save words to files
    with open('../data/easy_words.txt', 'a') as f:
        f.write('\n'.join(sorted(easy_words)))
    
    with open('../data/medium_words.txt', 'a') as f:
        f.write('\n'.join(sorted(medium_words)))
    
    with open('../data/hard_words.txt', 'a') as f:
        f.write('\n'.join(sorted(hard_words)))

if __name__ == "__main__":
    generate_word_lists()
    print("Word lists have been generated and saved to files!")