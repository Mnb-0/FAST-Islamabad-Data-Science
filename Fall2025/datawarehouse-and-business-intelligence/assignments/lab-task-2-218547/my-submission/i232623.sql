drop database Company;

create database Company;
use Company;

create table Employee(

	empid int primary key,
    fname varchar(64),
    lname varchar(64),
    dep varchar(32),
    salary int,
    hiredate date
);

INSERT INTO Employee (empid, fname, lname, dep, salary, hiredate)
VALUES
(1, 'John', 'Doe', 'HR', 55000, '2020-02-15'),
(2, 'Jane', 'Smith', 'IT', 75000, '2021-05-21'),
(3, 'Alice', 'Johnson', 'Sales', 60000, '2019-08-30'),
(4, 'Bob', 'Williams', 'Marketing', 48000, '2022-03-10'),
(5, 'Charlie', 'Brown', 'Engineering', 88000, '2018-11-04'),
(6, 'David', 'Davis', 'Finance', 70000, '2020-07-17'),
(7, 'Emma', 'Miller', 'HR', 52000, '2021-06-11'),
(8, 'Frank', 'Wilson', 'Sales', 63000, '2019-12-23'),
(9, 'Grace', 'Moore', 'Marketing', 54000, '2022-01-29'),
(10, 'Harry', 'Taylor', 'IT', 95000, '2017-05-06'),
-- Add more rows as needed to reach 100
(11, 'Ivy', 'Anderson', 'Finance', 76000, '2020-10-01'),
(12, 'Jack', 'Thomas', 'Sales', 58000, '2022-07-23'),
(13, 'Kathy', 'Jackson', 'Marketing', 49000, '2018-02-17'),
(14, 'Leo', 'White', 'Engineering', 85000, '2021-03-14'),
(15, 'Mona', 'Harris', 'HR', 56000, '2021-11-09'),
(16, 'Nathan', 'Martin', 'Finance', 72000, '2020-12-30'),
(17, 'Olivia', 'Garcia', 'Sales', 59000, '2018-10-18'),
(18, 'Paul', 'Rodriguez', 'Engineering', 78000, '2021-04-05'),
(19, 'Quincy', 'Lewis', 'HR', 50000, '2019-01-11'),
(20, 'Rita', 'Lee', 'Marketing', 45000, '2022-02-18'),
(21, 'Sam', 'Walker', 'Engineering', 80000, '2019-07-23'),
(22, 'Tina', 'Allen', 'Finance', 68000, '2021-09-12'),
(23, 'Ursula', 'Young', 'Sales', 57000, '2020-05-25'),
(24, 'Victor', 'King', 'HR', 53000, '2022-03-22'),
(25, 'Wendy', 'Scott', 'Marketing', 51000, '2017-09-03'),
(26, 'Xander', 'Green', 'Engineering', 90000, '2021-06-06'),
(27, 'Yvonne', 'Adams', 'Finance', 74000, '2020-01-15'),
(28, 'Zane', 'Baker', 'Sales', 62000, '2018-12-09'),
(29, 'Alan', 'Nelson', 'HR', 53000, '2019-05-04'),
(30, 'Beth', 'Carter', 'Engineering', 95000, '2021-08-14');

select * from Employee;

select fname, salary from Employee;

select * from Employee where dep = "IT";

select * from Employee where salary > 50000;

select * from Employee order by hiredate desc;

select distinct dep from Employee;

select * from employee order by salary desc limit 3;

select count(*) from employee where dep = "HR";

select avg(salary) from employee where dep = "IT";

select fname, lname from employee where fname like "A%";

select dep, max(salary) from employee group by dep;

select fname, lname from employee where salary > 45000 and salary < 60000;

select dep, avg(salary) from employee group by dep having avg(salary) > 55000;

select fname, lname from employee where hiredate > 01/01/2020;

select concat(fname," ", lname) from employee;

select salary from employee order by salary desc limit 1 offset 1;

select fname, lname, dep from employee where dep != "IT" and dep != "HR";

select fname, lname, hiredate from employee order by hiredate asc limit 1;

select dep, count(*) from employee  group by dep order by count(*) desc;

select fname, lname, salary from employee where salary > (select avg(salary) from employee);



