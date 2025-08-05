SELECT *
FROM Students 

--projection of name and surname

SELECT name, surname 
FROM Students 

-- projection of name and surname (rename name and surname)

SELECT name as name_student, surname as surname_student 
FROM Students 

-- student with master

SELECT studentID, name as name_student, surname as surname_student 
FROM Students 
WHERE program = 'master'

--students with master of the second year

SELECT studentID, name as name_student, surname as surname_student 
FROM Students 
WHERE program = 'master' AND year = 2 


--list all exams in the corresponding table

SELECT *
FROM Exams 

--list all exams with mark greater than 25

SELECT *
FROM Exams
WHERE mark > 25

--list all exams with mark greater than 25 related to the course BD1

SELECT *
FROM Exams
WHERE mark > 25 AND course = 'BD1'

--list of the teachers with surname starting with "M"

SELECT *
FROM Teachers t 
where t.surname like 'M%'

--list of the teachers with surname without "M"

SELECT *
FROM Teachers t 
where t.surname not like '%M%'

--List students with a mark	greater	than 26 in the exam for databases	

SELECT s.studentID, s.name, s.surname, s.year, e.course, e.mark, c.title, c.program
FROM Students s Join Exams e on s.studentID = e.student 
				JOIN Courses c on e.course = c.code 
WHERE e.mark > 26 AND title = 'databases'


--List studentID of students with at least an exam with laud

SELECT DISTINCT e.student --In this specific exemple Distinct is not necessary since there is only 1 laud
FROM Exams e 
WHERE e.laud = 1

--List studentID of students with at least an exam greater than 26

SELECT DISTINCT e.student --Here distinct is necessary 
FROM Exams e 
WHERE e.mark > 26

--List students (studentID, name, surname) with
--at least an exam with laud

SELECT DISTINCT s.studentID, s.name, s.surname 
FROM Students s JOIN Exams e ON s.studentID = e.student 
where e.laud = 1

--list students (studentID, name, surname) with
--at least an exam without laud

SELECT DISTINCT s.studentID, s.name, s.surname 
FROM Students s JOIN Exams e ON s.studentID = e.student 
where e.laud = 0

-- if we want only one attribute to be distinct we can write

SELECT DISTINCT(e.student), s.surname, s.name
from Students s JOIN Exams e ON s.studentID = e.student 
WHERE e.laud = 0


--list of student with surname containing "s"
--and with a supervisor having a name ending with "na"

SELECT *
from Students s join Teachers t on s.supervisor = t.code 
where s.surname like '%s%' and t.name LIKE '%na' --regular expressions are case insensitive

--list the tutors who in databases exam have a greater mark
--than at least one of their students
--tables: tutoring, students, exams, course

SELECT st.studentID, st.surname, st.name
FROM Tutoring t join Students st on t.tutor = st.studentID 
join Exams et on st.studentID = et.student 
--or equivalently join Exams e on t.student = e.student
join Courses c on c.code = et.course 
join Students s on t.student = s.studentID 
join Exams es on es.student = s.studentID 
WHERE et.mark > es.mark and c.title ='Databases'

--list students having exams with mark greater than 27 (at least one exam with mark greater than)
--in the output i will have also 276545

SELECT DISTINCT e.student 
from Exams e 
where e.mark > 27

--What is harder is: 
--list students with ONLY exams with mark greater than 27
--we need the set operator ('except' in particular)

SELECT e.student 
from Exams e 
where e.mark > 27
EXCEPT 
SELECT e.student 
from Exams e 
where e.mark <= 27
--in the previous we can't put select * since the full row are
--always different and the 'except' does nothing. 
--We only have to project on the studentID

--if we want to include surname and name in the table:

SELECT student, surname, name
from Exams join Students on student = studentID
where mark > 27
EXCEPT 
SELECT student, surname, name
from Exams join Students on student = studentID
where mark <= 27

--alternative with NOT IN

SELECT DISTINCT student 
from Exams 
WHERE mark > 27 and student not in (
SELECT student 
from Exams  
where mark <= 27
)
--Better to include distinct in the query above because we are not 
--using set operators which account automatically of duplicates (removing them).

--Exemple of insertion

--INSERT INTO Exams(student,course,mark,laud)
--VALUES (276545,'BD2', 30, 1)



--To have also surname and name (the schema is defined by the
--outer select and in fact the second select doesn't need
--other projections for the required calculation)

SELECT DISTINCT student, surname, name
from Exams join Students on student = studentID 
WHERE mark > 27 and student not in (
SELECT student 
from Exams  
where mark <= 27
)

--list students having a tutor
SELECT student, name, surname 
from Tutoring join Students on studentID = student 

--list all the tutor
SELECT tutor, name, surname 
from Tutoring join Students on studentID = tutor 

--Surname and name of all people in the database
SELECT name, surname
FROM Students
union
SELECT name, surname
FROM Teachers 
--if there are repetition in the tables and we want to take
--into account all the occurences (i.e. repetitions), use 'union all'


--surname and name of full professors who are
--supervisors of bachelor thesis

SELECT t.surname, t.name 
FROM Teachers t join Students s on t.code = s.supervisor 
WHERE t.role = 'full' and s.program = 'bachelor'

--Some 'order by' exemples

SELECT *
from Students s 
order by surname, name 

SELECT *
from Students s 
order by surname, name desc

SELECT *
from Students s 
order by surname desc, name desc

SELECT *
from Students s 
where program = 'bachelor'
order by surname desc, name desc

SELECT *
from Students s 
where program = 'bachelor'
order by year

--Some aggregate functions exemples

SELECT AVG(mark) as AVG_MARK, COUNT(*) as NExams
FROM Exams

--In the following query an error arise! Which student? It can be solved by using 'group by'

SELECT student, AVG(mark) as AVG_MARK, COUNT(*) as NExams
FROM Exams
--where student = 276545

--Usage exemples of 'group by'

SELECT Program, count(*) as nstud
FROM Students
GROUP BY Program
 
SELECT Year, count(*) as nstud
FROM Students
GROUP BY Program, Year

--The following query is the correction of that one above

SELECT student, AVG(mark) as AVG_MARK, COUNT(*) as NExams
FROM Exams
group by student

SELECT Year, Program, COUNT(*) AS NumStud
FROM Students
GROUP BY Year, Program;

SELECT Year, COUNT(*) AS NumStud
FROM Students
where program = 'bachelor'
GROUP BY Year--, Program;

-- return for each program the num. of students with a supervisor
-- and in the result we are interested only to groups having at least one student
SELECT Program, COUNT(*) AS NumStud
FROM Students
where supervisor is not null
GROUP BY Program
having count(*) > 1;