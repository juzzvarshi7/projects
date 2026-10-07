print("Enter you height in m: ")
height = float(input())
print("Enter your weight in kg: ")
weight = float(input())
bmi = weight / (height **2)
print("Your BMI is: ", round(bmi, 2))
if bmi < 18.5:
    print("Category: Underweight")
elif bmi < 25:
    print("Category: Normal weight")
elif bmi < 30:
    print("Category: Overweight")
else:
    print("Category: Obesity")