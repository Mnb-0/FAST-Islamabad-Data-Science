select s.* from Sales s,  Product p, Region r, Time t 
where (s.productid = p.productid and (p.category = "electronics" or p.category = "clothing")) 
and ((s.regionid = r.regionid) and (r.country = "usa" or r.country = "uk")) 
and ((s.dateid = t.dateid) and (t.year = 2023));


select r.country,r.state,r.city,sum(s.salesamount) as total_sales_amount,sum(s.quantity) as total_quantity
from sales s
join region r on s.regionid = r.regionid
group by r.country, r.state, r.city
order by r.country, r.state, r.city;

select
    p.productname as product,
    sum(s.salesamount) as total_product_sales
from sales s
join product p on s.productid = p.productid
group by p.productname
order by p.productname;

select
    r.city,
    sum(s.salesamount) as total_city_sales
from sales s
join region r on s.regionid = r.regionid
group by r.city
order by r.city;

select
    p.productname as product,
    r.city,
    sum(s.salesamount) as product_city_sales
from sales s
join product p on s.productid = p.productid
join region r on s.regionid = r.regionid
group by p.productname, r.city
order by p.productname, r.city;

