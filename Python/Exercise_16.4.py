def clean_text(line):
    result = ""
    line = line.lower()
    for character in line:
        if character >= "a" and character <= "z":
            result += character
        else:
            result += " "
    return result
"""
def words_in_common(file1, file2, file3):
    f1 = open(file1)
    f2 = open(file2)
    f3 = open(file3)

    r2 = clean_text(f2.read())
    r3 = clean_text(f3.read())

    word_list = []

    for line1 in f1:
        text1 = clean_text(line1)
        text1_list = text1.split()
        for word in text1_list:
            if len(word) > 1 and (word in r2) and (word in r3):
                if word not in word_list:
                    word_list.append(word)

    f1.close()
    f2.close()
    f3.close()

    return word_list
"""
def words_in_common2(file1, file2, file3):
    f1 = open(file1)
    f2 = open(file2)
    f3 = open(file3)

    word_list1 = []
    word_list2 = []
    word_list3 = []

    for line1 in f1:
        text1 = clean_text(line1)
        text1_list = text1.split()

    for line2 in f2:
        text2 = clean_text(line2)
        text2_list = text2.split()

    for line3 in f3:
        text3 = clean_text(line3)
        text3_list = text3.split()


    print(text1_list)
    print(text2_list)
    print(text3_list)

    text1_set = set(text1_list)
    text2_set = set(text2_list)
    text3_set = set(text3_list)
    print(text1_set)
    print(text2_set)
    print(text3_set)

    intersection_set = (text1_set & text2_set) & text3_set

    f1.close()
    f2.close()
    f3.close()

    return intersection_set

print(words_in_common2("pc_jabberwocky.txt", "pc_woodchuck.txt", "pc_rose.txt"))


