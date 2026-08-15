drop database company;
create database company;
use company;

set sql_safe_updates = 0;

-- Customer Table (Dim)
CREATE TABLE Customer (
    CustomerID INT PRIMARY KEY,
    FirstName VARCHAR(50),
    LastName VARCHAR(50),
    Region VARCHAR(50),
    Email VARCHAR(100)
);

-- Insert Sample Data into Customer Table (Dim)
INSERT INTO Customer (CustomerID, FirstName, LastName, Region, Email) VALUES
(1, 'John', 'Doe', 'North America', 'john.doe@email.com'),
(2, 'Jane', 'Smith', 'Europe', 'jane.smith@email.com'),
(3, 'Carlos', 'Gomez', 'Latin America', 'carlos.gomez@email.com'),
(4, 'Maria', 'Lopez', 'Asia', 'maria.lopez@email.com'),
(5, 'Emily', 'Davis', 'North America', 'emily.davis@email.com'),
(6, 'Ahmed', 'Khan', 'Middle East', 'ahmed.khan@email.com'),
(7, 'Sophie', 'Miller', 'Europe', 'sophie.miller@email.com'),
(8, 'Liam', 'Brown', 'North America', 'liam.brown@email.com'),
(9, 'Chloe', 'Wilson', 'Africa', 'chloe.wilson@email.com'),
(10, 'Lucas', 'Martinez', 'Latin America', 'lucas.martinez@email.com');

-- Product Table (Dim)
CREATE TABLE Product (
    ProductID INT PRIMARY KEY,
    ProductName VARCHAR(100),
    Category VARCHAR(50),
    Price DECIMAL(10, 2)
);

-- Insert Sample Data into Product Table (Dim)
INSERT INTO Product (ProductID, ProductName, Category, Price) VALUES
(1, 'Laptop', 'Electronics', 1200.00),
(2, 'Headphones', 'Electronics', 150.00),
(3, 'Chair', 'Furniture', 300.00),
(4, 'Desk', 'Furniture', 500.00),
(5, 'Smartphone', 'Electronics', 800.00),
(6, 'Smartwatch', 'Electronics', 250.00),
(7, 'Gaming Console', 'Electronics', 400.00),
(8, 'Coffee Table', 'Furniture', 200.00),
(9, 'Bookshelf', 'Furniture', 150.00),
(10, 'Air Conditioner', 'Home Appliances', 600.00);

-- Date Table (Dim)
CREATE TABLE Date (
    DateID INT PRIMARY KEY,
    Date DATE,
    Month INT,
    Quarter INT,
    Year INT
);

-- Insert Sample Data into Date Table (Dim)
INSERT INTO Date (DateID, Date, Month, Quarter, Year) VALUES
(1, '2023-01-01', 1, 1, 2023),
(2, '2023-03-15', 3, 1, 2023),
(3, '2023-05-10', 5, 2, 2023),
(4, '2023-07-25', 7, 3, 2020),
(5, '2023-09-15', 9, 3, 2021),
(6, '2023-11-30', 11, 4, 2022),
(7, '2024-01-01', 1, 1, 2024),
(8, '2024-04-10', 4, 2, 2024),
(9, '2024-06-20', 6, 2, 2025),
(10, '2024-09-05', 9, 3, 2025);

-- Sales Fact Table
CREATE TABLE Sales (
    SaleID INT PRIMARY KEY,
    CustomerID INT,
    ProductID INT,
    DateID INT,
    Quantity INT,
    TotalAmount DECIMAL(10, 2),
    FOREIGN KEY (CustomerID) REFERENCES Customer(CustomerID),
    FOREIGN KEY (ProductID) REFERENCES Product(ProductID),
    FOREIGN KEY (DateID) REFERENCES Date(DateID)
);

-- Insert Data
INSERT INTO Sales (SaleID, CustomerID, ProductID, DateID, Quantity, TotalAmount) VALUES
(1, 1, 1, 1, 2, 2400.00),
(2, 2, 2, 2, 1, 150.00),
(3, 3, 3, 3, 12, 3600.00),
(4, 4, 4, 3, 5, 2500.00),
(5, 5, 5, 5, 15, 12000.00),
(6, 2, 6, 1, 20, 8000.00),  -- Larger quantity for testing discounts
(7, 1, 1, 1, 0, 0.00);  -- Invalid entry, used for testing the error table

-- ETL Monitoring Table
CREATE TABLE ETL_Monitoring (
    LogID INT PRIMARY KEY,
    ETLProcessName VARCHAR(100),
    StartTime DATETIME,
    EndTime DATETIME,
    Status VARCHAR(20),
    ErrorMessage VARCHAR(255)
);

-- Insert Data
INSERT INTO ETL_Monitoring (LogID, ETLProcessName, StartTime, EndTime, Status, ErrorMessage) VALUES
(1, 'Customer Data Load', '2023-01-01 08:00:00', '2023-01-01 09:00:00', 'Success', NULL),
(2, 'Product Data Load', '2023-01-02 08:30:00', '2023-01-02 09:15:00', 'Failed', 'Connection Timeout');

-- Error Orders Table
CREATE TABLE Error_Orders (
    ErrorID INT PRIMARY KEY,
    SaleID INT,
    ErrorDescription VARCHAR(255),
    DateLogged DATETIME
);

-- Insert Data
INSERT INTO Error_Orders (ErrorID, SaleID, ErrorDescription, DateLogged) VALUES
(1, 7, 'Missing Price', '2023-01-01 10:00:00');


#extraction
select * from sales where dateid in (select dateid from date where year = 2023);

select distinct c.CustomerID, c.firstname, c.lastname
from customer c join sales s on c.customerid = s.customerid join product p on s.productid = p.productid
where p.category = "Electronics";

select s.saleid, s.quantity, s.totalamount, c.region
from sales s join customer c on s.customerid = c.customerid
where s.quantity > 10 and c.region = 'Asia';

select * 
from sales s join product p on s.productid = p.productid
where p.price is null or p.price < 0;

select c.customerid, c.firstname, c.lastname, sum(s.totalamount) as TotalSales
from sales s join customer c on s.customerid = c.customerid join date d on s.dateid = d.dateid
where d.year = 2024
group by c.customerid
order by totalsales desc
limit 5;

#transformation
update sales set quantity = 0 where quantity is null;

update product set productname = (select concat(upper(substring(productname,1,1)), lower(substring(productname,2))));

alter table sales add totalsales decimal(10,2);
update sales
set totalsales = quantity * (select price from product where productid = sales.productid);

alter table sales add discount decimal(10,2);
update sales 
set discount = 0.10 * (select price from product where productid = sales.productid and quantity > 10);

update sales set totalsales = round(totalsales, 2);


#load
insert into customer(customerid, firstname,lastname,region,email)
select 11,'new','customer','north america',  'new.customer@email.com'
where not exists (select 1 from customer where customerid = 11);

insert into product (productid, productname, category, price)
values (11, 'new product', 'home applicances', 100.00);

insert into sales(saleid,customerid,productid,dateid,quantity,totalamount)
select saleid,customerid,productid,dateid,quantity,totalamount
from sales;

insert into error_orders (saleid, errordescription, datelogged)
select saleid, 'Price < 0', current_timestamp()
from sales s join product p on s.productid = p.productid
where p.price < 0;

#monitor

select p.productid, p.productname, sum(s.totalamount) as total_revenue
from sales s
join product p on s.productid = p.productid
group by p.productid, p.productname
order by total_revenue desc
limit 3;

select c.customerid, c.firstname, c.lastname, sum(s.totalamount) as total_purchases
from sales s
join customer c on s.customerid = c.customerid
group by c.customerid, c.firstname, c.lastname
order by total_purchases desc
limit 5;

select d.year, d.month, sum(s.totalamount) as monthly_sales
from sales s
join date d on s.dateid = d.dateid
where d.year = 2023
group by d.year, d.month
order by d.year, d.month;

select c.region, sum(s.totalamount) as total_sales
from sales s
join customer c on s.customerid = c.customerid
group by c.region
order by total_sales desc;

select d.year, sum(s.totalamount) as total_sales
from sales s
join date d on s.dateid = d.dateid
group by d.year
order by total_sales desc
limit 1;

select p.category, c.region, sum(s.totalamount) as total_sales
from sales s
join product p on s.productid = p.productid
join customer c on s.customerid = c.customerid
group by rollup(p.category, c.region)
order by p.category, c.region;