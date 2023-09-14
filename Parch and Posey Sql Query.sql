-- Now write a query that again displays order ID, account ID, and total dollar amount for each order, but this time sorted first by total dollar amount (in descending order), and then by account ID (in ascending order).
SELECT id,account_id,total_amt_usd 
FROM Parch_Posey..orders
ORDER BY total_amt_usd desc, account_id;

--Pulls the first 5 rows and all columns from the orders table that have a dollar amount of gloss_amt_usd greater than or equal to 1000.
SELECT * 
FROM Parch_Posey..orders
WHERE gloss_amt_usd >= 1000
ORDER BY id
OFFSET 0 ROWS FETCH FIRST 5 ROWS ONLY;

--Pulls the first 10 rows and all columns from the orders table that have a total_amt_usd less than 500.
SELECT * 
FROM Parch_Posey..orders
WHERE total_amt_usd < 500
ORDER BY id
OFFSET 0 ROWS FETCH FIRST 10 ROWS ONLY;

-- Write a query that finds the percentage of revenue that comes from poster paper for each order. You will need to use only the columns that end with _usd. (Try to do this without using the total column.) Display the id and account_id fields also. 
SELECT id, account_id, poster_amt_usd/(standard_amt_usd + gloss_amt_usd + poster_amt_usd) AS post_per
FROM Parch_Posey..orders
ORDER BY id
OFFSET 0 ROWS FETCH FIRST 10 ROWS ONLY;

-- All companies whose names contain the string 'one' somewhere in the name.
SELECT name
FROM Parch_Posey..accounts
WHERE name like '%one%'

-- Use the accounts table to find the account name, primary poc, and sales rep id for all stores except Walmart, Target, and Nordstrom.
SELECT name,primary_poc,sales_rep_id
FROM Parch_Posey..accounts
WHERE name Not in ('walmart','target','nordstrom')

--Find all the company names that start with a 'C' or 'W', and the primary contact contains 'ana' or 'Ana', but it doesn't contain 'eana'.
SELECT NAME
FROM Parch_Posey..accounts
WHERE (name LIKE 'C%' or name like 'w%') and
((primary_poc like '%ana%') or primary_poc not like '%eana%')

--Provide the name for each region for every order, as well as the account name and the unit price they paid (total_amt_usd/total) for the order. Your final table should have 3 columns: region name, account name, and unit price.
SELECT r.name region,a.name,(o.total_amt_usd/o.total + 0.01) unit_price
FROM Parch_Posey..region r
JOIN Parch_Posey..sales_reps s
ON r.id = s.region_id  
JOIN Parch_Posey..accounts a 
ON s.id = a.sales_rep_id
JOIN Parch_Posey..orders o
ON  a.id = o.account_id

--Provide a table that provides the region for each sales_rep along with their associated accounts. This time only for the Midwest region. Your final table should include three columns: the region name, the sales rep name, and the account name. Sort the accounts alphabetically (A-Z) according to account name.
SELECT r.name region,s.name,a.name 
FROM Parch_Posey..region r
JOIN Parch_Posey..sales_reps s
ON r.id = s.region_id  
JOIN Parch_Posey..accounts a 
ON s.id = a.sales_rep_id
WHERE r.name = 'midwest' 
ORDER BY a.name 

--Provide the name for each region for every order, as well as the account name and the unit price they paid (total_amt_usd/total) for the order. However, you should only provide the results if the standard order quantity exceeds 100 and the poster order quantity exceeds 50. Your final table should have 3 columns: region name, account name, and unit price. Sort for the largest unit price first. 
SELECT r.name region,a.name,(o.total_amt_usd/o.total + 0.01) unit_price
FROM Parch_Posey..region r
JOIN Parch_Posey..sales_reps s
ON r.id = s.region_id  
JOIN Parch_Posey..accounts a 
ON s.id = a.sales_rep_id
JOIN Parch_Posey..orders o
ON  a.id = o.account_id
Where o.standard_qty >  100 and o.poster_qty > 50

--Determine the number of times a particular channel was used in the web_events table for each sales rep. Your final table should have three columns - the name of the sales rep, the channel, and the number of occurrences. Order your table with the highest number of occurrences first.
SELECT S.name,W.channel,COUNT(W.CHANNEL) number_of_orders
FROM Parch_Posey..web_events W
JOIN Parch_Posey..accounts A
ON W.account_id= A.id
JOIN Parch_Posey..sales_reps S
ON S.id = A.sales_rep_id
GROUP BY W.channel, s.name
ORDER BY number_of_orders desc;

--Determine the number of times a particular channel was used in the web_events table for each region. Your final table should have three columns - the region name, the channel, and the number of occurrences. Order your table with the highest number of occurrences first.
SELECT R.name,W.channel,COUNT(W.CHANNEL) number_of_orders
FROM Parch_Posey..web_events W
JOIN Parch_Posey..accounts A
ON W.account_id= A.id
JOIN Parch_Posey..sales_reps S
ON S.id = A.sales_rep_id
JOIN Parch_Posey..region R
ON R.id = S.region_id
GROUP BY W.channel, R.name
ORDER BY number_of_orders desc;

--Use DISTINCT to test if there are any accounts associated with more than one region.
SELECT A.id, R.ID
FROM Parch_Posey..accounts A
JOIN Parch_Posey..sales_reps S
ON S.id = A.sales_rep_id
JOIN Parch_Posey..region R
ON R.id = S.region_id

SELECT DISTINCT ID,name
FROM Parch_Posey..accounts
/*Since the number of rows are same in both the queries we know that each account is associated with only one region.*/

--How many of the sales reps have more than 5 accounts that they manage?
SELECT s.id, s.name, COUNT(*) num_accounts
FROM Parch_Posey..accounts a
JOIN Parch_Posey..sales_reps s
ON s.id = a.sales_rep_id
GROUP BY s.id, s.name
HAVING count(*) > '5'
ORDER BY num_accounts

--How many accounts have more than 20 orders?
SELECT COUNT(table1.no_orders)
FROM
(SELECT a.id, a.name, count(*) no_orders
FROM Parch_Posey..accounts A
JOIN Parch_Posey..web_events W
ON A.id = W.account_id
group by a.id, a.name  
HAVING count(*)>20) table1;

--Which account has the most orders?
SELECT top 1 a.name,a.id,count(*) account_with_max_orders
FROM Parch_Posey..accounts a
join Parch_Posey..orders o
on a.id = o.account_id
group by a.name,a.id
order by count(*) desc

--Which accounts spent more than 30,000 usd total across all orders?
SELECT a.id,a.name,sum(o.total_amt_usd) sum_total
FROM Parch_Posey..accounts a
join Parch_Posey..orders o
on a.id = o.account_id
group by a.id,a.name
having sum(o.total_amt_usd) > 30000

--Which accounts spent less than 1,000 usd total across all orders?
SELECT a.id,a.name,sum(o.total_amt_usd) sum_total
FROM Parch_Posey..accounts a
join Parch_Posey..orders o
on a.id = o.account_id
group by a.id,a.name
having sum(o.total_amt_usd) < 1000

--Which account has spent the most with us?
SELECT a.id,a.name,sum(o.total_amt_usd) sum_total
FROM Parch_Posey..accounts a
join Parch_Posey..orders o
on a.id = o.account_id
group by a.id,a.name
ORDER BY sum_total DESC
OFFSET 0 ROWS FETCH FIRST 1 ROWS ONLY;

--Which account has spent the least with us?
SELECT a.id,a.name,sum(o.total_amt_usd) sum_total
FROM Parch_Posey..accounts a
join Parch_Posey..orders o
on a.id = o.account_id
group by a.id,a.name
ORDER BY sum_total
OFFSET 0 ROWS FETCH FIRST 1 ROWS ONLY;

--Which year did Parch & Posey have the greatest sales in terms of total number of orders? Are all years evenly represented by the dataset?
SELECT DATEPART(YYYY , occurred_at) order_year,  COUNT(*) total_sales
FROM Parch_Posey..orders
GROUP BY DATEPART(YYYY , occurred_at)
ORDER BY total_sales DESC;

--Create a column that divides the standard_amt_usd by the standard_qty to find the unit price for standard paper for each order.
SELECT id,account_id, CASE WHEN standard_qty = 0 OR standard_qty IS NULL THEN 0
                        ELSE standard_amt_usd/standard_qty END AS unit_price
FROM Parch_Posey..orders 
order by unit_price desc
OFFSET 0 ROWS FETCH FIRST 10 ROWS ONLY;

--We would now like to perform a similar calculation to the first, but we want to obtain the total amount spent by customers only in 2016 and 2017. Keep the same levels as in the previous question. Order with the top spending customers listed first.
SELECT a.name, SUM(O.total_amt_usd)sum_spend,
         CASE WHEN sum(o.total_amt_usd) > 200000 THEN 'top'
        WHEN  SUM(O.total_amt_usd) > 100000 THEN 'middle'
        ELSE 'low' END AS customer_level, o.occurred_at
FROM Parch_Posey..accounts A
JOIN Parch_Posey..orders O
ON A.id = O.account_id
WHERE o.occurred_at > '2015-12-31'
GROUP BY a.name,o.occurred_at
order by customer_level desc

--Provide the name of the sales_rep in each region with the largest amount of total_amt_usd sales.
SELECT t3.name,t3.region,t3.amt
FROM
    (SELECT t1.name ,t1.region region, MAX(t1.amt) amt
    FROM (SELECT S.name name, R.name region , SUM(O.total_amt_usd) amt
       FROM Parch_Posey..orders O
       JOIN Parch_Posey..accounts A
        ON A.id = O.account_id
        JOIN Parch_Posey..sales_reps S
       ON A.sales_rep_id = S.id
       JOIN Parch_Posey..region R
       ON S.region_id = R.id
       GROUP BY S.name,R.name) t1
GROUP BY region,name) t2
join
     (SELECT S.name , R.name region , SUM(O.total_amt_usd) amt
       FROM Parch_Posey..orders O
       JOIN Parch_Posey..accounts A
        ON A.id = O.account_id
        JOIN Parch_Posey..sales_reps S
       ON A.sales_rep_id = S.id
       JOIN Parch_Posey..region R
       ON S.region_id = R.id
       GROUP BY S.name,R.name) t3
on t2.region= t3.region and t2.amt = t3.amt

--What is the lifetime average amount spent in terms of total_amt_usd for the top 10 total spending accounts?
SELECT AVG(amt_spent) avg_amt_spent
FROM (SELECT a.id,a.name name,sum(o.total_amt_usd) amt_spent
      FROM Parch_Posey..accounts a
      JOIN Parch_Posey..orders o
      on a.id = o.account_id
      group by a.ID, name
      order by amt_spent DESC
      offset 0 rows fetch first 10 rows only) t1

--What is the lifetime average amount spent in terms of total_amt_usd, including only the companies that spent more per order, on average, than the average of all orders.
select round(avg(avg_amt),0) total_avg
from (select account_id id, avg(total_amt_usd) avg_amt
from Parch_Posey..orders
group by account_id
having AVG(total_amt_usd) >  (Select avg(total_amt_usd) avg_all 
from Parch_Posey..orders)) temp