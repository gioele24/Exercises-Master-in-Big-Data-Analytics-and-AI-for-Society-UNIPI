def multiplies_of_a_number(n : int, N : int):
    multiplies_list = []
    for i in range(2, N + 1):
        if n*i > N:
            break
        multiplies_list.append(n*i)
    return multiplies_list

def sieve_of_eratosthenes(N : int):
    l_primes = []
    for i in range(1, N + 1):
        l_primes.append(i)

    l_primes[0] = 0
    for num in l_primes:
        if num != 0:
            for n in multiplies_of_a_number(num, N):
                if n in l_primes:
                    l_primes[l_primes.index(n)] = 0

    return l_primes

def display_primes(l_primes : list):
    for elem in range(len(l_primes)):
        if l_primes[elem] != 0:
            print(l_primes[elem], end = " ")

display_primes(sieve_of_eratosthenes(150))


