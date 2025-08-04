class Frequency:
    def __init__(self, file):   # The '__init__' method processes the file:
        self.handle = open(file, encoding = 'utf8') # it opens the file (with a Unicode encoding)
        self.fileToProcess = (line for line in self.handle) # and process it line by line by means of a generator expression.

    def guess6(self):   # The 'guess6' method is the core of the class

        def clean(string: str): # The clean function 'cleans' the string in a way that
            string = string.lower() # ignores the distinction between uppercase and lowercase letters
            for character in string:
                if not character.isalnum(): # and maintains only alphanumeric characters.
                    string = string.replace(character, "")
            return string

        freq_dict = {}

        for text_line in self.fileToProcess: # This block reads the text file,
            text_line = clean(text_line) # cleans it
            for letter in text_line:
                freq_dict[letter] = freq_dict.get(letter, 0) + 1 # and fills a dictionary with letters (keys) and their respective frequency (values)

        def custom_sort(item : tuple): # This function takes a tuple (of length 2 in our case) as a parameter
            return -item[1], item[0] # and returns a tuple constructed as shown here.

        freq_list = list(freq_dict.items()) # In order to use the .sort() method of lists, the dictionary above is transformed into a list.
        freq_list.sort(key = custom_sort) # Such list is sorted by the numeric value (the frequency) in descending order and, in case of a tie, in lexicographical order of the key.
        freq_dict = dict(freq_list) # Finally the list is transformed back into a dictionary.

        freq_string = "" # This block creates an empty string
        count = 0
        for letter in freq_dict.keys():
            count += 1
            freq_string += letter # and fills it
            if count == 6: # with the 6 most frequent letters of the .txt file.
                break

        return freq_string # This is the returning value of the 'guess6' method.

    def close_file(self):   # This method closes the file.
        self.handle.close() # Remember to always call it at the end of the 'Frequency' class usage!

# The following is a usage exemple of the class 'Frequency' and its methods:

text = Frequency("divinaCommedia.txt")  # the variable 'text' is an instance of the class 'Frequency'
print(text.guess6()) # this prints the returning string of the 'guess6' method
text.close_file() # and this method closes the file.

# Output for "divinaCommedia.txt": eaionr
# Output for "OdisseaGreco.txt": αοντει