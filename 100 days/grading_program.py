student_scores = {
    "Harry": 81,
    "Ron" : 78,
    "Hermione" : 99,
    "Draco" : 74,
    "Neville" : 62
}

#create an empty dictionary called student_grades
student_grades ={}
#write your code below to add the grades to student_grades
for student, score in student_scores.items():
    if score>=91:
        student_grades[student]="Outstanding"
    elif score>=81:
        student_grades[student]="Exceeds Expectations"
    elif score>=71:
        student_grades[student]="Acceptable"
    else:
        student_grades[student]="Fail"
#dont change the code below
print(student_grades)