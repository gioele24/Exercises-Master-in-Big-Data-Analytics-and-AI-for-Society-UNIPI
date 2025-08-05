-- 1. Bachelor students attending years greater	than 1

SELECT *
FROM Students s 
WHERE s.program = 'bachelor' AND s.year > 1

-- 2. StudentID	and	surname	of students	who	did	the	exam of	programming	

SELECT s.studentID, s.surname 
FROM Students s join Exams e on s.studentID = e.student 
				JOIN Courses c on e.course = c.code 
WHERE c.title = 'programming'

-- 3. Surname and name of all people in	the	database	

SELECT s.name, s.surname 
FROM Students s 
Union
SELECT t.name, t.surname
FROM Teachers t 

-- 4. Students attending years greater than	1 and exams	with laud

SELECT DISTINCT s.studentID, s.surname, s.name 
FROM Students s join Exams e on s.studentID = e.student
WHERE s.year > 1 and e.laud = 1 

-- 5. Surname and name of full professors who are supervisors of bachelor theses
	
SELECT t.surname, t.name 
from Teachers t join Students s on t.code = s.supervisor 
WHERE t.role = 'full' and s.program = 'bachelor'

-- 6. Surnames,	names and phone	numbers	of teachers	

SELECT t.surname, t.name, p.phonenumber 
FROM Teachers t join Phones p on t.code = p.teacher 

-- 7. surname and name of full professors who are supervisors of bachelor students with name Rossi

SELECT t.surname, t.name 
from Teachers t join Students s on t.code = s.supervisor 
WHERE t.role = 'full' and s.program = 'bachelor' and s.name = 'Rossi'

-- 8. List teachers	supervisioning students	having at least	one	mark less than 25 or students with a mark greater than 29.	
-- Notice the 'at least' word. This means that it can be done
-- without using sets

SELECT DISTINCT t.surname, t.name 
from Teachers t join Students s on t.code = s.supervisor
				join Exams e on s.studentID = e.student 
WHERE e.mark < 25 or e.mark > 29

-- 9. RETURN teachers who are not supervisioning bachelor students	

SELECT t.surname, t.name 
from Teachers t join Students s on t.code = s.supervisor 
WHERE NOT s.program = 'bachelor'

-- 10. List	the	tutors who in databases	exam have a greater	mark than at least one of their students

SELECT *--st.studentID, st.surname, st.name 
FROM Tutoring t 
join Students st on t.tutor = st.studentID
join Exams et on st.studentID = et.student 
join Courses c on et.course = c.code
join Students s on t.student = s.studentID
join Exams es on s.studentID = es.student
WHERE c.title = 'Databases' and et.mark > es.mark
