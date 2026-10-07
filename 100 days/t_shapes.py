import turtle as t

tm = t.Turtle()

for n in range(3,11):
    angle = 360/n
    for i in range(n):
        tm.forward(100)
        tm.right(angle)
        
tb = t.Turtle()

for _ in range(1,10):
    tb.forward(10)
    tb.penup()
    tb.forward(10)
    tb.pendown()