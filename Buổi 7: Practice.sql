--ex1
select Name from STUDENTS
where Marks>75
order by right(name,3),ID
--ex2
select user_id, 
CONCAT(upper(left(name,1)),lower(right(name,length(name)-1))) as name 
from Users
--ex3
SELECT 
manufacturer,
concat('$',ROUND(SUM(total_sales)/1000000,0),' ','million') as name
FROM pharmacy_sales
GROUP BY manufacturer
order by sum(total_sales) desc, manufacturer
--ex4
SELECT
extract(month from submit_date) as mth,
product_id as product,
round(avg(stars),2) as avg_stars
FROM reviews
group by mth, product_id
order by mth, product 
--ex5
--output:sender, message_count
SELECT
sender_id,
count(message_id) as message_count
FROM messages
where extract(month from sent_date)=8 and extract(year from sent_date)=2022
GROUP BY sender_id
order by message_count desc
limit 2
--ex6
select tweet_id from Tweets
where length(content) > 15
--ex7
select 
activity_date as day,
count (distinct user_id) as active_users
from Activity
where activity_date between '2019-06-27' and '2019-07-27'
group by activity_date
--ex8
select 
count(id) as number_employee
from employees
where extract(month from joining_date) between 1 and 7
and extract(year from joining_date) = 2022
--ex9
select 
position ('a'in first_name)
from worker
where first_name = 'Amitah' 
--ex10
select substring(title, length(winery)+2,4) 
from winemag_p2
where country='Macedonia'

