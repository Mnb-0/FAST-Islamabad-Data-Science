create database if not exists mnb;
use mnb;

drop table if exists mobile_tech_components;
drop table if exists mobile_evolution;
drop table if exists price_cube;
drop table if exists sales_fact;
drop table if exists store_dim;
drop table if exists time_dim;
drop table if exists product_dim;

create table product_dim (
  article_id int primary key,
  article_name varchar(100) not null,
  brand varchar(50) not null,
  subcategory varchar(50) not null,
  category varchar(50) not null
);


create table mobile_tech_components
{
    id int auto_increment primary key,
    year_start date not null,
    year_end date null,
    has_gsm tinyint(1) not null default 0,
    has_3g tinyint(1) not null default 0,
    has_4g tinyint(1) not null default 0
};


insert into product_dim (article_id, article_name, brand, subcategory, category) values
(1, 'tr-34', 'sony', 'video recorder', 'electronics'),
(2, 'ts-56', 'panasonic', 'camcorder', 'electronics'),
(3, 'tv-42', 'samsung', 'television', 'electronics'),
(4, 'soundmax', 'bose', 'speakers', 'electronics'),
(5, 'galaxy a55', 'samsung', 'smartphone', 'electronics'),
(6, 'air jordan', 'nike', 'basketball shoes', 'clothes'),
(7, 'superstar', 'adidas', 'sneakers', 'clothes'),
(8, 'polo tee', 'ralph lauren', 't-shirts', 'clothes'),
(9, 'levi 501', 'levis', 'jeans', 'clothes'),
(10, 'winter jacket', 'north face', 'jackets', 'clothes');

create table time_dim (
  day_date date primary key,
  day_name varchar(10) not null,
  week_num int not null,
  month_name varchar(15) not null,
  quarter_num int not null,
  year_num int not null
);


insert into time_dim (day_date, day_name, week_num, month_name, quarter_num, year_num) values
('2023-12-01', 'friday', 48, 'december', 4, 2023),
('2023-12-02', 'saturday', 48, 'december', 4, 2023),
('2023-12-03', 'sunday', 49, 'december', 4, 2023),
('2023-12-04', 'monday', 49, 'december', 4, 2023),
('2023-12-05', 'tuesday', 49, 'december', 4, 2023),
('2023-12-06', 'wednesday', 49, 'december', 4, 2023),
('2023-12-07', 'thursday', 49, 'december', 4, 2023),
('2023-12-08', 'friday', 49, 'december', 4, 2023),
('2023-12-09', 'saturday', 49, 'december', 4, 2023),
('2023-12-10', 'sunday', 50, 'december', 4, 2023),
('2023-12-11', 'monday', 50, 'december', 4, 2023),
('2023-12-12', 'tuesday', 50, 'december', 4, 2023),
('2023-12-13', 'wednesday', 50, 'december', 4, 2023),
('2023-12-14', 'thursday', 50, 'december', 4, 2023),
('2023-12-15', 'friday', 50, 'december', 4, 2023),
('2023-12-16', 'saturday', 50, 'december', 4, 2023),
('2023-12-17', 'sunday', 51, 'december', 4, 2023),
('2023-12-18', 'monday', 51, 'december', 4, 2023),
('2023-12-19', 'tuesday', 51, 'december', 4, 2023),
('2023-12-20', 'wednesday', 51, 'december', 4, 2023),
('2023-12-21', 'thursday', 51, 'december', 4, 2023),
('2023-12-22', 'friday', 51, 'december', 4, 2023),
('2023-12-23', 'saturday', 51, 'december', 4, 2023),
('2023-12-24', 'sunday', 52, 'december', 4, 2023),
('2023-12-25', 'monday', 52, 'december', 4, 2023),
('2023-12-26', 'tuesday', 52, 'december', 4, 2023),
('2023-12-27', 'wednesday', 52, 'december', 4, 2023),
('2023-12-28', 'thursday', 52, 'december', 4, 2023),
('2023-12-29', 'friday', 52, 'december', 4, 2023),
('2023-12-30', 'saturday', 52, 'december', 4, 2023),
('2023-12-31', 'sunday', 52, 'december', 4, 2023);


insert ignore into time_dim (day_date, day_name, week_num, month_name, quarter_num, year_num)
values ('2023-11-30', 'thursday', week('2023-11-30',1), 'november', quarter('2023-11-30'), year('2023-11-30'));

create table store_dim (
  store_id int primary key,
  store_name varchar(50) not null,
  store_city varchar(50) not null
);

insert into store_dim (store_id, store_name, store_city) values
(1, 'mega mart', 'karachi'),
(2, 'city center', 'lahore'),
(3, 'tech world', 'islamabad');

create table sales_fact
{
    sales_id int auto_increment primary key,
    store_key int not null,
    article_key int not null,
    day_date date not null,
    turnover decimal(12,2) not null,
    quantity int not null,
    profit decimal(12,2) not null,
    constraint fk_sales_store foreign key (store_key) references store_dim(store_id),
    constraint fk_sales_product foreign key (article_key) references product_dim(article_id),
    constraint fk_sales_time foreign key (day_date) references time_dim(day_date)
};

-- insert at least 15 transactions (varied stores, products, and days)
insert into sales_fact (sales_id, store_key, article_key, day_date, turnover, quantity, profit) values
(1, 1, 1, '2023-12-01', 52000.00, 5, 12000.00),
(2, 1, 2, '2023-12-01', 32000.00, 3, 8200.00),
(3, 2, 3, '2023-12-02', 71000.00, 7, 20100.00),
(4, 2, 4, '2023-12-02', 26000.00, 10, 7200.00),
(5, 3, 5, '2023-12-03', 91000.00, 6, 25100.00),
(6, 1, 6, '2023-12-04', 15200.00, 2, 4050.00),
(7, 1, 7, '2023-12-04', 12500.00, 1, 3050.00),
(8, 2, 8, '2023-12-05', 8000.00, 4, 2500.00),
(9, 2, 9, '2023-12-05', 20500.00, 5, 6100.00),
(10, 3, 10, '2023-12-06', 40500.00, 3, 10050.00),
(11, 3, 1, '2023-12-07', 55500.00, 6, 13200.00),
(12, 1, 2, '2023-12-08', 35500.00, 4, 9050.00),
(13, 2, 3, '2023-12-08', 80500.00, 8, 23200.00),
(14, 2, 6, '2023-12-09', 18200.00, 2, 5050.00),
(15, 3, 7, '2023-12-10', 14200.00, 1, 3600.00),
(16, 1, 5, '2023-12-11', 93000.00, 7, 25500.00),
(17, 2, 4, '2023-12-12', 27000.00, 6, 7500.00),
(18, 3, 9, '2023-12-13', 21000.00, 4, 6200.00);

create table price_cube (
  store_key int not null,
  article_key int not null,
  day_date date not null,
  unit_price decimal(10,2) not null,
  primary key (store_key, article_key, day_date),
  constraint fk_price_store foreign key (store_key) references store_dim(store_id),
  constraint fk_price_article foreign key (article_key) references product_dim(article_id),
  constraint fk_price_time foreign key (day_date) references time_dim(day_date)
);

-- populate prices for days that sales exist and a few extras to reduce nulls
insert into price_cube (store_key, article_key, day_date, unit_price) values
(1, 1, '2023-12-01', 10000.00),
(1, 2, '2023-12-01', 12000.00),
(2, 3, '2023-12-02', 10000.00),
(3, 5, '2023-12-03', 15000.00),
(1, 6, '2023-12-04', 7500.00),
(2, 8, '2023-12-05', 2000.00),
(2, 9, '2023-12-05', 4000.00),
(3, 10, '2023-12-06', 13333.33),
(3, 1, '2023-12-07', 9250.00),
(1, 2, '2023-12-08', 8750.00),
(2, 3, '2023-12-08', 10062.50),
(2, 6, '2023-12-09', 9000.00),
(3, 7, '2023-12-10', 14000.00),
(1, 5, '2023-12-11', 13300.00),
(2, 4, '2023-12-12', 4500.00),
(3, 9, '2023-12-13', 5250.00);


select day_date,
       count(distinct month_name) as cnt_month,
       count(distinct quarter_num) as cnt_quarter,
       count(distinct year_num) as cnt_year
from time_dim
group by day_date
having cnt_month > 1 or cnt_quarter > 1 or cnt_year > 1;

select day_date, month_name, quarter_num, year_num
from time_dim
where day_date = '2023-12-05';

select sf.*, p.article_name, p.category
from sales_fact sf
join product_dim p on sf.article_key = p.article_id
where p.category = 'electronics';

select p.article_name, sum(sf.turnover) as total_turnover, sum(sf.quantity) as total_quantity
from sales_fact sf
join product_dim p on sf.article_key = p.article_id
group by p.article_name;

select t.month_name, p.category, sum(sf.turnover) as total_turnover
from sales_fact sf
join product_dim p on sf.article_key = p.article_id
join time_dim t on sf.day_date = t.day_date
group by t.month_name, p.category
order by t.year_num, t.month_name, p.category;

select sf.sales_id, p.article_name, s.store_name, t.day_date, sf.quantity, pc.unit_price,
       case when pc.unit_price is null then null else sf.quantity * pc.unit_price end as revenue
from sales_fact sf
left join price_cube pc
  on sf.store_key = pc.store_key
 and sf.article_key = pc.article_key
 and sf.day_date = pc.day_date
join product_dim p on sf.article_key = p.article_id
join store_dim s on sf.store_key = s.store_id
join time_dim t on sf.day_date = t.day_date;

-- base cuboid (3-d): product, store, time (day)
select p.article_name, s.store_name, t.day_date,
       sum(sf.turnover) as turnover, sum(sf.quantity) as quantity, sum(sf.profit) as profit
from sales_fact sf
join product_dim p on sf.article_key = p.article_id
join store_dim s on sf.store_key = s.store_id
join time_dim t on sf.day_date = t.day_date
group by p.article_name, s.store_name, t.day_date
order by p.article_name, s.store_name, t.day_date;

-- 2-d cuboids
-- (product, store)
select p.article_name, s.store_name, sum(sf.turnover) as total_turnover
from sales_fact sf
join product_dim p on sf.article_key = p.article_id
join store_dim s on sf.store_key = s.store_id
group by p.article_name, s.store_name
order by p.article_name, s.store_name;

-- (product, time) aggregated by month
select p.article_name, t.month_name, sum(sf.turnover) as total_turnover
from sales_fact sf
join product_dim p on sf.article_key = p.article_id
join time_dim t on sf.day_date = t.day_date
group by p.article_name, t.month_name
order by t.year_num, t.month_name, p.article_name;

-- (store, time) aggregated by month
select s.store_name, t.month_name, sum(sf.turnover) as total_turnover
from sales_fact sf
join store_dim s on sf.store_key = s.store_id
join time_dim t on sf.day_date = t.day_date
group by s.store_name, t.month_name
order by t.year_num, t.month_name, s.store_name;

-- 1-d cuboids
-- product only
select p.article_name, sum(sf.turnover) as total_turnover
from sales_fact sf
join product_dim p on sf.article_key = p.article_id
group by p.article_name
order by p.article_name;

-- store only
select s.store_name, sum(sf.turnover) as total_turnover
from sales_fact sf
join store_dim s on sf.store_key = s.store_id
group by s.store_name
order by s.store_name;

-- time only (month)
select t.year_num, t.month_name, sum(sf.turnover) as total_turnover
from sales_fact sf
join time_dim t on sf.day_date = t.day_date
group by t.year_num, t.month_name
order by t.year_num, t.month_name;

select 'all' as apex, sum(turnover) as total_turnover, sum(quantity) as total_quantity, sum(profit) as total_profit
from sales_fact;

select t.year_num, t.month_name, t.day_date, sum(sf.turnover) as turnover
from sales_fact sf
join time_dim t on sf.day_date = t.day_date
group by t.year_num, t.month_name, t.day_date
order by t.year_num, t.month_name, t.day_date;

select t.year_num, t.month_name, t.day_date, sum(sf.turnover) as turnover
from sales_fact sf
join time_dim t on sf.day_date = t.day_date
group by t.year_num, t.month_name, t.day_date with rollup;

create table mobile_evolution (
  id int auto_increment primary key,
  techs varchar(255) not null,
  valid_from date not null,
  valid_to date null
);

delete from mobile_evolution;

insert into mobile_evolution (techs, valid_from, valid_to) values
('gsm', '2003-01-01', '2004-12-31'),
('gsm + 3g', '2005-01-01', '2009-12-31'),
('gsm + 3g + 4g', '2010-01-01', null);


-- as was -> snapshot on 2007-01-01
select 'as_was_2007-01-01' as view_name, techs, valid_from, valid_to
from mobile_evolution
where '2007-01-01' between valid_from and coalesce(valid_to, '9999-12-31');

-- as is -> current hierarchy (uses current_date)
select 'as_is_current' as view_name, techs, valid_from, valid_to
from mobile_evolution
where current_date between valid_from and coalesce(valid_to, '9999-12-31');


delete from mobile_tech_components;
insert into mobile_tech_components (year_start, year_end, has_gsm, has_3g, has_4g) values
('2003-01-01', '2005-12-31', 1, 0, 0),
('2005-01-01', '2008-12-31', 1, 1, 0),
('2010-01-01', null,          1, 1, 1);

-- as was normalized on 2007-01-01
select 'as_was_normalized_2007-01-01' as view_name, has_gsm, has_3g, has_4g
from mobile_tech_components
where '2007-01-01' between year_start and coalesce(year_end, '9999-12-31');

-- as is normalized (current)
select 'as_is_normalized_current' as view_name, has_gsm, has_3g, has_4g
from mobile_tech_components
where current_date between year_start and coalesce(year_end, '9999-12-31');
