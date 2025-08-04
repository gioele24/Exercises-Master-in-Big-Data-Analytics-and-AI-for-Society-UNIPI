class Card:
    def __init__(self, value, suit):
        self.value = value
        self.suit = suit
        suits = ["Hearts", "Spades", "Clubs", "Diamonds"]
        values = ["2", "3", "4", "5", "6", "7", "8", "9", "10", "Jack", "Queen", "King", "Ace"]
        if self.suit not in suits:
            raise ValueError("Invalid type of suit!")
        if self.value not in values:
            raise ValueError("Invalid type of value!")

    def __repr__(self):
        return "{} of {}".format(self.value, self.suit)

    def __eq__(self, other):
        return self.value == other.value

    def __lt__(self, other):
        values = ["2", "3", "4", "5", "6", "7", "8", "9", "10", "Jack", "Queen", "King", "Ace"]
        if self.value in values:
            index1 = values.index(self.value)
        if other.value in values:
            index2 = values.index(other.value)
        return index1 < index2

c1 = Card("3", "Clubs")
c2 = Card("Ace", "Diamonds")
print(c1, "and", c2)
print(c1 != c2)
print(c1 < c2)




