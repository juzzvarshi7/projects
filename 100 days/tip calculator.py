print('welcome to tip calculator')
bill = float(input('what was the total bill? '))
tip = int(input('what percentage tip would you like to give? 10, 12, or 15? '))
ppl = int(input('how many ppl to split the bills? '))
bill_with_tip = bill * (1 + tip/100)
print(bill_with_tip)
bill_per_person = bill_with_tip / ppl
final_amount = round(bill_per_person, 2)
print(f'each person should pay: ${final_amount}')
