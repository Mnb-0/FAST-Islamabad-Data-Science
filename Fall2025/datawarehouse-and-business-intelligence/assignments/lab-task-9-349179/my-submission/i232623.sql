drop database if exists lab9_A;
create database lab9_A;
use lab9_A;
-- Denormalized Dimension: Patient, Age Group, Risk Category
create table dim_patient_star (
    patient_id int primary key auto_increment,
    patient_name varchar(100) not null,
    age_group_name varchar(50) not null,
    risk_category_name varchar(50) not null
);

-- Denormalized Dimension: Procedure, Service Category, Department
create table dim_treatment_star (
    procedure_id int primary key auto_increment,
    procedure_name varchar(100) not null,
    service_category_name varchar(50) not null,
    department_name varchar(50) not null
);

-- Denormalized Dimension: Doctor, Specialization, Certification
create table dim_doctor_star (
    doctor_id int primary key auto_increment,
    doctor_name varchar(100) not null,
    specialization_name varchar(50) not null,
    certification_level_name varchar(50) not null
);

-- Denormalized Dimension: Time
-- Note: This table is often the same in both schemas as its hierarchy is simple.
create table dim_time_star (
    time_id int primary key auto_increment,
    full_date date not null,
    month int not null,
    quarter int not null,
    year int not null
);

-- Denormalized Dimension: Room, Floor, Building
create table dim_location_star (
    room_id int primary key auto_increment,
    room_number varchar(10) not null,
    floor_number int not null,
    building_name varchar(50) not null
);

-- Fact Table (references the new denormalized dimension tables)
create table fact_treatments_star (
    treatment_id int primary key auto_increment,
    patient_id int,
    procedure_id int,
    doctor_id int,
    time_id int,
    room_id int,
    treatment_cost decimal(10, 2),
    duration_minutes int,
    success_rate decimal(5, 2),
    foreign key (patient_id) references dim_patient_star(patient_id),
    foreign key (procedure_id) references dim_treatment_star(procedure_id),
    foreign key (doctor_id) references dim_doctor_star(doctor_id),
    foreign key (time_id) references dim_time_star(time_id),
    foreign key (room_id) references dim_location_star(room_id)
);


-- Dimension Data Insertion (Same data, but denormalized)
-- DATA REDUNDANCY is evident here. For example, 'Adult' and 'Low' are repeated for each adult patient.
insert into dim_patient_star (patient_name, age_group_name, risk_category_name) values
('John Smith', 'Adult', 'Low'), ('Jane Doe', 'Senior', 'High'), ('Peter Jones', 'Pediatric', 'Medium'),
('Mary Williams', 'Adult', 'Low'), ('David Brown', 'Senior', 'High');

-- DATA REDUNDANCY: 'Surgical' and 'Orthopedics' are repeated for both Knee Replacement and Spinal Fusion.
insert into dim_treatment_star (procedure_name, service_category_name, department_name) values
('Heart Bypass', 'Surgical', 'Cardiology'), ('Angiogram', 'Diagnostic', 'Cardiology'),
('Knee Replacement', 'Surgical', 'Orthopedics'), ('Spinal Fusion', 'Surgical', 'Orthopedics'),
('Physical Therapy', 'Rehabilitation', 'Orthopedics'), ('EEG', 'Consultation', 'Neurology');

-- DATA REDUNDANCY: 'Orthopedic Surgery' and 'Fellowship Trained' repeated for Dr. Charlie and Dr. Eve.
insert into dim_doctor_star (doctor_name, specialization_name, certification_level_name) values
('Dr. Alice', 'Cardiac Surgery', 'Fellowship Trained'), ('Dr. Bob', 'Interventional Cardiology', 'Board Certified'),
('Dr. Charlie', 'Orthopedic Surgery', 'Fellowship Trained'), ('Dr. Diana', 'Neurology', 'Board Certified'),
('Dr. Eve', 'Orthopedic Surgery', 'Fellowship Trained');

insert into dim_time_star (full_date, month, quarter, year) values
('2023-11-15', 11, 4, 2023), ('2023-12-20', 12, 4, 2023), ('2024-01-10', 1, 1, 2024), ('2024-02-05', 2, 1, 2024),
('2024-03-22', 3, 1, 2024), ('2024-04-18', 4, 2, 2024), ('2024-05-30', 5, 2, 2024), ('2024-06-12', 6, 2, 2024);

-- DATA REDUNDANCY: '1' and 'Main Hospital' are repeated for both rooms on the first floor.
insert into dim_location_star (room_number, floor_number, building_name) values
('101A', 1, 'Main Hospital'), ('102B', 1, 'Main Hospital'), ('201', 2, 'Main Hospital'),
('305', 3, 'Main Hospital'), ('OP-1', 1, 'Outpatient Center');

-- Fact Table Data Insertion (Same exact fact data)
insert into fact_treatments_star (patient_id, procedure_id, doctor_id, time_id, room_id, treatment_cost, duration_minutes, success_rate) values
(1, 1, 1, 1, 3, 50000.00, 240, 0.95), (2, 3, 3, 2, 3, 25000.00, 180, 0.98), (3, 6, 4, 3, 5, 500.00, 45, 0.99),
(4, 2, 2, 4, 1, 3000.00, 60, 0.99), (5, 4, 5, 5, 3, 40000.00, 210, 0.92), (1, 5, 3, 6, 2, 150.00, 60, 1.00),
(2, 6, 4, 7, 5, 550.00, 45, 0.99), (3, 2, 2, 8, 1, 3200.00, 65, 0.98), (4, 1, 1, 1, 3, 51000.00, 250, 0.94),
(5, 3, 3, 2, 3, 26000.00, 185, 0.97), (1, 2, 2, 3, 1, 2900.00, 55, 1.00), (2, 5, 5, 4, 2, 200.00, 60, 1.00),
(3, 1, 1, 5, 3, 49000.00, 230, 0.96), (4, 4, 3, 6, 3, 42000.00, 220, 0.91), (5, 6, 4, 7, 5, 600.00, 50, 0.99),
(1, 3, 5, 8, 3, 25500.00, 190, 0.98), (2, 1, 1, 1, 3, 52000.00, 260, 0.93), (3, 5, 3, 2, 2, 180.00, 60, 1.00),
(4, 6, 4, 3, 5, 525.00, 45, 0.99), (5, 2, 2, 4, 1, 3100.00, 62, 0.99);

select
    p.risk_category_name,
    t.department_name,
    sum(f.treatment_cost) as total_cost
from fact_treatments_star f
join dim_patient_star p on f.patient_id = p.patient_id
join dim_treatment_star t on f.procedure_id = t.procedure_id
group by p.risk_category_name, t.department_name
order by total_cost desc;

select
    d.certification_level_name,
    t.quarter,
    avg(f.duration_minutes) as avg_duration
from fact_treatments_star f
join dim_doctor_star d on f.doctor_id = d.doctor_id
join dim_time_star t on f.time_id = t.time_id
group by d.certification_level_name, t.quarter
order by t.quarter, avg_duration desc;

select
    l.building_name,
    t.service_category_name,
    avg(f.success_rate) as avg_success_rate
from fact_treatments_star f
join dim_location_star l on f.room_id = l.room_id
join dim_treatment_star t on f.procedure_id = t.procedure_id
join dim_time_star ti on f.time_id = ti.time_id
where ti.year = 2024
group by l.building_name, t.service_category_name
order by l.building_name, avg_success_rate desc;

-- SNOWFLAKE
drop database if exists lab9_B;
create database lab9_B;
use lab9_B;

-- ---------------------------------
-- PATIENT DIMENSION (NORMALIZED)
-- ---------------------------------
-- Level 3: Risk Category
create table dim_risk_category (
    risk_category_id int primary key auto_increment,
    risk_category_name varchar(50) not null
);

-- Level 2: Age Group -> Risk Category
create table dim_age_group (
    age_group_id int primary key auto_increment,
    age_group_name varchar(50) not null,
    risk_category_id int,
    foreign key (risk_category_id) references dim_risk_category(risk_category_id)
);

-- Level 1: Patient -> Age Group
create table dim_patient (
    patient_id int primary key auto_increment,
    patient_name varchar(100) not null,
    age_group_id int,
    foreign key (age_group_id) references dim_age_group(age_group_id)
);


-- ---------------------------------
-- TREATMENT DIMENSION (NORMALIZED)
-- ---------------------------------
-- Level 3: Department
create table dim_department (
    department_id int primary key auto_increment,
    department_name varchar(50) not null
);

-- Level 2: Service Category -> Department
create table dim_service_category (
    service_category_id int primary key auto_increment,
    service_category_name varchar(50) not null,
    department_id int,
    foreign key (department_id) references dim_department(department_id)
);

-- Level 1: Procedure -> Service Category
create table dim_procedure (
    procedure_id int primary key auto_increment,
    procedure_name varchar(100) not null,
    service_category_id int,
    foreign key (service_category_id) references dim_service_category(service_category_id)
);


-- ---------------------------------
-- DOCTOR DIMENSION (NORMALIZED)
-- ---------------------------------
-- Level 3: Certification Level
create table dim_certification_level (
    certification_level_id int primary key auto_increment,
    certification_level_name varchar(50) not null
);

-- Level 2: Specialization -> Certification Level
create table dim_specialization (
    specialization_id int primary key auto_increment,
    specialization_name varchar(50) not null,
    certification_level_id int,
    foreign key (certification_level_id) references dim_certification_level(certification_level_id)
);

-- Level 1: Doctor -> Specialization
create table dim_doctor (
    doctor_id int primary key auto_increment,
    doctor_name varchar(100) not null,
    specialization_id int,
    foreign key (specialization_id) references dim_specialization(specialization_id)
);


-- ---------------------------------
-- LOCATION DIMENSION (NORMALIZED)
-- ---------------------------------
-- Level 3: Building
create table dim_building (
    building_id int primary key auto_increment,
    building_name varchar(50) not null
);

-- Level 2: Floor -> Building
create table dim_floor (
    floor_id int primary key auto_increment,
    floor_number int not null,
    building_id int,
    foreign key (building_id) references dim_building(building_id)
);

-- Level 1: Room -> Floor
create table dim_room (
    room_id int primary key auto_increment,
    room_number varchar(10) not null,
    floor_id int,
    foreign key (floor_id) references dim_floor(floor_id)
);


-- ---------------------------------
-- TIME DIMENSION
-- ---------------------------------
-- This dimension is typically flat and doesn't require further normalization.
create table dim_time (
    time_id int primary key auto_increment,
    full_date date not null,
    month int not null,
    quarter int not null,
    year int not null
);


-- ---------------------------------
-- FACT TABLE
-- ---------------------------------
-- References the lowest level of each normalized dimension.
create table fact_treatments (
    treatment_id int primary key auto_increment,
    patient_id int,
    procedure_id int,
    doctor_id int,
    time_id int,
    room_id int,
    treatment_cost decimal(10, 2),
    duration_minutes int,
    success_rate decimal(5, 2),
    foreign key (patient_id) references dim_patient(patient_id),
    foreign key (procedure_id) references dim_procedure(procedure_id),
    foreign key (doctor_id) references dim_doctor(doctor_id),
    foreign key (time_id) references dim_time(time_id),
    foreign key (room_id) references dim_room(room_id)
);


-- ---------------------------------
-- DATA INSERTION
-- ---------------------------------

set foreign_key_checks = 0;

-- Patient Dimension Data
insert into dim_risk_category (risk_category_name) values ('Low'), ('High'), ('Medium');
insert into dim_age_group (age_group_name, risk_category_id) values ('Adult', 1), ('Senior', 2), ('Pediatric', 3);
insert into dim_patient (patient_name, age_group_id) values ('John Smith', 1), ('Jane Doe', 2), ('Peter Jones', 3), ('Mary Williams', 1), ('David Brown', 2);

-- Treatment Dimension Data
insert into dim_department (department_name) values ('Cardiology'), ('Orthopedics'), ('Neurology');
insert into dim_service_category (service_category_name, department_id) values ('Surgical', 1), ('Diagnostic', 1), ('Surgical', 2), ('Rehabilitation', 2), ('Consultation', 3);
insert into dim_procedure (procedure_name, service_category_id) values ('Heart Bypass', 1), ('Angiogram', 2), ('Knee Replacement', 3), ('Spinal Fusion', 3), ('Physical Therapy', 4), ('EEG', 5);

-- Doctor Dimension Data
insert into dim_certification_level (certification_level_name) values ('Fellowship Trained'), ('Board Certified');
insert into dim_specialization (specialization_name, certification_level_id) values ('Cardiac Surgery', 1), ('Interventional Cardiology', 2), ('Orthopedic Surgery', 1), ('Neurology', 2);
insert into dim_doctor (doctor_name, specialization_id) values ('Dr. Alice', 1), ('Dr. Bob', 2), ('Dr. Charlie', 3), ('Dr. Diana', 4), ('Dr. Eve', 3);

-- Time Dimension Data
insert into dim_time (full_date, month, quarter, year) values
('2023-11-15', 11, 4, 2023), ('2023-12-20', 12, 4, 2023), ('2024-01-10', 1, 1, 2024), ('2024-02-05', 2, 1, 2024),
('2024-03-22', 3, 1, 2024), ('2024-04-18', 4, 2, 2024), ('2024-05-30', 5, 2, 2024), ('2024-06-12', 6, 2, 2024);

-- Location Dimension Data
insert into dim_building (building_name) values ('Main Hospital'), ('Outpatient Center');
insert into dim_floor (floor_number, building_id) values (1, 1), (2, 1), (3, 1), (1, 2);
insert into dim_room (room_number, floor_id) values ('101A', 1), ('102B', 1), ('201', 2), ('305', 3), ('OP-1', 4);

-- Fact Table Data Insertion (Same exact fact data)
-- The foreign key IDs match because we inserted the dimension data in the same order.
insert into fact_treatments (patient_id, procedure_id, doctor_id, time_id, room_id, treatment_cost, duration_minutes, success_rate) values
(1, 1, 1, 1, 3, 50000.00, 240, 0.95), (2, 3, 3, 2, 3, 25000.00, 180, 0.98), (3, 6, 4, 3, 5, 500.00, 45, 0.99),
(4, 2, 2, 4, 1, 3000.00, 60, 0.99), (5, 4, 5, 5, 3, 40000.00, 210, 0.92), (1, 5, 3, 6, 2, 150.00, 60, 1.00),
(2, 6, 4, 7, 5, 550.00, 45, 0.99), (3, 2, 2, 8, 1, 3200.00, 65, 0.98), (4, 1, 1, 1, 3, 51000.00, 250, 0.94),
(5, 3, 3, 2, 3, 26000.00, 185, 0.97), (1, 2, 2, 3, 1, 2900.00, 55, 1.00), (2, 5, 5, 4, 2, 200.00, 60, 1.00),
(3, 1, 1, 5, 3, 49000.00, 230, 0.96), (4, 4, 3, 6, 3, 42000.00, 220, 0.91), (5, 6, 4, 7, 5, 600.00, 50, 0.99),
(1, 3, 5, 8, 3, 25500.00, 190, 0.98), (2, 1, 1, 1, 3, 52000.00, 260, 0.93), (3, 5, 3, 2, 2, 180.00, 60, 1.00),
(4, 6, 4, 3, 5, 525.00, 45, 0.99), (5, 2, 2, 4, 1, 3100.00, 62, 0.99);

select
    rc.risk_category_name,
    d.department_name,
    sum(f.treatment_cost) as total_cost
from fact_treatments f
join dim_patient p on f.patient_id = p.patient_id
join dim_age_group ag on p.age_group_id = ag.age_group_id
join dim_risk_category rc on ag.risk_category_id = rc.risk_category_id
join dim_procedure proc on f.procedure_id = proc.procedure_id
join dim_service_category sc on proc.service_category_id = sc.service_category_id
join dim_department d on sc.department_id = d.department_id
group by rc.risk_category_name, d.department_name
order by total_cost desc;

select
    cl.certification_level_name,
    t.quarter,
    avg(f.duration_minutes) as avg_duration
from fact_treatments f
join dim_doctor d on f.doctor_id = d.doctor_id
join dim_specialization s on d.specialization_id = s.specialization_id
join dim_certification_level cl on s.certification_level_id = cl.certification_level_id
join dim_time t on f.time_id = t.time_id
group by cl.certification_level_name, t.quarter
order by t.quarter, avg_duration desc;

select
    b.building_name,
    sc.service_category_name,
    avg(f.success_rate) as avg_success_rate
from fact_treatments f
join dim_room r on f.room_id = r.room_id
join dim_floor fl on r.floor_id = fl.floor_id
join dim_building b on fl.building_id = b.building_id
join dim_procedure proc on f.procedure_id = proc.procedure_id
join dim_service_category sc on proc.service_category_id = sc.service_category_id
join dim_time t on f.time_id = t.time_id
where t.year = 2024
group by b.building_name, sc.service_category_name
order by b.building_name, avg_success_rate desc;

drop database if exists lab9_C;
create database lab9_C;
use lab9_C;

-- ---------------------------------
-- STUDENT DIMENSION (SNOWFLAKED ❄️)
-- ---------------------------------
-- This dimension is normalized to reduce redundancy and handle changes in college/department structure.
create table dim_college (
    college_id int primary key auto_increment,
    college_name varchar(100) not null
);

create table dim_department (
    department_id int primary key auto_increment,
    department_name varchar(100) not null,
    college_id int,
    foreign key (college_id) references dim_college(college_id)
);

create table dim_major (
    major_id int primary key auto_increment,
    major_name varchar(100) not null,
    department_id int,
    foreign key (department_id) references dim_department(department_id)
);

create table dim_student (
    student_id int primary key auto_increment,
    student_name varchar(100) not null,
    major_id int,
    foreign key (major_id) references dim_major(major_id)
);


-- ---------------------------------
-- OTHER DIMENSIONS (DENORMALIZED ⭐)
-- ---------------------------------
-- These dimensions are kept flat for query simplicity and performance, as their hierarchies are stable.
create table dim_course_star (
    course_id int primary key auto_increment,
    course_code varchar(10) not null,
    course_title varchar(100) not null,
    subject_name varchar(50) not null,
    program_name varchar(50) not null
);

create table dim_instructor_star (
    instructor_id int primary key auto_increment,
    instructor_name varchar(100) not null,
    instructor_rank varchar(50) not null,
    faculty_name varchar(50) not null
);

create table dim_time_star (
    time_id int primary key auto_increment,
    full_date date not null,
    semester varchar(20) not null, -- e.g., 'Fall 2024'
    academic_year varchar(10) not null -- e.g., '2024-2025'
);

create table dim_classroom_star (
    classroom_id int primary key auto_increment,
    room_number varchar(10) not null,
    building_name varchar(50) not null,
    campus_name varchar(50) not null
);

-- ---------------------------------
-- FACT TABLE 🎓
-- ---------------------------------
create table fact_enrollments (
    enrollment_id int primary key auto_increment,
    student_id int,
    course_id int,
    instructor_id int,
    time_id int,
    classroom_id int,
    enrollment_count int default 1, -- Usually 1 per row
    grade_points decimal(3, 2), -- e.g., 4.00, 3.33
    attendance_rate decimal(5, 2), -- e.g., 0.95 for 95%
    foreign key (student_id) references dim_student(student_id),
    foreign key (course_id) references dim_course_star(course_id),
    foreign key (instructor_id) references dim_instructor_star(instructor_id),
    foreign key (time_id) references dim_time_star(time_id),
    foreign key (classroom_id) references dim_classroom_star(classroom_id)
);

-- ---------------------------------
-- DATA INSERTION
-- ---------------------------------
-- Snowflaked Student Data
insert into dim_college (college_name) values ('College of Engineering'), ('College of Arts & Sciences');
insert into dim_department (department_name, college_id) values ('Computer Science', 1), ('Mechanical Engineering', 1), ('Physics', 2), ('History', 2);
insert into dim_major (major_name, department_id) values ('BS in AI', 1), ('BS in Software Engineering', 1), ('BS in Robotics', 2), ('BS in Astrophysics', 3), ('BA in World History', 4);
insert into dim_student (student_name, major_id) values ('Alice Johnson', 1), ('Bob Miller', 2), ('Charlie Davis', 1), ('Diana Prince', 3), ('Eve Adams', 4), ('Frank White', 5);

-- Denormalized Dimension Data
insert into dim_course_star (course_code, course_title, subject_name, program_name) values
('CS101', 'Intro to Programming', 'Computer Science', 'Undergraduate'), ('CS305', 'Databases', 'Computer Science', 'Undergraduate'),
('ME210', 'Thermodynamics', 'Mechanical Eng.', 'Undergraduate'), ('PHY450', 'Quantum Mechanics', 'Physics', 'Graduate'), ('HIS202', 'Modern Civilizations', 'History', 'Undergraduate');

insert into dim_instructor_star (instructor_name, instructor_rank, faculty_name) values
('Dr. Alan Turing', 'Professor', 'Faculty of STEM'), ('Dr. Marie Curie', 'Professor', 'Faculty of STEM'),
('Dr. Howard Zinn', 'Associate Professor', 'Faculty of Humanities');

insert into dim_time_star (full_date, semester, academic_year) values
('2024-09-10', 'Fall 2024', '2024-2025'), ('2025-02-15', 'Spring 2025', '2024-2025'),
('2025-09-12', 'Fall 2025', '2025-2026'), ('2026-02-20', 'Spring 2026', '2025-2026');

insert into dim_classroom_star (room_number, building_name, campus_name) values
('301', 'Hopper Hall', 'Main Campus'), ('105A', 'Edison Building', 'Main Campus'), ('220B', 'Arts Center', 'West Campus');

-- Fact Table Data (30 rows)
insert into fact_enrollments (student_id, course_id, instructor_id, time_id, classroom_id, grade_points, attendance_rate) values
(1, 1, 1, 1, 1, 4.00, 0.98), (2, 1, 1, 1, 1, 3.67, 0.95), (3, 1, 1, 1, 1, 3.33, 0.92),
(1, 2, 1, 2, 1, 3.67, 0.99), (2, 2, 1, 2, 1, 4.00, 0.94), (3, 2, 1, 2, 1, 3.00, 0.88),
(4, 3, 2, 1, 2, 4.00, 1.00), (4, 3, 2, 3, 2, 3.67, 0.97),
(5, 5, 3, 1, 3, 3.33, 0.91), (6, 5, 3, 1, 3, 4.00, 0.99),
(1, 1, 1, 3, 1, 3.67, 0.96), (2, 1, 1, 3, 1, 3.33, 0.94),
(5, 5, 3, 3, 3, 4.00, 1.00), (6, 5, 3, 3, 3, 3.67, 0.98),
(1, 4, 2, 4, 2, 3.33, 0.92), (4, 4, 2, 4, 2, 4.00, 0.99),
(1, 2, 1, 4, 1, 3.00, 0.90), (2, 2, 1, 4, 1, 3.67, 0.95),
(3, 2, 1, 4, 1, 3.33, 0.91), (4, 3, 2, 2, 2, 3.33, 0.96),
(5, 5, 3, 2, 3, 3.00, 0.85), (6, 5, 3, 2, 3, 3.67, 0.94),
(1, 4, 2, 2, 2, 3.00, 0.89), (4, 4, 2, 2, 2, 3.67, 0.93),
(1, 1, 1, 1, 1, 4.00, 0.98), (2, 1, 1, 1, 1, 3.67, 0.95),
(3, 1, 1, 1, 1, 3.33, 0.92), (1, 2, 1, 2, 1, 3.67, 0.99),
(2, 2, 1, 2, 1, 4.00, 0.94), (3, 2, 1, 2, 1, 3.00, 0.88);

select
    c.college_name,
    t.semester,
    avg(f.grade_points) as average_grade
from fact_enrollments f
join dim_student s on f.student_id = s.student_id
join dim_major m on s.major_id = m.major_id
join dim_department d on m.department_id = d.department_id
join dim_college c on d.college_id = c.college_id
join dim_time_star t on f.time_id = t.time_id
group by c.college_name, t.semester
order by c.college_name, t.semester;

select
    c.program_name,
    t.academic_year,
    sum(f.enrollment_count) as total_enrollments
from fact_enrollments f
join dim_course_star c on f.course_id = c.course_id
join dim_time_star t on f.time_id = t.time_id
group by c.program_name, t.academic_year
order by c.program_name, t.academic_year;

select
    cl.campus_name,
    i.faculty_name,
    avg(f.attendance_rate) as average_attendance
from fact_enrollments f
join dim_classroom_star cl on f.classroom_id = cl.classroom_id
join dim_instructor_star i on f.instructor_id = i.instructor_id
group by cl.campus_name, i.faculty_name
order by cl.campus_name, i.faculty_name;