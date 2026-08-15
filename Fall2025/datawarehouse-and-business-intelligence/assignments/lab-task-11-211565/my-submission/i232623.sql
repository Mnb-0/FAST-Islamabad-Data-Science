drop database if exists lab11;
create database lab11;
use lab11;

-- task 1
-- task 1.1
create table warehouses_t1 (
    warehouse_id int primary key,
    warehouse_name varchar(100),
    location point not null,
    spatial index idx_location (location)
) engine=innodb;
create table customers_t1 (
    customer_id int primary key,
    customer_name varchar(100),
    location point not null,
    spatial index idx_location (location)
) engine=innodb;

-- task 1.1
insert into warehouses_t1 (warehouse_id, warehouse_name, location)
values
(1, 'WH-Los Angeles',   st_geomfromtext('POINT(34.0522 -118.2437)', 4326)),
(2, 'WH-San Francisco', st_geomfromtext('POINT(37.7749 -122.4194)', 4326)),
(3, 'WH-San Diego',     st_geomfromtext('POINT(32.7157 -117.1611)', 4326)),
(4, 'WH-Sacramento',    st_geomfromtext('POINT(38.5816 -121.4944)', 4326)),
(5, 'WH-Fresno',        st_geomfromtext('POINT(36.7378 -119.7871)', 4326));
insert into customers_t1 (customer_id, customer_name, location) values
(101, 'cust-anaheim',       st_geomfromtext('point(33.8366 -117.9143)', 4326)),
(102, 'cust-santa monica',  st_geomfromtext('point(34.0195 -118.4912)', 4326)),
(103, 'cust-long beach',    st_geomfromtext('point(33.7701 -118.1937)', 4326)),
(104, 'cust-pasadena',      st_geomfromtext('point(34.1478 -118.1445)', 4326)),
(105, 'cust-irvine',        st_geomfromtext('point(33.6846 -117.8265)', 4326)),
(106, 'cust-oakland',       st_geomfromtext('point(37.8044 -122.2712)', 4326)),
(107, 'cust-san jose',      st_geomfromtext('point(37.3382 -121.8863)', 4326)),
(108, 'cust-berkeley',      st_geomfromtext('point(37.8715 -122.2730)', 4326)),
(109, 'cust-palo alto',     st_geomfromtext('point(37.4419 -122.1430)', 4326)),
(110, 'cust-chula vista',   st_geomfromtext('point(32.6401 -117.0842)', 4326)),
(111, 'cust-la jolla',      st_geomfromtext('point(32.8427 -117.2733)', 4326)),
(112, 'cust-escondido',     st_geomfromtext('point(33.1192 -117.0864)', 4326)),
(113, 'cust-davis',         st_geomfromtext('point(38.5449 -121.7405)', 4326)),
(114, 'cust-roseville',     st_geomfromtext('point(38.7521 -121.2880)', 4326)),
(115, 'cust-bakersfield',   st_geomfromtext('point(35.3733 -119.0187)', 4326)),
(116, 'cust-modesto',       st_geomfromtext('point(37.6391 -120.9969)', 4326)),
(117, 'cust-stockton',      st_geomfromtext('point(37.9577 -121.2908)', 4326)),
(118, 'cust-redding',       st_geomfromtext('point(40.5865 -122.3917)', 4326)),
(119, 'cust-santa barbara', st_geomfromtext('point(34.4208 -119.6982)', 4326)),
(120, 'cust-palm springs',  st_geomfromtext('point(33.8303 -116.5453)', 4326));

-- task 1.2
select
    w.warehouse_name,
    c.customer_name,
    st_distance_sphere(w.location, c.location) / 1000 as distance_km
from
    warehouses_t1 w
join
    customers_t1 c
on st_distance_sphere(w.location, c.location) <= 100000
order by w.warehouse_name, distance_km;

-- task 1.3
with rankedwarehouses as (
    select
        c.customer_id,
        c.customer_name,
        w.warehouse_id,
        w.warehouse_name,
        st_distance_sphere(c.location, w.location) as distance_meters,
        row_number() over (
            partition by c.customer_id
            order by st_distance_sphere(c.location, w.location)
        ) as distance_rank
    from customers_t1 c
    cross join warehouses_t1 w
)
select
    customer_name,
    warehouse_name,
    distance_meters / 1000 as distance_km
from rankedwarehouses
where distance_rank = 1
order by customer_name;

-- task 1.4
with coveredcustomers as (
    select
        w.warehouse_id,
        w.warehouse_name,
        c.location as customer_location
    from warehouses_t1 w
    join customers_t1 c
    on st_distance_sphere(w.location, c.location) <= 100000
),
mbr_coords as (
    select
        warehouse_id,
        warehouse_name,
        min(st_x(customer_location)) as min_x,
        max(st_x(customer_location)) as max_x,
        min(st_y(customer_location)) as min_y,
        max(st_y(customer_location)) as max_y
    from coveredcustomers
    group by warehouse_id, warehouse_name
)
select
    warehouse_name,
    st_astext(
        st_geomfromtext(
            concat(
                'polygon((',
                min_x, ' ', min_y, ',',
                max_x, ' ', min_y, ',',
                max_x, ' ', max_y, ',',
                min_x, ' ', max_y, ',',
                min_x, ' ', min_y, '))'
            )
        )
    ) as mbr_polygon
from mbr_coords;

-- task 1.5
with coveredcustomers as (
    select
        w.warehouse_id,
        w.warehouse_name,
        c.location as customer_location
    from warehouses_t1 w
    join customers_t1 c
    on st_distance_sphere(w.location, c.location) <= 100000
),
mbr_coords as (
    select
        warehouse_id,
        warehouse_name,
        min(st_x(customer_location)) as min_x,
        max(st_x(customer_location)) as max_x,
        min(st_y(customer_location)) as min_y,
        max(st_y(customer_location)) as max_y
    from coveredcustomers
    group by warehouse_id, warehouse_name
),
warehouse_mbrs as (
    select
        warehouse_id,
        warehouse_name,
        st_geomfromtext(
            concat(
                'polygon((',
                min_x, ' ', min_y, ',',
                max_x, ' ', min_y, ',',
                max_x, ' ', max_y, ',',
                min_x, ' ', max_y, ',',
                min_x, ' ', min_y, '))'
            )
        ) as mbr
    from mbr_coords
    where min_x is not null
)
select
    a.warehouse_name as warehouse_a,
    b.warehouse_name as warehouse_b
from warehouse_mbrs a
join warehouse_mbrs b
on a.warehouse_id < b.warehouse_id
where st_overlaps(a.mbr, b.mbr);

-- task 1.6
set @test_point = st_geomfromtext('point( 34.0195 -118.4912)', 4326);
select customer_name, st_distance_sphere(@test_point, location) as dist
from customers_t1
where st_distance_sphere(@test_point, location) <= 50000;
explain
select customer_name, st_distance_sphere(@test_point, location) as dist
from customers_t1
where st_distance_sphere(@test_point, location) <= 50000;
alter table customers_t1 drop index idx_location;
explain
select customer_name, st_distance_sphere(@test_point, location) as dist
from customers_t1
where st_distance_sphere(@test_point, location) <= 50000;
alter table customers_t1 add spatial index idx_location (location);

-- task 2
create table products_t2 (
    product_id int primary key,
    product_name varchar(100),
    category varchar(50),
    price decimal(10,2),
    rating decimal(3,2),
    product_position point not null,
    spatial index idx_position (product_position)
) engine=innodb;
insert into products_t2 (product_id, product_name, category, price, rating, product_position) values
(1, 'laptop', 'electronics', 1200.00, 4.5, st_geomfromtext('point(1200 4.5)', 0)),
(2, 'smartphone', 'electronics', 800.00, 4.7, st_geomfromtext('point(800 4.7)', 0)),
(3, 'headphones', 'electronics', 150.00, 4.2, st_geomfromtext('point(150 4.2)', 0)),
(4, '4k tv', 'electronics', 1500.00, 4.8, st_geomfromtext('point(1500 4.8)', 0)),
(5, 'smartwatch', 'electronics', 300.00, 4.0, st_geomfromtext('point(300 4.0)', 0)),
(6, 'gaming console', 'electronics', 500.00, 4.6, st_geomfromtext('point(500 4.6)', 0)),
(7, 'dslr camera', 'electronics', 1800.00, 4.9, st_geomfromtext('point(1800 4.9)', 0)),
(8, 'blender', 'home', 80.00, 4.1, st_geomfromtext('point(80 4.1)', 0)),
(9, 'coffee maker', 'home', 60.00, 4.3, st_geomfromtext('point(60 4.3)', 0)),
(10, 'vacuum cleaner', 'home', 250.00, 4.4, st_geomfromtext('point(250 4.4)', 0)),
(11, 'air fryer', 'home', 120.00, 4.7, st_geomfromtext('point(120 4.7)', 0)),
(12, 'sofa', 'home', 700.00, 3.8, st_geomfromtext('point(700 3.8)', 0)),
(13, 'bed frame', 'home', 450.00, 3.5, st_geomfromtext('point(450 3.5)', 0)),
(14, 'dining table', 'home', 600.00, 4.0, st_geomfromtext('point(600 4.0)', 0)),
(15, 't-shirt', 'clothing', 20.00, 3.9, st_geomfromtext('point(20 3.9)', 0)),
(16, 'jeans', 'clothing', 50.00, 4.1, st_geomfromtext('point(50 4.1)', 0)),
(17, 'sneakers', 'clothing', 90.00, 4.5, st_geomfromtext('point(90 4.5)', 0)),
(18, 'jacket', 'clothing', 120.00, 4.3, st_geomfromtext('point(120 4.3)', 0)),
(19, 'winter coat', 'clothing', 200.00, 4.6, st_geomfromtext('point(200 4.6)', 0)),
(20, 'dress shirt', 'clothing', 45.00, 4.0, st_geomfromtext('point(45 4.0)', 0)),
(21, 'running shoes', 'clothing', 110.00, 4.8, st_geomfromtext('point(110 4.8)', 0)),
(22, 'budget tv', 'electronics', 250.00, 3.0, st_geomfromtext('point(250 3.0)', 0)),
(23, 'cheap t-shirt', 'clothing', 10.00, 2.5, st_geomfromtext('point(10 2.5)', 0)),
(24, 'basic mug', 'home', 15.00, 4.5, st_geomfromtext('point(15 4.5)', 0)),
(25, 'premium laptop', 'electronics', 1900.00, 4.8, st_geomfromtext('point(1900 4.8)', 0)),
(26, 'designer jeans', 'clothing', 300.00, 3.7, st_geomfromtext('point(300 3.7)', 0)),
(27, 'robotic vacuum', 'home', 800.00, 4.6, st_geomfromtext('point(800 4.6)', 0)),
(28, 'budget smartphone', 'electronics', 95.00, 4.2, st_geomfromtext('point(95 4.2)', 0)),
(29, 'basic sneakers', 'clothing', 40.00, 4.3, st_geomfromtext('point(40 4.3)', 0)),
(30, 'premium headphones', 'electronics', 550.00, 4.7, st_geomfromtext('point(550 4.7)', 0));

-- task 2.2
select * from products_t2
where price > 500 and rating > 4.0;
set @premium_box = st_geomfromtext(
    'polygon((500 4, 2001 4, 2001 5, 500 5, 500 4))',
    0
);
select * from products_t2
where mbrcontains(@premium_box, product_position);

-- task 2.3
select * from products_t2
where price < 100 and rating > 4.0;
set @budget_box = st_geomfromtext(
    'polygon((0 4, 100 4, 100 5, 0 5, 0 4))',
    0
);
select * from products_t2
where mbrcontains(@budget_box, product_position);

-- task 2.4
with mbr_coords as (
    select
        category,
        min(st_x(product_position)) as min_price,
        max(st_x(product_position)) as max_price,
        min(st_y(product_position)) as min_rating,
        max(st_y(product_position)) as max_rating
    from products_t2
    group by category
)
select
    category,
    st_astext(
        st_geomfromtext(
            concat(
                'polygon((',
                min_price, ' ', min_rating, ',',
                max_price, ' ', min_rating, ',',
                max_price, ' ', max_rating, ',',
                min_price, ' ', max_rating, ',',
                min_price, ' ', min_rating, '))'
            )
        )
    ) as mbr_price_rating_space
from mbr_coords;

-- task 2.5
with mbr_coords as (
    select
        category,
        min(st_x(product_position)) as min_price,
        max(st_x(product_position)) as max_price,
        min(st_y(product_position)) as min_rating,
        max(st_y(product_position)) as max_rating
    from products_t2
    group by category
),
category_mbrs as (
    select
        category,
        st_geomfromtext(
            concat(
                'polygon((',
                min_price, ' ', min_rating, ',',
                max_price, ' ', min_rating, ',',
                max_price, ' ', max_rating, ',',
                min_price, ' ', max_rating, ',',
                min_price, ' ', min_rating, '))'
            )
        ) as mbr
    from mbr_coords
)
select
    a.category as category_a,
    b.category as category_b
from category_mbrs a
join category_mbrs b
on a.category < b.category
where st_overlaps(a.mbr, b.mbr);

-- task 3
create table hospitals_t3 (
    hospital_id int primary key,
    hospital_name varchar(100),
    location point not null,
    service_radius_km int,
    spatial index idx_location (location)
) engine=innodb;
create table emergency_calls_t3 (
    call_id int primary key auto_increment,
    patient_location point not null,
    severity varchar(20),
    spatial index idx_location (patient_location)
) engine=innodb;
insert into hospitals_t3 (hospital_id, hospital_name, location, service_radius_km) values
(1, 'harborview medical',   st_geomfromtext('point(47.6045 -122.3275)', 4326), 10),
(2, 'uw medical center',    st_geomfromtext('point(47.6506 -122.3080)', 4326), 12),
(3, 'swedish first hill',   st_geomfromtext('point(47.6083 -122.3238)', 4326), 8),
(4, 'virginia mason',       st_geomfromtext('point(47.6095 -122.3270)', 4326), 7),
(5, 'northwest hospital',   st_geomfromtext('point(47.7018 -122.3330)', 4326), 15),
(6, 'swedish ballard',      st_geomfromtext('point(47.6680 -122.3831)', 4326), 9);
insert into emergency_calls_t3 (patient_location, severity) values
(st_geomfromtext('point(47.6080 -122.3300)', 4326), 'high'),
(st_geomfromtext('point(47.6550 -122.3100)', 4326), 'medium'),
(st_geomfromtext('point(47.6700 -122.3850)', 4326), 'low'),
(st_geomfromtext('point(47.7050 -122.3400)', 4326), 'high'),
(st_geomfromtext('point(47.5900 -122.2900)', 4326), 'medium'),
(st_geomfromtext('point(47.6600 -122.3600)', 4326), 'low'),
(st_geomfromtext('point(47.7100 -122.3000)', 4326), 'high'),
(st_geomfromtext('point(47.6400 -122.3000)', 4326), 'medium'),
(st_geomfromtext('point(47.6150 -122.3450)', 4326), 'high'),
(st_geomfromtext('point(47.6020 -122.3350)', 4326), 'low'),
(st_geomfromtext('point(47.6450 -122.3200)', 4326), 'medium'),
(st_geomfromtext('point(47.6750 -122.3500)', 4326), 'high'),
(st_geomfromtext('point(47.6850 -122.3600)', 4326), 'medium'),
(st_geomfromtext('point(47.6950 -122.3500)', 4326), 'low'),
(st_geomfromtext('point(47.7050 -122.3300)', 4326), 'medium'),
(st_geomfromtext('point(47.6150 -122.3000)', 4326), 'low'),
(st_geomfromtext('point(47.6250 -122.2900)', 4326), 'medium'),
(st_geomfromtext('point(47.6350 -122.3400)', 4326), 'high'),
(st_geomfromtext('point(47.6200 -122.3300)', 4326), 'medium'),
(st_geomfromtext('point(47.6680 -122.3800)', 4326), 'high'),
(st_geomfromtext('point(47.7000 -122.3600)', 4326), 'medium'),
(st_geomfromtext('point(47.7200 -122.3400)', 4326), 'low'),
(st_geomfromtext('point(47.7300 -122.3500)', 4326), 'medium'),
(st_geomfromtext('point(47.5900 -122.3300)', 4326), 'high'),
(st_geomfromtext('point(47.6050 -122.3600)', 4326), 'low'),
(st_geomfromtext('point(47.6500 -122.3000)', 4326), 'medium'),
(st_geomfromtext('point(47.6600 -122.2950)', 4326), 'high'),
(st_geomfromtext('point(47.6750 -122.3050)', 4326), 'low'),
(st_geomfromtext('point(47.6870 -122.3220)', 4326), 'medium'),
(st_geomfromtext('point(47.6990 -122.3110)', 4326), 'high'),
(st_geomfromtext('point(47.6400 -122.3550)', 4326), 'low'),
(st_geomfromtext('point(47.6500 -122.3650)', 4326), 'medium'),
(st_geomfromtext('point(47.6600 -122.3750)', 4326), 'high'),
(st_geomfromtext('point(47.6700 -122.3450)', 4326), 'medium'),
(st_geomfromtext('point(47.6800 -122.3200)', 4326), 'low'),
(st_geomfromtext('point(47.6900 -122.3000)', 4326), 'high'),
(st_geomfromtext('point(47.7000 -122.2800)', 4326), 'medium'),
(st_geomfromtext('point(47.6300 -122.3500)', 4326), 'low'),
(st_geomfromtext('point(47.6200 -122.3600)', 4326), 'medium'),
(st_geomfromtext('point(47.6150 -122.3800)', 4326), 'high'),
(st_geomfromtext('point(47.6050 -122.3950)', 4326), 'medium'),
(st_geomfromtext('point(47.6950 -122.3700)', 4326), 'high'),
(st_geomfromtext('point(47.7050 -122.3650)', 4326), 'low'),
(st_geomfromtext('point(47.7150 -122.3500)', 4326), 'medium'),
(st_geomfromtext('point(47.7250 -122.3300)', 4326), 'low'),
(st_geomfromtext('point(47.7350 -122.3200)', 4326), 'high'),
(st_geomfromtext('point(47.7450 -122.3100)', 4326), 'medium'),
(st_geomfromtext('point(47.7550 -122.3000)', 4326), 'high');

-- task 3.1
select 
    c.call_id,
    h.hospital_id,
    h.hospital_name,
    st_distance_sphere(c.patient_location, h.location) / 1000 as distance_km
from emergency_calls_t3 c
join hospitals_t3 h
order by c.call_id, distance_km;

-- task 3.2
select t.call_id, t.hospital_id, t.hospital_name, t.distance_km
from (
    select 
        c.call_id,
        h.hospital_id,
        h.hospital_name,
        st_distance_sphere(c.patient_location, h.location) / 1000 as distance_km,
        row_number() over (partition by c.call_id order by st_distance_sphere(c.patient_location, h.location)) as rn
    from emergency_calls_t3 c
    join hospitals_t3 h
) t
where t.rn = 1;

-- task 3.3
select 
    h.hospital_id,
    h.hospital_name,
    c.call_id
from hospitals_t3 h
join emergency_calls_t3 c
    on st_distance_sphere(h.location, c.patient_location) <= (h.service_radius_km * 1000);
    
-- task 3.4
select c.call_id
from emergency_calls_t3 c
left join hospitals_t3 h
    on st_distance_sphere(c.patient_location, h.location) <= (h.service_radius_km * 1000)
where h.hospital_id is null;

-- task 3.5
delete from hospitals_t3 where hospital_id in (5, 6);

-- task 3.6
select old.call_id
from (
    select 
        c.call_id,
        h.hospital_id
    from emergency_calls_t3 c
    join hospitals_t3 h
        on st_distance_sphere(c.patient_location, h.location) <= (h.service_radius_km * 1000)
) old
left join (
    select 
        c.call_id,
        h.hospital_id
    from emergency_calls_t3 c
    join hospitals_t3 h
        on st_distance_sphere(c.patient_location, h.location) <= (h.service_radius_km * 1000)
) now_covered
on old.call_id = now_covered.call_id
where old.hospital_id in (5, 6)
  and now_covered.hospital_id is null;
  
  -- Deleting hospitals messes with the spatial index, so the R-Tree has to tidy itself up. When a node drops below its minimum occupancy,
  -- the CondenseTree step kicks in: it walks upward from the deleted spot, tosses out underfilled nodes, reinserts whatever’s still valid, 
  -- and updates all the bounding boxes on the way. Basically, the index notices you ripped out a couple hospitals, mutters to itself, 
  -- and quietly restructures the tree so distance queries keep working instead of collapsing in on themselves.
  
  
-- TASK 5
  
  drop table if exists locations_t4;

create table locations_t4 (
    id int primary key auto_increment,
    loc point not null srid 0
);

-- ---------------------------------------------------------
-- Stored Procedure: Insert Random Points
-- ---------------------------------------------------------
delimiter $$
create procedure insert_random_points(in n int)
begin
    declare i int default 0;
    while i < n do
        insert into locations_t4 (loc)
        values (st_geomfromtext(concat('point(', rand()*10000, ' ', rand()*10000, ')'), 0));
        set i = i + 1;
    end while;
end$$
delimiter ;

-- Insert 5000 random points
call insert_random_points(500);

-- ---------------------------------------------------------
-- Add Spatial Index
-- ---------------------------------------------------------
create spatial index idx_loc on locations_t4 (loc);

-- ---------------------------------------------------------
-- Queries with index
-- ---------------------------------------------------------
set profiling = 1;

-- Query 1: Small range scan (1% of area)
set @small_box = st_geomfromtext('polygon((0 0, 1000 0, 1000 1000, 0 1000, 0 0))', 0);
select count(*) from locations_t4 where mbrcontains(@small_box, loc);

-- Query 2: Large range scan (25% of area)
set @large_box = st_geomfromtext('polygon((0 0, 5000 0, 5000 5000, 0 5000, 0 0))', 0);
select count(*) from locations_t4 where mbrcontains(@large_box, loc);

-- Query 3: Nearest neighbor (k-NN)
set @test_point = st_geomfromtext('point(5000 5000)', 0);
select id from locations_t4 order by st_distance(loc, @test_point) limit 10;

-- Query 4: Point lookup (check for existence)
set @exact_point = st_geomfromtext('point(123.45 678.90)', 0);
select * from locations_t4 where st_equals(loc, @exact_point);

-- Show query profiling results
show profiles;

-- ---------------------------------------------------------
-- Drop index to run queries without index
-- ---------------------------------------------------------
drop index idx_loc on locations_t4;

set profiling = 1;

-- Repeat queries without index
select count(*) from locations_t4 where mbrcontains(@small_box, loc);
select count(*) from locations_t4 where mbrcontains(@large_box, loc);
select id from locations_t4 order by st_distance(loc, @test_point) limit 10;
select * from locations_t4 where st_equals(loc, @exact_point);

show profiles;

-- ---------------------------------------------------------
-- Scenario 2: Clustered points
-- ---------------------------------------------------------
truncate table locations_t4;

delimiter $$
create procedure insert_clustered_points(in n int)
begin
    declare i int default 0;
    declare cluster_id int;
    declare offset_x float;
    declare offset_y float;
    while i < n do
        set cluster_id = floor(rand()*5);
        set offset_x = (cluster_id % 3)*3000;
        set offset_y = floor(cluster_id / 3)*3000;
        insert into locations_t4 (loc)
        values (st_geomfromtext(concat('point(', offset_x + (rand()*1000), ' ', offset_y + (rand()*1000), ')'), 0));
        set i = i + 1;
    end while;
end$$
delimiter ;

-- Insert 5000 clustered points
call insert_clustered_points(500);

-- Add spatial index again
create spatial index idx_loc on locations_t4 (loc);

-- Re-run queries with clusters to compare performance
set profiling = 1;
select count(*) from locations_t4 where mbrcontains(@small_box, loc);
select count(*) from locations_t4 where mbrcontains(@large_box, loc);
select id from locations_t4 order by st_distance(loc, @test_point) limit 10;
select * from locations_t4 where st_equals(loc, @exact_point);

show profiles;

-- Recommendation
-- R-tree indexes are efficient for multi-dimensional spatial queries
-- like range queries and nearest neighbor searches in DW.
-- B-tree indexes are better for single-dimensional lookups, sorting, and equality searches.
