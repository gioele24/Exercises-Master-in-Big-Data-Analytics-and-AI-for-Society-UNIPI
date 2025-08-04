#My implementation of the exercise is a little more complex for challenging purposes!
import math

class Shape:
    def __init__(self, regular : bool, no_of_sides, len_of_sides):
        self.regular = regular
        self.no_of_sides = no_of_sides
        if self.regular:
            self.len_of_sides = len_of_sides
        elif not self.regular and isinstance(len_of_sides, list):
            self.len_of_sides = len_of_sides

    def perimeter(self):
        if self.regular:
            return self.no_of_sides * self.len_of_sides
        else:
            return sum(self.len_of_sides)

    def area(self):
        return NotImplemented

class Rectangle(Shape):
    def __init__(self, len_of_sides):
        super().__init__(regular = False, no_of_sides = 4, len_of_sides = 0)
        self.len_of_sides = len_of_sides

    def area(self):
        len_of_sides_list = list(set(self.len_of_sides))
        area_val = 1
        for side in len_of_sides_list:
            area_val *= side
        return area_val


class Square(Shape):
    def __init__(self, len_of_sides):
        super().__init__(regular = True, no_of_sides = 4, len_of_sides = 0)
        self.len_of_sides = len_of_sides

    def area(self):
        return self.len_of_sides**2

class Circle(Shape):
    def __init__(self, radius):
        super().__init__(regular = True, no_of_sides = 2 * math.pi, len_of_sides = radius)
        self.radius = radius

    def area(self):
        return math.pi * self.radius**2

r = Rectangle([2,4,2,4])
s = Square(2)
c = Circle(3)

print(r.perimeter(), r.area())
print(s.perimeter(), s.area())
print(c.perimeter(), c.area())