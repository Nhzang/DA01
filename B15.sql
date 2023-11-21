--ex1
with twt_yoy_rate as 
(
SELECT extract(year from transaction_date) as year,product_id,spend as curr_year_spend,
lag(spend) over(partition by product_id order by transaction_date) as prev_year_spend

from user_transactions)

select *,round(100.0*(curr_year_spend-prev_year_spend)/prev_year_spend,2) as yoy_rate
from twt_yoy_rate;
--ex2
WITH rank_cards AS
(SELECT
  card_name,
  issued_amount,
  RANK() OVER(PARTITION BY card_name ORDER BY issue_year, issue_month) AS ranker
FROM monthly_cards_issued)

SELECT
  card_name,
  issued_amount
FROM rank_cards
WHERE ranker = 1
ORDER BY issued_amount DESC;
--ex3
with cte_user_id AS(
Select user_id, spend, transaction_date,
      row_number() Over (PARTITION BY user_id Order By user_id,transaction_date) AS row_num
      From transactions
)
Select user_id, spend, transaction_date From cte_user_id
Where row_num = 3
--ex4
WITH twt_r AS (
SELECT 
transaction_date,user_id,count(transaction_date) as purchase_count,
dense_rank() over(PARTITION BY user_id ORDER BY transaction_date desc) AS rn
FROM user_transactions
GROUP BY transaction_date,user_id
ORDER BY user_id
)
SELECT 
transaction_date,user_id,purchase_count
FROM twt_r 
WHERE rn = 1
ORDER BY transaction_date;
--ex5
WITH lag_cte AS  (
  SELECT 
    *,
    LAG(tweet_count, 1) OVER(
        PARTITION BY user_id
        ORDER BY tweet_date
      ) AS lag_1,
      LAG(tweet_count, 2) OVER(
        PARTITION BY user_id
        ORDER BY tweet_date
      ) AS lag_2
  FROM tweets
)
SELECT 
  user_id,
  tweet_date,
  ROUND((tweet_count + lag_1 + lag_2) / 3, 2) AS rolling_avg_3d
From lag_cte
--ex6
with twt_tb1 as 
(SELECT merchant_id, credit_card_id, amount, transaction_timestamp,
lag(transaction_timestamp) 
OVER(PARTITION BY merchant_id, credit_card_id, amount order by transaction_timestamp) 
as prev_transaction
FROM transactions
where EXTRACT(MINUTE from transaction_timestamp) <= 10
)

select COUNT(merchant_id) as payment_count from twt_tb1 
where EXTRACT(MINUTE FROM transaction_timestamp)-EXTRACT(MINUTE FROM prev_transaction) <= 10
--ex7
with tb1 as 
(
select category, product, sum(spend) as total_spend
from product_spend
where category = 'appliance'
and transaction_date >= '2022-01-01' 
    AND transaction_date <= '2022-12-31' 
group by category,product
order by sum(spend) desc
limit 2
),
tb2 as
(select category, product, sum(spend) as total_spend
from product_spend
where category = 'electronics'
and  transaction_date >= '2022-01-01' 
    AND transaction_date <= '2022-12-31' 
group by category,product
order by sum(spend) desc
limit 2)

select *
from tb1 
UNION all
select *
from tb2
--ex8
WITH top_artists AS (
        SELECT artist_name,
               COUNT(*) AS no_appearance
          FROM artists AS a
          JOIN songs AS s 
            ON s.artist_id = a.artist_id
          JOIN global_song_rank AS g
            ON g.song_id = s.song_id
         WHERE g.rank < 11
         GROUP BY artist_name
)
SELECT artist_name,
       artist_rank
  FROM (
        SELECT artist_name,
               DENSE_RANK() OVER(ORDER BY no_appearance DESC) AS artist_rank
          FROM top_artists
          ) AS top
 WHERE artist_rank < 6

