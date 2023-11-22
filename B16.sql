--ex1
select 
    ROUND(100*sum(case when min_date = customer_pref_delivery_date then 1 else 0 end ) / 
    count(distinct customer_id), 2) as immediate_percentage
from (
    select  
        customer_id, 
        MIN(order_date)OVER(partition by customer_id order by order_date asc) as min_date,
        order_date,
        customer_pref_delivery_date
    from Delivery
) c
--ex2
select 
round(count(a1.player_id)/count(distinct a2.player_id),2) as fraction
from activity a1 right join activity a2
on a1.player_id = a2.player_id and datediff(a1.event_date, a2.event_date) = 1
where (a2.player_id,a2.event_date) in (
    select player_id, min(event_date)
    from activity
    group by player_id
)
--ex3
SELECT CASE
           WHEN s.id % 2 <> 0 AND s.id = (SELECT COUNT(*) FROM Seat) THEN s.id
           WHEN s.id % 2 = 0 THEN s.id - 1
           ELSE
               s.id + 1
           END AS id,
       student
FROM Seat AS s
ORDER BY id
--ex4
SELECT a.visited_on AS visited_on, SUM(b.day_sum) AS amount,
       ROUND(AVG(b.day_sum), 2) AS average_amount
FROM
  (SELECT visited_on, SUM(amount) AS day_sum FROM Customer GROUP BY visited_on ) a,
  (SELECT visited_on, SUM(amount) AS day_sum FROM Customer GROUP BY visited_on ) b
WHERE DATEDIFF(a.visited_on, b.visited_on) BETWEEN 0 AND 6
GROUP BY a.visited_on
HAVING COUNT(b.visited_on) = 7
--ex5
SELECT ROUND(SUM(tiv_2016), 2) AS tiv_2016
FROM insurance
WHERE tiv_2015 IN 
    (SELECT tiv_2015 FROM insurance GROUP BY tiv_2015 HAVING COUNT(*) > 1)
AND (lat, lon) IN 
    (  SELECT lat, lon FROM insurance GROUP BY lat, lon HAVING COUNT(*) = 1)
--ex6'
select d.name as department , e1.name as employee, e1.salary as Salary
from Employee e1 join Department d on e1.DepartmentId = d.Id
where  3 > (select count(distinct (e2.Salary))
        from  Employee e2
        where e2.Salary > e1.Salary
            and e1.DepartmentId = e2.DepartmentId)
--ex7
SELECT person_name 
FROM queue AS q
WHERE (
    SELECT SUM(weight) 
    FROM queue 
    WHERE q.turn >= turn
) <= 1000 
ORDER BY turn DESC 
LIMIT 1;
--ex8
WITH tb1 AS
(SELECT *, 
RANK() OVER (PARTITION BY product_id ORDER BY change_date DESC) AS r 
FROM Products
WHERE change_date<= '2019-08-16')

SELECT product_id, new_price AS price
FROM tb1
WHERE r = 1
UNION
SELECT product_id, 10 AS price
FROM Products
WHERE product_id NOT IN (SELECT product_id FROM tb1)
