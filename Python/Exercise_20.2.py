from datetime import datetime

class Student:
    def __init__(self, first_name, last_name, date_of_birth, administration_number):
        self.first_name = first_name
        self.last_name = last_name
        self.date_of_birth = date_of_birth
        self.administration_number = administration_number
        self.courses = []

    def enroll(self, course):
            self.courses.append(course)

    def __repr__(self):
        return "id: {}, name: {}, surname: {}, age: {}"\
            .format(self.administration_number,self.first_name, self.last_name,\
                    (datetime.today()).year - self.date_of_birth.year)

class Course:
    def __init__(self, name, number):
        self.name = name
        self.number = number

    def __repr__(self):
        return "({}, {})".format(self.name, self.number)


s = Student("Gioele", "Eterno", datetime(1999, 7, 24), 577944)
c = Course("Python", 1)
c1 = Course("Database", 2)

s.enroll(c)
s.enroll(c1)
print(s)
print(s.courses)
