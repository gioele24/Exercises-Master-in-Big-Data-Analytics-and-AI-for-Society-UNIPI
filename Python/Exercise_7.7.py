from random import random
from math import sqrt

def pi_approximation(N : int):
    M = 0
    for dart in range(N):
        x = random()
        y = random()
        if sqrt(x**2 + y**2) < 1:
            M += 1

    return 4*M/N

print(pi_approximation(1000000))

