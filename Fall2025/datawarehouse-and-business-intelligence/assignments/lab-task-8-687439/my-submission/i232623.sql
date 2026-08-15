drop database Lab8;
create database Lab8;
use Lab8;
set sql_safe_updates = 0;
-- drop tables if they exist to start fresh
drop table if exists sales_fact;
drop table if exists product_dim;
drop table if exists store_dim;
drop table if exists time_dim;

-- create dimension tables
create table product_dim (
    product_key int primary key,
    product_name varchar(100),
    category varchar(50)
);

create table store_dim (
    store_key int primary key,
    store_city varchar(50)
);

create table time_dim (
    time_key date primary key,
    month_name varchar(20),
    quarter_num int,
    year_num int
);

-- create fact table
create table sales_fact (
    product_key int,
    store_key int,
    time_key date,
    turnover decimal(10, 2),
    foreign key (product_key) references product_dim(product_key),
    foreign key (store_key) references store_dim(store_key),
    foreign key (time_key) references time_dim(time_key)
);

-- populate dimension tables
insert into product_dim values
(1, 'laptop', 'electronics'),
(2, 'smartphone', 'electronics'),
(3, 't-shirt', 'apparel');

insert into store_dim values
(1, 'islamabad'),
(2, 'lahore'),
(3, 'karachi');

insert into time_dim values
('2023-01-15', 'january', 1, 2023),
('2023-02-20', 'february', 1, 2023),
('2023-04-10', 'april', 2, 2023),
('2023-05-25', 'may', 2, 2023),
('2023-08-05', 'august', 3, 2023);

-- populate fact table
insert into sales_fact values
(1, 1, '2023-01-15', 1500.00),
(2, 1, '2023-02-20', 800.00),
(3, 2, '2023-04-10', 50.00),
(1, 2, '2023-05-25', 1450.00),
(2, 3, '2023-08-05', 850.00),
(3, 1, '2023-01-15', 45.00);


-- slice for store_city = 'islamabad'
select
    p.product_name,
    t.month_name,
    s.turnover,
    st.store_city
from sales_fact s
join product_dim p on s.product_key = p.product_key
join store_dim st on s.store_key = st.store_key
join time_dim t on s.time_key = t.time_key
where st.store_city = 'islamabad';

 -- dice
select
    p.product_name,
    st.store_city,
    t.month_name,
    s.turnover
from sales_fact s
join product_dim p on s.product_key = p.product_key
join store_dim st on s.store_key = st.store_key
join time_dim t on s.time_key = t.time_key
where
    p.category = 'electronics'
    and t.quarter_num = 1
    and st.store_city in ('islamabad', 'lahore');

-- setup table for scd type 1
create table product_scd1 (
    product_id int primary key,
    product_name varchar(100),
    unit_price decimal(10, 2)
);
insert into product_scd1 values (101, 'gaming mouse', 49.99);

-- check original price
select * from product_scd1 where product_id = 101;

-- update the price (overwrite the old value)
update product_scd1
set unit_price = 55.00
where product_id = 101;

-- check the new price; the old price is lost
select * from product_scd1 where product_id = 101;

-- setup table for scd type 2
create table customer_dim_scd2 (
    customer_key int primary key auto_increment,
    customer_id int,
    city varchar(50),
    effective_date date,
    expiry_date date,
    is_current boolean
);

-- initial record for customer 1001
insert into customer_dim_scd2 (customer_id, city, effective_date, expiry_date, is_current)
values (1001, 'lahore', '2023-01-01', '9999-12-31', true);

-- first change: customer moves to islamabad on 2023-06-01
-- step 1: close the old record
update customer_dim_scd2
set expiry_date = '2023-05-31', is_current = false
where customer_id = 1001 and is_current = true;

-- step 2: insert the new record
insert into customer_dim_scd2 (customer_id, city, effective_date, expiry_date, is_current)
values (1001, 'islamabad', '2023-06-01', '9999-12-31', true);

-- second change: customer moves to karachi on 2024-02-15
-- step 1: close the old record
update customer_dim_scd2
set expiry_date = '2024-02-14', is_current = false
where customer_id = 1001 and is_current = true;

-- step 2: insert the new record
insert into customer_dim_scd2 (customer_id, city, effective_date, expiry_date, is_current)
values (1001, 'karachi', '2024-02-15', '9999-12-31', true);

-- query for the current state
select * from customer_dim_scd2 where customer_id = 1001 and is_current = true;

-- query for the historical state as of '2023-08-01'
select * from customer_dim_scd2
where customer_id = 1001 and '2023-08-01' between effective_date and expiry_date;

-- setup table for scd type 3
create table store_dim_scd3 (
    store_id int primary key,
    store_name varchar(100),
    current_city varchar(50),
    previous_city varchar(50),
    relocation_date date
);
insert into store_dim_scd3 values (5, 'flagship store', 'lahore', null, null);

-- check original location
select * from store_dim_scd3 where store_id = 5;


-- store relocates to karachi
update store_dim_scd3
set previous_city = current_city,
    current_city = 'karachi',
    relocation_date = '2023-08-01'
where store_id = 5;

-- check new and previous location
select * from store_dim_scd3 where store_id = 5;


-- setup validity matrix table
create table hierarchy_validity (
    hierarchy_id int primary key auto_increment,
    dimension_name varchar(50),
    parent_node varchar(100),
    child_node varchar(100),
    level_name varchar(50),
    valid_from date,
    valid_to date
);

-- populate with payment method evolution data
insert into hierarchy_validity (dimension_name, parent_node, child_node, level_name, valid_from, valid_to) values
-- Level 1: Base methods
('payment', 'all', 'traditional', 'level1', '2000-01-01', '9999-12-31'),
('payment', 'traditional', 'cash', 'level2', '2000-01-01', '9999-12-31'),
('payment', 'traditional', 'card', 'level2', '2000-01-01', '9999-12-31'),

-- Level 1: Digital wallets emerge
('payment', 'all', 'digital wallet', 'level1', '2010-01-01', '9999-12-31'),
('payment', 'digital wallet', 'easypaisa', 'level2', '2010-01-01', '9999-12-31'),
('payment', 'digital wallet', 'jazzcash', 'level2', '2012-01-01', '9999-12-31'),

-- Level 1: Crypto emerges
('payment', 'all', 'crypto', 'level1', '2018-01-01', '9999-12-31'),
('payment', 'crypto', 'bitcoin', 'level2', '2018-01-01', '9999-12-31'),
('payment', 'crypto', 'ethereum', 'level2', '2020-01-01', '9999-12-31'),

-- Change: Card gets a sub-category 'contactless'
('payment', 'card', 'contactless', 'level3', '2015-01-01', '9999-12-31');

select parent_node, child_node, level_name
from hierarchy_validity
where dimension_name = 'payment'
and '2014-01-01' between valid_from and valid_to
order by level_name, parent_node;

select parent_node, child_node, level_name
from hierarchy_validity
where dimension_name = 'payment'
and current_date between valid_from and valid_to
order by level_name, parent_node;
