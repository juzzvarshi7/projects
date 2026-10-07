def paint_calc(height, width, cover):
    area = height * width
    number_of_cans = (area + cover - 1) // cover
    print(f"You'll need {number_of_cans} cans of paint.")

test_h = int(input())  # Height of wall (m)
test_w = int(input())  # Width of wall (m)
coverage = 5
paint_calc(height=test_h, width=test_w, cover=coverage)