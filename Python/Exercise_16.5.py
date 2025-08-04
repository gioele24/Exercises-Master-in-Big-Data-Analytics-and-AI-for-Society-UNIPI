def clean_text(line : str):
    result = ""
    line = line.lower()
    for character in line:
        if character >= "a" and character <= "z":
            result += character
        else:
            result += ""
    return result

def letter_count(line : str):
    letter_list = 26*[0]
    for character in clean_text(line):
        letter_list[ord(character)-ord("a")] += 1
    return letter_list

def fraction_of_occurrences(l : list):
    fraction_list = []
    for occur in l:
        fraction_list.append(round(occur/sum(l), 5))
    return fraction_list

def create_csv(file1, file2, file3, file4):
    h1 = open(file1)
    h2 = open(file2)
    h3 = open(file3)
    h4 = open(file4, "w")

    r1 = h1.read()
    r2 = h2.read()
    r3 = h3.read()
    
    r1_list = letter_count(r1)
    r2_list = letter_count(r2)
    r3_list = letter_count(r3)

    f1 = fraction_of_occurrences(r1_list)
    f2 = fraction_of_occurrences(r2_list)
    f3 = fraction_of_occurrences(r3_list)

    index = 0
    for ord_letter in range(ord("a"),ord("z") + 1):
        w4 = h4.write("{},{},{},{}\n".format(chr(ord_letter), f1[index], f2[index], f3[index]))
        index += 1
    
    h1.close()
    h2.close()
    h3.close()
    h4.close()


create_csv("pc_jabberwocky.txt", "pc_rose.txt", "pc_woodchuck.txt", "pc_fraction.csv")