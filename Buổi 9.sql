--ex1
SELECT
sum (CASE
  when device_type = 'tablet' or device_type = 'phone' then 1 
  else 0
END) as mobile_views,
sum (CASE
  when device_type = 'laptop' then '1' 
  else 0
END) as laptop_views
FROM viewership;
--ex2
select x, y, z, 
case when x + y > z and x + z > y and y + z > x then 'Yes'  
     else 'No'  
end as triangle
from Triangle
--ex3
SELECT
  ROUND(100.0 * 
    SUM(CASE WHEN call_category IS NULL OR call_category = 'n/a'
      THEN 1
      ELSE 0
      END)
    /COUNT(*), 1) AS uncategorised_call_pct
FROM callers
--ex4
SELECT name FROM Customer
WHERE referee_id IS NULL OR referee_id <> 2
--ex5
SELECT
    survived,
    sum(CASE WHEN pclass = 1 THEN 1 ELSE 0 END) AS first_class,
    sum(CASE WHEN pclass = 2 THEN 1 ELSE 0 END) AS second_class,
    sum(CASE WHEN pclass = 3 THEN 1 ELSE 0 END) AS third_class
FROM titanic
GROUP BY survived
