-------MID-COURSE TEST-------
--ex1
select distinct replacement_cost 
from film
order by replacement_cost 
--ex2
select 
case
	when replacement_cost between 9.99 and 19.99 then 'low'
	when replacement_cost between 20.00 and 24.99 then 'medium'
	when replacement_cost between 25.00 and 29.99 then 'high'
end as category,
count(*) as so_luong
from film
group by category
--ex3
select a.title, a.length, c.name from film as a
Join public.film_category as b on a.film_id=b.film_id
join public.category as c on c.category_id = b.category_id
where c.name = 'Drama' or c.name = 'Sports'
order by a.length desc
--ex4
select count (a.title), c.name from film as a
Join public.film_category as b on a.film_id=b.film_id
join public.category as c on c.category_id = b.category_id
group by c.name
order by count (a.title) desc
--ex5
select a.first_name, a.last_name,
concat(a.first_name, ' ' ,a.last_name) as full_name,
count (b.film_id) as so_luong_phim
from actor as a
Join public.film_actor as b on a.actor_id = b.actor_id
group by a.first_name,a.last_name
order by count (b.film_id) desc
--ex6
select count(a.address_id)
from public.address as a
LEFT JOIN customer as b on a.address_id = b.address_id
where b.address_id is NULL
--ex7
select a.city, 
sum(d.amount) as doanh_thu
from city as a
join public.address as b on a.city_id = b.city_id
join public.customer as c on b.address_id=c.address_id
join public.payment as d on c.customer_id=d.customer_id
group by a.city
order by sum(d.amount) desc
--ex8
select 
concat(b.city, ',' ,a.country) as information, 
sum(e.amount) as doanh_thu
from public.country as a
join public.city as b on a.country_id = b.country_id
join public.address as c on b.city_id = c.city_id
join public.customer as d on c.address_id=d.address_id
join public.payment as e on d.customer_id=e.customer_id
group by a.country,b.city
order by sum(e.amount) desc
------BÀI TẬP TRÊN WEB--------
--ex1
SELECT country.continent, FLOOR(AVG(city.population))
FROM city
LEFT JOIN country ON country.code = city.countrycode
WHERE country.continent IS NOT NULL
GROUP BY country.continent
--ex2
SELECT 
ROUND(SUM(CASE 
WHEN t.signup_action = 'Confirmed' THEN 1 ELSE 0 
END)*1.0 / COUNT(t.signup_action),2)
FROM emails as e LEFT JOIN texts as t
ON e.email_id  = t.email_id
WHERE 
  e.email_id IS NOT NULL
--ex3
SELECT age_bucket,
ROUND(
SUM(case when activity_type = 'send' then time_spent else 0 end)*100.0/
(SUM(case when activity_type = 'open' then time_spent else 0 end) + 
SUM(case when activity_type = 'send' then time_spent else 0 end)),2)
as send_perc,
ROUND(
SUM(case when activity_type = 'open' then time_spent else 0 end)*100.0/
(SUM(case when activity_type = 'open' then time_spent else 0 end) + 
SUM(case when activity_type = 'send' then time_spent else 0 end)),2)
as open_perc
from activities
join age_breakdown
on age_breakdown.user_id = activities.user_id
GROUP BY age_bucket
--ex4
SELECT 
  customers.customer_id
FROM 
  customer_contracts AS customers
LEFT JOIN products ON customers.product_id = products.product_id
GROUP BY customers.customer_id
HAVING COUNT(DISTINCT products.product_category) = 3
--ex5
SELECT
    a.employee_id,
    a.name,
    COUNT(b.employee_id) AS reports_count,
    ROUND(AVG(b.age)) AS average_age
FROM Employees as a
INNER JOIN Employees as b ON a.employee_id = b.reports_to
GROUP BY a.employee_id
ORDER BY a.employee_id
--ex6
select a.product_name, sum(b.unit) as unit from Products as a
Join Orders as b on a.product_id = b.product_id   
where b.order_date between '2020-02-01' and '2020-02-28' 
group by a.product_name
having sum(b.unit)>=100
--ex7
SELECT a.page_id FROM pages as a
LEFT JOIN page_likes AS b ON a.page_id = b.page_id
WHERE b.page_id IS NULL


