-- Customer Demographics Mini-Dimension
create table customer_demographics (
    demo_id int primary key,
    age_bracket varchar(20),
    income_bracket varchar(20),
    location_type varchar(20)
);

-- Customer Dimension
create table customer_dim (
    customer_id int primary key,
    demo_id int,
    customer_name varchar(100),
    email varchar(100),
    foreign key (demo_id) references customer_demographics(demo_id)
);

-- Orders Table (Hash Partitioned by customer_id)
create table orders_hash (
    order_id int not null auto_increment,
    customer_id int not null,
    order_date date,
    total_amount decimal(10,2),
    status varchar(20),
    primary key (order_id, customer_id)
)
partition by hash(customer_id)
partitions 4;

-- Sales Fact Table (Range Partitioned by year)
create table sales_range (
    sale_id int not null auto_increment,
    order_id int not null,
    product_id int not null,
    sale_date date not null,
    quantity int,
    revenue decimal(10,2),
    primary key (sale_id, sale_date)
)
partition by range (year(sale_date)) (
    partition p_2022 values less than (2023),
    partition p_2023 values less than (2024),
    partition p_2024 values less than (2025),
    partition p_future values less than maxvalue
);

-- Inserts
insert into customer_demographics values
    (1, '18-25', 'Low', 'Urban'),
    (2, '26-35', 'Medium', 'Suburban'),
    (3, '26-35', 'High', 'Urban'),
    (4, '36-45', 'High', 'Suburban'),
    (5, '46-55', 'Medium', 'Rural');

insert into customer_dim values
    (101, 1, 'John Smith', 'john@email.com'),
    (102, 2, 'Sarah Jones', 'sarah@email.com'),
    (103, 3, 'Mike Brown', 'mike@email.com'),
    (104, 4, 'Emily Davis', 'emily@email.com'),
    (105, 5, 'Robert Wilson', 'robert@email.com');

insert into orders_hash values
    (1, 101, '2023-11-15', 250.00, 'Delivered'),
    (2, 102, '2023-11-20', 450.00, 'Delivered'),
    (3, 103, '2023-12-05', 800.00, 'Delivered'),
    (4, 104, '2024-01-10', 320.00, 'Shipped'),
    (5, 105, '2024-02-14', 150.00, 'Delivered'),
    (6, 101, '2024-03-20', 550.00, 'Processing'),
    (7, 103, '2024-04-05', 920.00, 'Delivered');

insert into sales_range values
    (1, 1, 201, '2023-11-15', 2, 200.00),
    (2, 1, 202, '2023-11-15', 1, 50.00),
    (3, 2, 203, '2023-11-20', 3, 450.00),
    (4, 3, 201, '2023-12-05', 4, 800.00),
    (5, 4, 204, '2024-01-10', 2, 320.00),
    (6, 5, 202, '2024-02-14', 3, 150.00),
    (7, 6, 203, '2024-03-20', 5, 550.00),
    (8, 7, 201, '2024-04-05', 6, 920.00);

-- Write a query to retrieve all sales records from the year 2024 only. Use the partition name p_2024 directly in your query.
select *
from sales_range partition (p_2024);

-- 2. Write a query that shows each customer's name along with their age_bracket and
-- income_bracket. Join the customer_dim and customer_demographics tables.
select cd.customer_name, cdemo.age_bracket, cdemo.income_bracket
from customer_dim cd
join customer_demographics cdemo on cd.demo_id = cdemo.demo_id;

-- 3. Calculate the total revenue (sum of total_amount from orders) for each age_bracket. Join
-- orders_hash, customer_dim, and customer_demographics tables. Group by age_bracket and
-- order by total revenue descending.
select cdemo.age_bracket, sum(oh.total_amount) as total_revenue
from orders_hash oh
join customer_dim cd on oh.customer_id = cd.customer_id
join customer_demographics cdemo on cd.demo_id = cdemo.demo_id
group by cdemo.age_bracket
order by total_revenue desc;