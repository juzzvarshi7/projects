from random import randint
from art_number_guess import logo

EASY_LEVEL_TURNS = 10
HARD_LEVEL_TURNS = 5


# function to check user's guess against actual answer
def check_answer(user_guess, actual_answer, turns):
    """Checks answer against guess, returns the number of turns remaining"""
    if user_guess >  actual_answer:
        print("""Too high. 
              Guess again!""")
        return turns - 1
    elif user_guess < actual_answer:
        print("""Too low. 
              Guess again!""")
        return turns - 1
    else:
        print(f"You got it! The answer was {actual_answer}")
        
# function to set difficulty
def set_difficulty():
    level = input("Choose a difficulty. Type 'easy' or 'hard': ")
    if level == 'easy':
        return EASY_LEVEL_TURNS
    else:
        return HARD_LEVEL_TURNS


def game():
    # choosing a random number between 1 and 100
    print(logo)
    print("Welcome to the Number Guessing Game!")
    print("I'm thinking of a number between 1 and 100")
    answer = randint(1, 100)
    print(answer)
    
    # let the user guess a number
    turns = set_difficulty()

    # repeat the guessing functionality if they get it wrong
    guess = 0

    while guess!=answer:
        print(f"You have {turns} attempts remaining to guess the number.")
        # let the user guess a number
        guess = int(input("Make a guess: "))
        turns = check_answer(guess, answer, turns)
        if turns==0:
            print("You've run out of guesses, you lose.")
            return
    
        

game()