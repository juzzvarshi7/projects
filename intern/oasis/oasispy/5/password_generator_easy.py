import random

letters = ['a', 'b', 'c', 'd', 'e', 'f', 'g', 'h', 'i', 'j', 'k', 'l', 'm', 'n', 'o', 'p', 'q', 'r', 's', 't', 'u', 'v', 'w', 'x', 'y', 'z',
           'A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J', 'K', 'L', 'M', 'N', 'O', 'P', 'Q', 'R', 'S', 'T', 'U', 'V', 'W', 'X', 'Y', 'Z']
numbers = ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9']
symbols = ['!', '#', '$', '%', '&', '(', ')', '*', '+']

print("Welcome to the PyPassword Generator!")

def get_int_input(prompt):
    while True:
        try:
            return int(input(prompt))
        except ValueError:
            print("Invalid input. Please enter a number.")

nr_letters = get_int_input("How many letters would you like in your password?\n")
nr_symbols = get_int_input("How many symbols would you like?\n")
nr_numbers = get_int_input("How many numbers would you like?\n")

password = ""

for _ in range(nr_letters):
    password += random.choice(letters)
for _ in range(nr_symbols):
    password += random.choice(symbols)
for _ in range(nr_numbers):
    password += random.choice(numbers)

# Shuffle the password to ensure a random order
password_list = list(password)
random.shuffle(password_list)
password = ''.join(password_list)

print(f"Your generated password is: {password}")
