from copy import deepcopy

def alphabet_range(c : str, p : str):
    if p == "uppercase":
        if c >= "A" and c <= "Z":
            return True
        else:
            return False

    if p == "lowercase":
        if c >= "a" and c <= "z":
            return True
        else:
            return False


"""
if a word starts with two capitals, followed by a lower-case letter,
the second capital is made lower case
"""

def autocorrect_1(w : str):
    w_new = ""
    if alphabet_range(w[0],"uppercase") and alphabet_range(w[1],"uppercase"):
        w_new = w[0] + w[1].lower() + w[2:]
        return w_new
    else:
        return w

"""
if a sentence contains a word that is immediately followed by the same word, the second
occurrence is removed
"""

def autocorrect_2(s : str):
    s_list = s.split()
    s_list_copy = deepcopy(s_list)
    for i in range(0, len(s_list) - 1):
        if s_list[i] == s_list[i + 1]:
            s_list_copy.pop(i + 1)
    s_new = " ".join(s_list_copy)
    return s_new

"""
if a sentence starts with a lower-case letter, that letter is turned
into a capital
"""

def autocorrect_3(s : str):
    s_new = ""
    if alphabet_range(s[0], "lowercase"):
        s_new = s[0].upper() + s[1:]
        return s_new
    else:
        return s

"""
if a word consists entirely of capitals, except for the first letter which
is lower case, then the case of the letters in the word is reversed
"""

def autocorrect_4(w : str):
    w_new = ""
    if alphabet_range(w[0], "lowercase") and alphabet_range(w[1:], "uppercase"):
        w_new = w[0].upper() + w[1:].lower()
        return w_new
    else:
        return w

"""
if the sentence contains the name of a day (in English) which does not start with a capital,
the first letter is turned into a capital
"""

def autocorrect_5(s : str):
    week_days = ["monday", "tuesday", "wednesday", "thursday", "friday", "saturday", "sunday"]
    s_list = s.split()
    for day in week_days:
        if day in s_list:
            s_list[s_list.index(day)] = day[0].upper() + day[1:]
    s_new = " ".join(s_list)
    return s_new

def autocorrect(text : str):
    text_list = text.split()
    for word_index in range(0,len(text_list)):
        text_list[word_index] = autocorrect_1(text_list[word_index])
        text_list[word_index] = autocorrect_4(text_list[word_index])

    text_1 = " ".join(text_list)
    new_text = autocorrect_5(autocorrect_3(autocorrect_2(text_1)))

    return new_text


sentence = "as it turned out our chance meeting with REverend \
aRTHUR BElling was was to change our whole way of life, and \
every sunday we 'd hurry along to St lOONY up the Cream BUn \
and Jam..."


corrected_sentence = autocorrect(sentence)
print(corrected_sentence)


