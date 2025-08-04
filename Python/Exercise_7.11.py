def multiplication_table(n : int):
    print(". |", end=" ")
    for i in range(1, n+1):
        print(i, end=" ")
    print("")
    print((3*n)*"-")
    j = 0
    for i in range(1, n+1):
        if j == n:
            print("")
        print(i, "|", end=" ")
        for j in range(1, n+1):
            print(i*j, end=" ")


multiplication_table(10)