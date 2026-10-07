from random import randint

EASY_LEVEL_TURNS = 10
HARD_LEVEL_TURNS = 5

def check_asnwer(user_guess, actual_guess):
    if user_guess>actual_guess:
        print("Too high.")
    elif user_guess>actual_guess:
        print("Too low.")
    else:
        print("You got it! The answer was {actual_answer}")

def set_difficulty():
    level = input("Choose a difficulty. Type 'easy' or 'hard': ")
    if level == "easy":
        turns = EASY_LEVEL_TURNS
    else:
        turns = HARD_LEVEL_TURNS

print("Welcome to the Number Guessing Game!")
print("I'm thinking of a number between 1 and 100.")
answer = randint(1, 100)