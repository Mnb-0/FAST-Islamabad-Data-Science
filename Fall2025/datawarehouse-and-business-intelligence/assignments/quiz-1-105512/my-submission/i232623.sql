create database quiz1;
use quiz1;
-- Student Dimension
CREATE TABLE student_dim (
student_id INT PRIMARY KEY,
student_name VARCHAR(100),
age_group VARCHAR(20)
);
-- Course Dimension
CREATE TABLE course_dim (
course_id INT PRIMARY KEY,
course_name VARCHAR(100),
department VARCHAR(50),
credits INT
);
-- Enrollment Fact Table
CREATE TABLE enrollment_fact (
enrollment_id INT PRIMARY KEY,
student_id INT,
course_id INT,
semester_id INT,
grade VARCHAR(2),
marks DECIMAL(5,2),
FOREIGN KEY (student_id) REFERENCES student_dim(student_id),
FOREIGN KEY (course_id) REFERENCES course_dim(course_id)
);
-- Semester Dimension
CREATE TABLE semester_dim (
semester_id INT PRIMARY KEY,

semester_name VARCHAR(20), -- e.g., 'Fall2023'
year INT,
semester_seq INT -- 1 for Spring, 2 for Fall
);
-- Inserts
INSERT INTO student_dim VALUES
(1, 'Alice Chen', '18-22'),
(2, 'Bob Smith', '18-22'),
(3, 'Charlie Brown', '23-30'),
(4, 'Diana Prince', '23-30');
INSERT INTO course_dim VALUES
(101, 'Data Structures', 'Computer Science', 3),
(102, 'Calculus I', 'Mathematics', 4),
(103, 'Introduction to BI', 'Business', 3),
(104, 'Advanced SQL', 'Computer Science', 3);
INSERT INTO semester_dim VALUES
(1, 'Fall2022', 2022, 2),
(2, 'Spring2023', 2023, 1),
(3, 'Fall2023', 2023, 2);
INSERT INTO enrollment_fact VALUES
(1, 1, 101, 1, 'A', 92.5),
(2, 1, 102, 1, 'B+', 88.0),
(3, 2, 101, 1, 'C', 72.0),
(4, 3, 103, 2, 'A-', 89.5),
(5, 1, 104, 3, 'A', 95.0),
(6, 2, 101, 3, 'B', 85.0),
(7, 4, 102, 3, 'A+', 98.0),
(8, 2, 103, 3, 'F', 45.0);


-- Q1
select distinct s.student_name, c.course_name, e.grade as old_grade, f.grade as new_grade, q.semester_name
from student_dim as s, course_dim as c, enrollment_fact as e , enrollment_fact as f, semester_dim as q
where e.student_id = f.student_id and e.grade > f.grade;

-- Q2
select c.department, c.course_name, avg(a.marks) as student_avg, avg(b.marks) as dept_avg
from course_dim as c, student_dim as s, enrollment_fact as b, enrollment_fact as a
where ;
-- Q3
select s.student_name, avg(e.marks),


-- Q4
select c.course_name
