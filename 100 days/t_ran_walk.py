import turtle as t
import random

tm = t.Turtle()
colours = ["CornflowerBlue", "DarkOrchid", "IndianRed", "DeepSkyBlue", "LightSeaGreen", "wheat", "SlateGray", "SeaGreen"]

directions = [0, 90, 180, 270]


for _ in range(300):
    tm.pensize("fastest")
    tm.pensize(8)
    tm.color(random.choice(colours))
    tm.forward(30)
    tm.setheading(random.choice(directions))