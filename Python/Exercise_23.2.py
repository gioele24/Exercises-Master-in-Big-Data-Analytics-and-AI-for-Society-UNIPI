def factorial_generator_10():
    count = 1
    fact = 1
    while count <= 10:
        fact = fact*count
        count += 1
        yield fact

for x in factorial_generator_10():
    print(x)