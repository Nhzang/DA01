--ex1
select distinct CITY  from STATION
where ID%2=0
--ex2
select count(CITY) - count(distinct CITY) from STATION
--ex3
--ex4
SELECT 
round(cast(sum (item_count * order_occurrences)/sum(order_occurrences) as decimal),1) as mean 
FROM items_per_order;
--ex5
SELECT candidate_id
FROM candidates
where skill in ('Python','Tableau','PostgreSQL')
GROUP BY candidate_id
HAVING COUNT(skill) = 3
ORDER BY candidate_id 
--ex6
SELECT user_id,
Date(MAX(post_date)) - date(MIN(post_date)) as day_between
FROM posts 
where post_date>='2021-01-01'and post_date<'2022-01-01'
GROUP BY user_id
HAVING COUNT(post_id)>=2
--ex7
SELECT card_name,
MAX(issued_amount) - MIN(issued_amount) as difference
FROM monthly_cards_issued
GROUP BY card_name
ORDER BY difference DESC
--ex8
SELECT  manufacturer,
COUNT(drug) as drug_count,
ABS (SUM(cogs-total_sales))as total_loss
FROM pharmacy_sales
WHERE total_sales < cogs
GROUP BY manufacturer
ORDER BY total_loss DESC
--ex9
select * from Cinema
where id%2=1 and description<>'boring'
order by rating desc
--ex10
select teacher_id,
count(distinct subject_id) as cnt
from Teacher
group by teacher_id
--exx11
select user_id,
count(follower_id) as followers_count
from Followers
group by user_id
order by user_id
--ex12
select class from Courses
group by class
having count(student)>=5 
