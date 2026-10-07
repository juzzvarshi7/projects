from replit import clear
import random

from hangman_words import word_list
from hangman_art import stages, logo

chosen_word = random.choice(word_list)
word_length = len(chosen_word)

end_of_game = False
lives = 6

print(logo)

#testing code
#print(f'Pssst, the solution is {chosen_word}.')

#create blanks
display = []
for _ in range(word_length):
    display += "_"

while not end_of_game:
    guess = input("Guess a letter: ").lower()
    
    clear()
    
    if guess in display:
      print(f"You've already gessed {guess}")
    
    #check guessed letter
    for position in range(word_length):
        letter = chosen_word[position]
        #print(f"Current position: {position}\nCurrent letter: {letter}\nGuessed letter: {guess}")
        if letter == guess:
            display[position] = letter
        else:
            print("No match")

    if guess not in chosen_word:
      print(f"You guessed {guess}, that's not in the word. You lose a life.")
      lives -= 1
      if lives == 0:
        end_of_game = True
        print("You lose.")

    print(f"{' '.join(display)}")

    if "_" not in display:
        end_of_game = True
        print("You win.")
    print(stages[lives])