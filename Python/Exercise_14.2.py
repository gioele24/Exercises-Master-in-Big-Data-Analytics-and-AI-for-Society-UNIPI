num_div_by_3 = set([num for num in range(1,1001) if num % 3 == 0])
num_div_by_7 = set([num for num in range(1,1001) if num % 7 == 0])
num_div_by_11 = set([num for num in range(1,1001) if num % 11 == 0])

num_div_by_3_7_and_11 = (num_div_by_3 & num_div_by_7) & num_div_by_11
num_div_by_3_and_7_but_not_11 = (num_div_by_3 & num_div_by_7) - num_div_by_11
num_not_div_by_3_7_or_11 = ((set(range(1,1001)) - num_div_by_3) - num_div_by_7) - num_div_by_11

print(num_div_by_3_7_and_11)
print(num_div_by_3_and_7_but_not_11)
print(num_not_div_by_3_7_or_11)
