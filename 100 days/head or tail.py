import random
random_side=random.randint(0,1)
if random_side==1:
    print("Heads")
else:
    print("Tails")


print("MY code")
# Write your code below this line 👇
# Hint: Remember to import the random module first. 🎲
import random
print("Choose head or tail")
choice = input()
toss = random.randint(0,1)
if toss == 0 and choice == 'head':
  print("My coice was toss")
  print("You won the toss")
else:
  print("My choice was head")
  print("You lost the toss")