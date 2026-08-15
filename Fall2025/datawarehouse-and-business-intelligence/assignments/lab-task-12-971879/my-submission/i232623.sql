-- 1
create database if not exists dw_lab12;
use dw_lab12;

create table districts
(
    district_id int primary key,
    district_name varchar(100),
    boundary polygon not null,
    spatial index idx_boundary (boundary)
);

create table properties
(
    property_id int primary key,
    address varchar(200),
    location point not null,
    price decimal(12,2),
    spatial index idx_location (location)
);

-- 2
insert into districts (district_id, district_name, boundary) values
(1, 'Downtown', st_geomfromtext('POLYGON((0 0, 10 0, 10 10, 0 10, 0 0))')),
(2, 'Uptown', st_geomfromtext('POLYGON((0 10, 10 10, 10 20, 0 20, 0 10))')),
(3, 'Westside', st_geomfromtext('POLYGON((-10 0, 0 0, 0 10, -10 10, -10 0))')),
(4, 'NorthWest', st_geomfromtext('POLYGON((-10 10, 0 10, 0 20, -10 20, -10 10))')),
(5, 'Eastside', st_geomfromtext('POLYGON((10 0, 20 0, 20 10, 10 10, 10 0))')),
(6, 'NorthEast', st_geomfromtext('POLYGON((10 10, 20 10, 20 20, 10 20, 10 10))'));

-- 3
insert into properties (property_id, address, location, price) values
(1, '101 Main St', st_geomfromtext('POINT(5 5)'), 500000),
(2, '102 Main St', st_geomfromtext('POINT(2 2)'), 450000),
(3, '200 High St', st_geomfromtext('POINT(5 15)'), 600000),
(4, '205 High St', st_geomfromtext('POINT(8 12)'), 620000),
(5, '300 West Ave', st_geomfromtext('POINT(-5 5)'), 300000),
(6, '305 West Ave', st_geomfromtext('POINT(-2 8)'), 320000),
(7, '400 Ind Pk', st_geomfromtext('POINT(-5 15)'), 250000),
(8, '500 East Rd', st_geomfromtext('POINT(15 5)'), 400000),
(9, '600 Rich Ln', st_geomfromtext('POINT(15 15)'), 900000),
(10, 'Center Place', st_geomfromtext('POINT(1 1)'), 480000),
(11, 'Border View', st_geomfromtext('POINT(9 9)'), 510000),
(12, 'Sky Tower', st_geomfromtext('POINT(5 18)'), 750000),
(13, 'Factory A', st_geomfromtext('POINT(-8 2)'), 200000),
(14, 'Factory B', st_geomfromtext('POINT(-8 18)'), 210000),
(15, 'Suburb A', st_geomfromtext('POINT(12 2)'), 350000),
(16, 'Suburb B', st_geomfromtext('POINT(18 8)'), 380000),
(17, 'Villa X', st_geomfromtext('POINT(12 12)'), 850000),
(18, 'Villa Y', st_geomfromtext('POINT(18 18)'), 880000),
(19, 'Edge Case 1', st_geomfromtext('POINT(0.1 10.1)'), 600000),
(20, 'Boundary House', st_geomfromtext('POINT(0 10)'), 550000);

-- 4
select r1.district_name, r2.district_name
from districts r1
join districts r2 on r1.district_id < r2.district_id
where st_overlaps(r1.boundary, r2.boundary);

-- 5
select p.address, d.district_name
from properties p
join districts d on st_intersects(p.location, d.boundary)
where p.property_id = 20;

-- 1 (ub tree)
create table products_ubtree
(
    product_id int primary key,
    product_name varchar(100),
    price_bucket int,
    rating_bucket int,
    z_value int,
    actual_price decimal(10,2),
    actual_rating decimal(3,2),
    index idx_z_value (z_value)
);

delimiter $$
create function calculate_z_value(x int, y int)
returns int deterministic
begin
    declare z_val int default 0;
    declare i int default 0;
    
    while i < 4 do
    begin
        set z_val = z_val | ((y & (1 << i)) << i);
        set z_val = z_val | ((x & (1 << i)) << (i + 1));
        set i = i + 1;
    end;
    end while;
    
    return z_val;
end$$
delimiter ;


-- 2.
insert into products_ubtree (product_id, product_name, actual_price, actual_rating) values
(1, 'Cheap Junk', 50.00, 1.0), (2, 'Budget Good', 100.00, 4.0),
(3, 'Mid Average', 500.00, 2.5), (4, 'Flagship', 900.00, 4.8),
(5, 'Overpriced', 950.00, 1.5), (6, 'Bargain', 200.00, 3.5),
(7, 'Standard', 400.00, 3.0), (8, 'Pro Model', 800.00, 4.5),
(9, 'Lite Ver', 300.00, 2.8), (10, 'Ultra', 990.00, 5.0),
(11, 'Mini', 150.00, 3.2), (12, 'Max', 850.00, 4.2),
(13, 'Old Model', 120.00, 1.2), (14, 'Refurb', 250.00, 3.8),
(15, 'Import', 600.00, 3.9), (16, 'Domestic', 550.00, 3.1),
(17, 'Accessory', 20.00, 4.0), (18, 'Bundle', 450.00, 4.1),
(19, 'Gift', 0.00, 5.0), (20, 'Scam', 999.00, 0.1);

update products_ubtree
set 
    price_bucket = floor(actual_price / 62.5),
    rating_bucket = floor(actual_rating * 3),
    z_value = calculate_z_value(floor(actual_price / 62.5), floor(actual_rating * 3));
    
    
-- 1 Bitmap
create table customers_bitmap
(
    customer_id int primary key,
    age_group enum('18-25', '26-35', '36-45', '46-60', '60+'),
    income_level enum('Low', 'Medium', 'High'),
    region enum('Urban', 'Suburban', 'Rural'),
    loyalty_status enum('New', 'Regular', 'VIP')
);

create table bitmap_indices
(
    attribute_name varchar(50),
    attribute_value varchar(50),
    bit_vector text,
    primary key (attribute_name, attribute_value)
);

-- 2
insert into customers_bitmap (customer_id, age_group, income_level, region, loyalty_status) 
values 
(1, '18-25', 'Low', 'Urban', 'New'),
(2, '26-35', 'High', 'Urban', 'VIP'),
(3, '60+', 'Medium', 'Rural', 'Regular'),
(4, '36-45', 'High', 'Suburban', 'VIP'),
(5, '18-25', 'Low', 'Rural', 'New');

-- 3
delimiter $$
create procedure generate_bitmap_index()
begin
    truncate table bitmap_indices;
    
    insert into bitmap_indices (attribute_name, attribute_value, bit_vector)
    select 'region', 'Urban', 
           group_concat(if(region='Urban', '1', '0') order by customer_id separator '') 
    from customers_bitmap;
    
    insert into bitmap_indices (attribute_name, attribute_value, bit_vector)
    select 'region', 'Rural', 
           group_concat(if(region='Rural', '1', '0') order by customer_id separator '') 
    from customers_bitmap;

    insert into bitmap_indices (attribute_name, attribute_value, bit_vector)
    select 'income_level', 'High', 
           group_concat(if(income_level='High', '1', '0') order by customer_id separator '') 
    from customers_bitmap;
    
    insert into bitmap_indices (attribute_name, attribute_value, bit_vector)
    select 'age_group', '18-25', 
           group_concat(if(age_group='18-25', '1', '0') order by customer_id separator '') 
    from customers_bitmap;
    
    insert into bitmap_indices (attribute_name, attribute_value, bit_vector)
    select 'age_group', '60+', 
           group_concat(if(age_group='60+', '1', '0') order by customer_id separator '') 
    from customers_bitmap;
end$$
delimiter ;

call generate_bitmap_index();

-- 4
select * from customers_bitmap 
where loyalty_status = 'VIP' and region = 'Urban' and income_level = 'High';

select attribute_value, bit_vector 
from bitmap_indices 
where attribute_name = 'age_group' and attribute_value in ('18-25', '60+');

select * from customers_bitmap 
where income_level = 'Medium' and region != 'Rural';