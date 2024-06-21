--ubah tipe data varchar ke integer
alter table orders
alter column orderid type integer
using orderid::integer;

select * from product_category

--check missing values
SELECT
    case when count(categoryid) = count(*) then 0 else count(categoryid) end as mv_categoryid,
	case when count(categoryname) = count(*) then 0 else count(categoryname) end as mv_categoryname,
    case when count(categoryabbreviation) = count(*) then 0 else count(categoryabbreviation) end as mv_categoryabbreviation,
	COUNT(*) AS TotalRows
FROM product_category
    

--join table dengan main table
select o.orderid, o.tanggal, o.customerid, o.prodnumber, o.quantity, cus.customeraddress, cus.customercity, 
cus.customerstate, cus.customerzip, pr.prodname, pr.category, pr.price, pc.categoryname, pc.CategoryAbbreviation
from orders o
	join customers cus on cus.custid=o.customerid
	join product pr on pr.prodnumber=o.prodnumber
	join product_category pc on pc.categoryid=pr.category


--table temp (membuat tabel sementara)
create temp table maintable
(
	orderid int, 
	tanggal date, 
	customerid int, 
	prodnumber varchar, 
	quantity int, 
	customeraddress varchar, 
	customercity varchar, 
	customerstate varchar, 
	customerzip int, 
	prodname varchar, 
	category int, 
	price numeric,  
	categoryname varchar, 
	CategoryAbbreviation varchar
);


insert into maintable(
select o.orderid, o.tanggal, o.customerid, o.prodnumber, o.quantity, cus.customeraddress, cus.customercity, 
cus.customerstate, cus.customerzip, pr.prodname, pr.category, pr.price, pc.categoryname, pc.CategoryAbbreviation
from orders o
	join customers cus on cus.custid=o.customerid
	join product pr on pr.prodnumber=o.prodnumber
	join product_category pc on pc.categoryid=pr.category
);

select * from maintable;

--KPI--
--total sales
select
	round(sum(price*quantity)) as TotalPenjualan
from maintable

--avg sales
select cast(avg(price*quantity) as decimal(10,2)) as Rata2Penjualan
from maintable

--avg order values
select
	cast(sum(price*quantity) / count(distinct(customerid)) as decimal (10,2)) as AverageOrderValue
from maintable

--total produk terjual
select sum(quantity) as ProdukTerjual
from maintable

--total order
select count (distinct orderid) as TotalOrder
from maintable

--avg product per order
select sum(quantity)/count(distinct(customerid)) as AverageProductPerOrder
from maintable

--menghitung jumlah customerstate
select count (distinct customerstate)
from maintable

--menghtiung jumlah customercity
select count (distinct customercity)
from maintable

--menghitung rata2 pembelian customer pada state
--awalnya mencari rerata pembelian dari per-state
select customerstate, count (distinct customercity), sum(quantity) as rerata
from maintable
group by 1
--dilanjut
with abc as(
 SELECT customerstate, sum(quantity) / count (distinct customercity) AS rata_rata_pembelian
    FROM maintable
	group by 1
)
select round(sum(rata_rata_pembelian)/count(distinct customerstate))
from abc

--menghitung rata2 pembelian customer pada city
with abc as(
 SELECT customercity, avg(quantity) AS rata_rata_pembelian
    FROM maintable
	group by 1
)
select round(sum(rata_rata_pembelian)/count(distinct customercity))
from abc


--CHART'S--
--sales per-bulan pada tahun 2020/2021
select
	to_char(tanggal,'Mon') bulan,
	extract(year from tanggal) tahun,
	round(sum(price*quantity), 0) as TotalPenjualan
from maintable
group by 1,2
order by 2

--total product sold perbulan pada tahun 2020/2021
select
	to_char(tanggal,'Mon') bulan,
	extract(year from tanggal) tahun,
	sum(quantity) as ProductSoldPerBulan
from maintable
group by 1,2
order by 2

--(%)total penjualan by categoryname
select categoryname, 
	   round(sum(price*quantity)* 100/(select sum(price*quantity) from maintable), 0)
from maintable
group by 1
order by 2 desc

--total product terjual by categoryname dalam per-tahun
select sum(quantity) quantity,
	   categoryname,
	   date_part('year', tanggal) Tahun
from maintable 
group by 2,3
order by 1 desc, 3

--top 5 product by total revenue
select prodname, sum(quantity*price) TotalRevenue
from maintable
group by 1
order by 2 desc
limit 5

--bottom 5 product by total revenue
select prodname, sum(quantity*price) TotalRevenue
from maintable
group by 1
order by 2
limit 5

--top 5 product by total quantity
--select categoryname, sum(quantity) TotalRevenue
--from maintable
--group by 1
--order by 2 desc
--limit 5

--bottom 5 product by total quantity
--select prodname, sum(quantity) TotalRevenue
--from maintable
--group by 1
--order by 2 
--limit 5

--top 5 product by Customer Order
select prodname, count(distinct(customerid)) Total_Customer_Order
from maintable
group by 1
order by 2 desc
limit 5

--bottom 5 product by Customer Order
select prodname, count(distinct(customerid)) Total_Customer_Order
from maintable
group by 1
order by 2
limit 5

--total customer order by customerstate
select customerstate, count(customerid)
from maintable
group by 1
order by 2 desc

select customerstate, count(customerid)
from maintable
group by 1
order by 2
limit 5

-------------------------------------------------------------
--mencari rata2 penjualan tiap bulannya pada tahun 2020/2021
select
	to_char(tanggal,'Mon') bulan,
	avg(price*quantity) as Rata2Penjualan
from maintable
where extract (year from tanggal)=2020
group by 1
order by 2 desc

--mencari rata2 penjualan tertinggi dalam 2 tahun terakhir
SELECT date_part('year', tanggal) Tahun,
       to_char(tanggal,'Mon') Bulan,
       avg(price*quantity) as Rata2Penjualan
FROM maintable
GROUP BY 1,2
order by 3 desc;

--compare total penjualan pada tiap tahun berdasarkan jumlah orderannya
SELECT DISTINCT date_part('year', tanggal) Tahun,
	   sum(quantity*price) Sales,
 	   count(orderid) JumlahOrderan
FROM maintable
GROUP BY 1
--ORDER BY 2 desc;

select * from maintable

--------------------tambahan-------------------
-- mencari total penjualan berdasarkan product
select prodname, 
	   round(sum(price*quantity), 0) as TotalBayar
from maintable
group by 1
order by 2 desc


--mencari penjualan tertinggi berdasarkan state
select customerstate,
	   max(price*quantity) as TotalPenjualan
from maintable
group by 1
order by totalpenjualan desc
limit 10


























