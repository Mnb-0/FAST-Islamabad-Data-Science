drop database if exists lab;
create database if not exists lab;
use lab;

-- task 1: horizontal partitioning - sales data warehouse
-- create sales data warehouse with range partitioning by sale_date
drop table sales_dw;
create table sales_dw (
    sale_id int not null auto_increment,
    product_id int not null,
    store_id int not null,
    sale_date date not null,
    sale_amount decimal(10,2),
    units_sold int,
    discount_percent decimal(5,2),
    primary key (sale_id, sale_date)
)
partition by range (year(sale_date)) (
    partition p_2020 values less than (2021),
    partition p_2021 values less than (2022),
    partition p_2022 values less than (2023),
    partition p_2023 values less than (2024),
    partition p_2024 values less than (2025),
    partition p_future values less than (2026)
);

-- insert 50 sample records into sales_dw
insert into sales_dw (product_id, store_id, sale_date, sale_amount, units_sold, discount_percent) 
values
(101, 1, '2020-02-15', 500.00, 5, 10),
(102, 2, '2020-03-20', 650.00, 6, 5),
(103, 3, '2020-04-10', 320.00, 3, 15),
(104, 4, '2020-06-15', 410.00, 4, 20),
(105, 5, '2020-07-25', 550.00, 5, 10),
(106, 1, '2020-09-05', 600.00, 5, 12),
(107, 2, '2020-10-01', 700.00, 7, 8),
(108, 3, '2020-11-22', 300.00, 2, 18),
(109, 4, '2020-12-15', 460.00, 4, 10),
(110, 5, '2021-01-10', 520.00, 6, 9);

-- add new partition for 2025
alter table sales_dw
add partition (partition p_2025 values less than (2027));

-- task 2: list partitioning - customer regional analysis
-- create customers table with list partitioning by country

create table customers_regional (
    customer_id int not null auto_increment,
    customer_name varchar(100),
    country varchar(50) not null,
    city varchar(50),
    industry varchar(50),
    annual_revenue decimal(15,2),
    primary key (customer_id, country)
)
partition by list columns(country) (
    partition p_na values in ('usa', 'canada', 'mexico'),
    partition p_europe values in ('germany', 'france', 'uk', 'italy'),
    partition p_asia values in ('china', 'japan', 'india'),
    partition p_other values in ('australia', 'brazil', 'south africa')
);

-- insert 30 customer records across regions
insert into customers_regional (customer_name, country, city, industry, annual_revenue) 
values
('tech corp', 'usa', 'new york', 'tech', 5000000),
('paris co.', 'france', 'paris', 'retail', 1000000);

-- query all european customers
select * from customers_regional where country in ('germany', 'france', 'uk', 'italy');

-- show partition distribution statistics
select partition_name, table_rows
from information_schema.partitions
where table_name = 'customers_regional';

-- task 3: hash partitioning - order distribution
-- create orders table with hash partitioning by customer_id

create table orders_distributed (
    order_id int not null auto_increment,
    customer_id int not null,
    order_date datetime,
    status enum('pending', 'processing', 'shipped', 'delivered'),
    total_amount decimal(10,2),
    primary key (order_id, customer_id) -- include customer_id in the primary key
)
partition by hash(customer_id)
partitions 6;

-- insert 60 orders with customer_ids from 1000-1059
insert into orders_distributed (customer_id, order_date, status, total_amount) 
values
(1000, '2024-01-15', 'shipped', 250.00),
(1001, '2024-01-16', 'processing', 180.50);

-- query orders for customer_id = 1025 and analyze which partition is accessed
explain select * from orders_distributed where customer_id = 1025;

-- calculate total order amount per partition
select 
    p.partition_name, 
    sum(o.total_amount) as total_order_amount
from 
    orders_distributed o
join 
    information_schema.partitions p
    on p.table_name = 'orders_distributed' 
    and p.table_schema = database()  -- make sure it's the right schema
group by 
    p.partition_name;


-- task 4: vertical partitioning - product catalog
-- create tables for product vertical partitioning

create table product_core (
    product_id int primary key,
    product_name varchar(100),
    category varchar(50),
    price decimal(10,2),
    stock_quantity int,
    index idx_category (category)
);

create table product_details (
    product_id int primary key,
    description text,
    specifications text,
    manufacturer varchar(100),
    warranty_info varchar(200),
    foreign key (product_id) references product_core(product_id)
);

create table product_media (
    product_id int primary key,
    image_url varchar(255),
    video_url varchar(255),
    manual_pdf_url varchar(255),
    foreign key (product_id) references product_core(product_id)
);

-- insert 25 products with complete information across all three tables
insert into product_core values
(1, 'laptop', 'electronics', 1000.00, 50),
(2, 'smartphone', 'electronics', 700.00, 200);

-- create a view to reconstruct the complete product information
create view product_complete as
select p.product_id, p.product_name, p.category, p.price, p.stock_quantity, 
       d.description, d.specifications, d.manufacturer, d.warranty_info,
       m.image_url, m.video_url, m.manual_pdf_url
from product_core p
left join product_details d on p.product_id = d.product_id
left join product_media m on p.product_id = m.product_id;

-- query performance comparison: fast query on product_core vs full join
select * from product_core where category = 'electronics';
select * from product_complete where product_id = 1;

-- task 5: mini-dimensions - customer analytics
-- create mini-dimension for demographics

create table customer_demographics (
    demo_id int primary key auto_increment,
    age_bracket varchar(20),
    income_bracket varchar(20),
    location_type varchar(20),
    index idx_brackets (age_bracket, income_bracket),
    unique key unique_demo (age_bracket, income_bracket, location_type)
);

-- create simplified customer dimension
create table customer_dim (
    customer_id int primary key auto_increment,
    demo_id int,
    customer_name varchar(100),
    email varchar(100),
    registration_date date,
    foreign key (demo_id) references customer_demographics(demo_id)
);

-- create fact table linking to mini-dimension
create table purchase_fact (
    purchase_id int primary key auto_increment,
    customer_id int,
    demo_id int,
    purchase_date date,
    product_category varchar(50),
    amount decimal(10,2),
    foreign key (customer_id) references customer_dim(customer_id),
    foreign key (demo_id) references customer_demographics(demo_id),
    index idx_demo (demo_id),
    index idx_date (purchase_date)
);

-- insert 10 distinct demographic profiles in customer_demographics
insert into customer_demographics (age_bracket, income_bracket, location_type) 
values
('18-25', 'low', 'urban'),
('26-35', 'medium', 'suburban');

-- insert 40 customers linked to demographics
insert into customer_dim (demo_id, customer_name, email, registration_date) 
values
(1, 'mike brown', 'mike.b@email.com', '2023-01-15'),
(2, 'sarah davis', 'sarah.d@email.com', '2023-02-20');

-- insert 100 purchase records
insert into purchase_fact (customer_id, demo_id, purchase_date, product_category, amount)
values
(1, 1, '2023-01-15', 'electronics', 250.00),
(2, 2, '2023-01-16', 'clothing', 180.50);

-- analytical query: total purchases by age_bracket and income_bracket
select d.age_bracket, d.income_bracket, sum(f.amount) as total_purchases
from purchase_fact f
join customer_demographics d on f.demo_id = d.demo_id
group by d.age_bracket, d.income_bracket
order by total_purchases desc;

-- calculate average purchase amount by location_type
select d.location_type, avg(f.amount) as avg_purchase
from purchase_fact f
join customer_demographics d on f.demo_id = d.demo_id
group by d.location_type;