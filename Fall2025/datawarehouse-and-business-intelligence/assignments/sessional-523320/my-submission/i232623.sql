drop database i232623_A;
create database i232623_A;
use i232623_A;

-- OLTP DB
drop table dim_student;
create table dim_student
(
sid int primary key auto_increment,
sname varchar(64),
email varchar(64),
age int,
enrollment_date date,
subscription_tier varchar(128),
city varchar(64),
state varchar(64),
country varchar(64),
region varchar(64)
);

insert into dim_student(sname,email,age,enrollment_date,subscription_tier,city,state,country,region)
values 
("Muneeb","muneeb@gmail.com",21,"2023-08-01","Premium", "Rawalpindi","Punjab","Pakistan","Asia"),
("Kabeer","kabeer@gmail.com",20,"2023-08-01","Free", "Rawalpindi","Gujranwala","Pakistan","Asia"),
("Taha","taha@gmail.com",21,"2023-08-01","Basic", "Rawalpindi","Islamabad","Pakistan","Asia"),
("Mustafa","musta@gmail.com",21,"2023-08-01","Enterprise", "Rawalpindi","Punjab","Pakistan","Asia"),
("Yaya","yaya@gmail.com",23,"2023-08-01","Premium", "Lahore","Punjab","Pakistan","Asia");

create table dim_course
(
cid int primary key auto_increment,
cname varchar(64),
durationHours int,
difficulty varchar(64),
price_usd decimal(10,2),
subcategory varchar(64),
category varchar(64),
domain varchar(64)
);

insert into dim_course
values 
(1,"Algorithms", 3,"Advanced",89.99,"Code","Computer Science","Technology"),
(2,"DWBI", 3,"Master",99.99,"Data Science","Computer Science","Technology"),
(3,"Calculus", 3,"Foundation",9.99,"Pure Math","Mathematics","Sciences"),
(4,"Arts", 3,"Intermediate",89.99,"Performative","Jeo","Creative"),
(5,"Economics", 3,"Advanced",49.99,"Finance","Meow","Business");

create table dim_instructor
(
iid int primary key auto_increment,
iname varchar(64),
rating decimal(10,2),
years_experience int,
country varchar(128),
specialization varchar(64),
certification_level varchar(64)
);

insert into dim_instructor
values
(1,"Nayyera Wasim", 5.0,0,"Pakistan","Data Science", "Associate"),
(2,"Shoaib Saleem", 4.5,12,"Pakistan","Computer Vision", "Master"),
(3,"Kanza Hamid", 4.0,6,"Pakistan","Operating Systems", "Expert"),
(4, "Muneeb Lone", 5.0,100, "Pakistan","Everything","Master"),
(5,"Kabeer Ali", 0.0,0,"Pakistan","Everything", "Professional");

create table dim_time
(
tid int primary key auto_increment,
day_name varchar(32),
is_weekend bool,
is_holiday bool,
date date,
week int,
month int,
quarter int,
year int
);

insert into dim_time
values
(1,"Thursday",0,0,"2025-10-30", 1,10,4,2025),
(2,"Friday",1,0,"2025-10-31", 1,10,4,2025),
(3,"Saturday",1,1,"2025-11-01", 1,11,4,2025),
(4,"Sunday",1,1,"2025-11-02", 1,11,4,2025),
(5,"Monday",0,0,"2025-11-03", 1,11,4,2025);

-- adding derived calculations to oltp fact table

create table fact_table
(
revenue_usd decimal(10,2),
discount_percent decimal(10,2),
time_spent_hours int,
final_grade INT,
completion_status varchar(32),
sid int,
cid int,
iid int,
tid int,
constraint foreign key (sid) REFERENCES dim_student(sid),
constraint foreign key (cid) REFERENCES dim_course(cid),
constraint foreign key (iid) REFERENCES dim_instructor(iid),
constraint foreign key (tid) REFERENCES dim_time(tid)
);

insert into fact_table
values
(5000,20,50,90,"Completed",1,1,2,1),
(6000,10,100,49,"Dropped",2,2,1,2);

alter table fact_table
add column completion_rate int;


-- unknown system variable error never seen before
-- set completed = (select count(*) from fact_table where completion_status = "Completed");
-- set notcompleted = (select count(*) from fact_table where completion_status != "Completed");


update fact_table
set completion_rate = (completed/notcompleted) * 100;

alter table fact_table
add column net_revenue decimal(10,2);

update fact_table
set net_revenue = revenue_usd * (discount_percent / 100);

alter table fact_table
add column revenue_per_hour decimal(10,2);

update fact_table
set revenue_per_hour = revenue_usd / time_spent_hours;

alter table fact_table
add column pass_fail_indicator varchar(16);

update fact_table
set pass_fail_indicator = case when final_grade >= 50 then "Pass" else "Fail" END;

alter table fact_table
add column grade_category varchar(1);

update fact_table
set grade_category = case 
when final_grade >= 80 then "A" 
when final_grade >= 70 and final_grade <80 then "B"
when final_grade >= 60 and final_grade < 70 then "C"
when final_grade >= 50 and final_grade < 60 then "D"
when final_grade < 50 then  grade_category = "F" END;

-- complex queries

select c.category, s.region, d.year, avg(f.final_grade), sum(f.revenue_usd)
from fact_table f
join dim_course c on c.cid = f.cid
join dim_student s on s.sid = f.sid
join dim_time d on d.tid = f.tid
where d.year = 2024
group by c.category,s.region,d.year
having avg(f.final_grade) >= 70 -- and completion_rate>65
order by sum(f.revenue_usd) desc
limit 3;

select sum(f.revenue_usd) as MonthRev, s.region, d.month, coalesce(lag(sum(f.revenue_usd)) over (partition by d.month order by sum(f.revenue_usd)), "Prev Month not available") as prevMonthRev
from fact_table f
join dim_student s on s.sid = f.sid
join dim_time d on d.tid = f.tid
group by s.region,d.month;

select * from fact_table;

select s.city,s.country, avg(f.final_grade), count(f.sid) as enrollments
from fact_table f
join dim_student s on s.sid = f.sid
group by s.city, s.country
having enrollments >= 50 -- and completion_rate>70;
order by avg(f.final_grade) desc
limit 3;




-- STARFLAKE
create database i232623_B;
use i232623_B;



create table city
( cityid int primary key);
create table state
( stateid int primary key);
create table country
( countryid int primary key );
create table region
( regionid int primary key );


create table dim_student
(
sid int primary key auto_increment,
sname varchar(64),
email varchar(64),
age int,
enrollment_date date,
subscription_tier varchar(128),
cityid int,
stateid int,
countryid int,
regionid int,
constraint foreign key (cityid) references city(cityid),
constraint foreign key (stateid) references state(stateid),
constraint foreign key (countryid) references country(countryid),
constraint foreign key (regionid) references region(regionid)
);


create table subcategory
( subid int primary key);
create table category
(categoryid int primary key);
create table domain
(domainid int primary key);

create table dim_course
(
cid int primary key auto_increment,
cname varchar(64),
durationHours int,
difficulty varchar(64),
price_usd decimal(10,2),
subid int,
categoryid int,
domainid int,
constraint foreign key (subid) references subcategory(subid),
constraint foreign key (categoryid) references category(categoryid),
constraint foreign key (domainid) references domain(domainid)
);

create table specialization
( specid int primary key);
create table certification
(cerid int primary key);

create table dim_instructor
(
iid int primary key auto_increment,
iname varchar(64),
rating decimal(10,2),
years_experience int,
country varchar(128),
specid int,
cerid int,
constraint foreign key (specid) references specialization(specid),
constraint foreign key (cerid) references certification (cerid)
);

create table dim_time
(
tid int primary key auto_increment,
day_name varchar(32),
is_weekend bool,
is_holiday bool,
date date,
week int,
month int,
quarter int,
year int
); -- assuming divisions into snowflake no time left

-- adding derived calculations to oltp fact table

create table fact_table
(
revenue_usd decimal(10,2),
discount_percent decimal(10,2),
time_spent_hours int,
final_grade INT,
completion_status varchar(32),
sid int,
cid int,
iid int,
tid int,
constraint foreign key (sid) REFERENCES dim_student(sid),
constraint foreign key (cid) REFERENCES dim_course(cid),
constraint foreign key (iid) REFERENCES dim_instructor(iid),
constraint foreign key (tid) REFERENCES dim_time(tid)
);


alter table fact_table
add column net_revenue decimal(10,2);

update fact_table
set net_revenue = revenue_usd * (discount_percent / 100);

alter table fact_table
add column revenue_per_hour decimal(10,2);

update fact_table
set revenue_per_hour = revenue_usd / time_spent_hours;

alter table fact_table
add column pass_fail_indicator varchar(16);

update fact_table
set pass_fail_indicator = case when final_grade >= 50 then "Pass" else "Fail" END;

alter table fact_table
add column grade_category varchar(1);

update fact_table
set grade_category = case 
when final_grade >= 80 then "A" 
when final_grade >= 70 and final_grade <80 then "B"
when final_grade >= 60 and final_grade < 70 then "C"
when final_grade >= 50 and final_grade < 60 then "D"
when final_grade < 50 then  grade_category = "F" END;

select sum(f.revenue_usd), avg(f.final_grade) from fact_table f 
join dim_course c on f.cid = c.cid join subcategory s on c.subid = s.subid;


-- dice -> multiple groupbys

-- roll up -> lower to higher granularity

-- drill down -> higher to lower granularity
