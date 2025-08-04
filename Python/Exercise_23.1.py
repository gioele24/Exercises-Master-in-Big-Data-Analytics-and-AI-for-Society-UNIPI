def enter_numbers():
    num_list = []
    while True:
        num = int(input())
        if num == 0:
            break
        num_list.append(num)
    return num_list

def divisibility(num : int, val : int):
    if num % val == 0:
        return True
    else:
        return False

class ClassRequired:
    def __init__(self, seq : list):
        num_list = [num for num in range(1,101)]
        for n in seq:
            for elem in num_list:
                if divisibility(elem, n):
                    num_list.remove(elem)
        self.seq = num_list
    def __iter__(self):
        return self
    def __next__(self):
        if len(self.seq) > 0:
            return self.seq.pop(0)
        raise StopIteration()

l = enter_numbers()
for i in ClassRequired(l):
    print(i)