def DCBA_4_ABCD():
    for A in range(1,10):
        for B in range(10):
            for C in range(10):
                for D in range(1,10):
                    ABCD = str(A) + str(B) + str(C) + str(D)
                    DCBA = str(D) + str(C) + str(B) + str(A)
                    if int(DCBA) == 4*int(ABCD):
                        return int(DCBA), int(ABCD)


print(DCBA_4_ABCD())