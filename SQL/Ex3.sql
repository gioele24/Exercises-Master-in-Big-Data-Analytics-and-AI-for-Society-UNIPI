/* GROUPING(A) returns 1 if current row aggregates over A
   SELECT GROUPING(A),A,B,C,SUM(M) 
   FROM …
   GROUP BY ROLLUP(A,B,C)
   
Study how GROUPING works, and use it to write an SQL query over 
Foodmart to solve

- Total Store Sales by Country and City 
with sub-total and total rows at the correct order, and with ‘Total’ instead of 
NULLS.
*/

SELECT CASE WHEN GROUPING(c.country) = 1 THEN 'Total' ELSE c.country END as country, 
       CASE WHEN GROUPING(c.city) = 1 THEN 'Total' ELSE c.city END as city, 
SUM(sf.store_sales) as TotalSales--, GROUPING(c.country), GROUPING(c.city)
FROM sales_fact sf, customer c  
WHERE sf.customer_id  = c.customer_id 
GROUP BY ROLLUP(c.country, c.city)
ORDER BY GROUPING(c.country), c.country, GROUPING(c.city), c.city 

-- 1. Total sales in January 1998 by customer city and day of week

SELECT c.city, tbd.the_day, SUM(sf.store_sales) AS TotalSales
FROM sales_fact sf, customer c, time_by_day tbd 
WHERE sf.customer_id = c.customer_id AND sf.time_id = tbd.time_id 
      AND tbd.the_month = 'January' AND tbd.the_year = 1998
GROUP BY c.city, tbd.the_day 
ORDER BY c.city, tbd.the_day 

-- 2. In addition to 1, the percentage of total sales over the total sales of the customer city, and the 
-- percentage over the grand total of sales

WITH temp as (
SELECT c.city, tbd.the_day, SUM(sf.store_sales) AS TotalSales
FROM sales_fact sf, customer c, time_by_day tbd 
WHERE sf.customer_id = c.customer_id AND sf.time_id = tbd.time_id 
      AND tbd.the_month = 'January' AND tbd.the_year = 1998
GROUP BY c.city, tbd.the_day 
)
SELECT city, the_day, TotalSales,
100*TotalSales/SUM(TotalSales) OVER (PARTITION BY city) AS PctTotSalesCity,
100*TotalSales/SUM(TotalSales) OVER () AS PctTotSales
FROM temp
ORDER BY city, the_day

-- 3. In addition to 2, the rank position of day wrt customers’ sales in customer’s city

WITH temp as (
SELECT c.city, tbd.the_day, SUM(sf.store_sales) AS TotalSales
FROM sales_fact sf, customer c, time_by_day tbd 
WHERE sf.customer_id = c.customer_id AND sf.time_id = tbd.time_id 
      AND tbd.the_month = 'January' AND tbd.the_year = 1998
GROUP BY c.city, tbd.the_day 
)
SELECT city, the_day, TotalSales,
100*TotalSales/SUM(TotalSales) OVER (PARTITION BY city) AS PctTotSalesCity,
100*TotalSales/SUM(TotalSales) OVER () AS PctTotSales,
RANK () OVER (PARTITION BY city ORDER BY TotalSales DESC) AS WeekRankPerCity
FROM temp
ORDER BY city, WeekRankPerCity

-- 4. In addition to 3, restrict to only day ranked 1st for each city

WITH temp as (
SELECT c.city, tbd.the_day, SUM(sf.store_sales) AS TotalSales
FROM sales_fact sf, customer c, time_by_day tbd 
WHERE sf.customer_id = c.customer_id AND sf.time_id = tbd.time_id 
      AND tbd.the_month = 'January' AND tbd.the_year = 1998
GROUP BY c.city, tbd.the_day 
),
temp2 as (
SELECT city, the_day, TotalSales,
100*TotalSales/SUM(TotalSales) OVER (PARTITION BY city) AS PctTotSalesCity,
100*TotalSales/SUM(TotalSales) OVER () AS PctTotSales,
RANK () OVER (PARTITION BY city ORDER BY TotalSales DESC) AS WeekRankPerCity
FROM temp
)
SELECT city, the_day, TotalSales, PctTotSalesCity, PctTotSales--, WeekRankPerCity
FROM temp2 
WHERE WeekRankPerCity = 1
ORDER BY city, WeekRankPerCity


/* We want to partition the customers into four groups:
 – Top5%, with 5% of customers with the highest amount of revenues.
 – Next15%, with 15% of other customers with the highest amount of revenues.
 – Middle30%, with 30% of other customers with the highest amount of revenues.
 – Bottom50%, with 50 % of the customers with the lowest amount of revenues.
 For each customer group we want to know their number, and the percentage
 of the sum of their revenues compared to total revenue of all sales.*/

WITH temp AS (
SELECT c.customer_id, SUM(sf.store_sales) AS TotalSales
FROM sales_fact sf, customer c 
WHERE sf.customer_id = c.customer_id 
GROUP BY c.customer_id
),
temp2 AS (
SELECT customer_id, TotalSales,
CUME_DIST() OVER (ORDER BY TotalSales) AS CumeDist
FROM temp
),
temp3 AS (
SELECT customer_id, TotalSales, CumeDist,
CASE 
	WHEN CumeDist > 1 - 0.05 THEN 'Top5%' 
	WHEN CumeDist > 1 - 0.2 THEN 'Next15%'
	WHEN CumeDist > 1 - 0.5 THEN 'Middle30%'
	ELSE 'Bottom50%'
END AS Ranking
FROM temp2
)
SELECT Ranking, COUNT(*) AS NCustomers,
100*SUM(TotalSales)/SUM(SUM(TotalSales)) OVER () AS PctTotSales
FROM temp3
GROUP BY Ranking
ORDER BY NCustomers 

--  Write an analytic SQL query using Lag-Lead (but NO JOIN) to compute a variance 
--  report comparing total sales by country and city in 1998 vs 1997

-- Delta = 100 x (Revenue2009 - Revenue2008)/Revenue2009
-- NOTE: A product may have been sold in one year, but not in the other !

WITH temp as (
SELECT c.country, c.city, tbd.the_year, SUM(sf.store_sales) AS TotalSales
FROM sales_fact sf, customer c, time_by_day tbd 
WHERE sf.customer_id = c.customer_id AND sf.time_id = tbd.time_id
GROUP BY c.country, c.city, tbd.the_year
),
temp2 as (
SELECT country, city, the_year, TotalSales,
LAG(TotalSales, 1, 0) OVER (PARTITION BY country, city ORDER BY the_year) AS PrevY,
LEAD(TotalSales, 1, 0) OVER (PARTITION BY country, city ORDER BY the_year) AS NextY
FROM temp
)
SELECT country, city, TotalSales AS TotalSales98, PrevY AS TotalSales97,
100*(TotalSales - PrevY)/TotalSales AS Delta
FROM temp2
WHERE the_year = 1998
ORDER BY country, city, the_year, TotalSales98


-- 1. number of customers who spent more than 50% of their total in the store by store

WITH temp AS (
SELECT sf.store_id, sf.customer_id, SUM(sf.store_sales) AS TotalSalesPerStore
FROM sales_fact sf
GROUP BY sf.store_id, sf.customer_id 
),
temp2 AS (
SELECT store_id, customer_id, TotalSalesPerStore,
SUM(TotalSalesPerStore) OVER (PARTITION BY customer_id) AS TotalSales
FROM temp
)
SELECT store_id, COUNT(*) AS NCustomers
FROM temp2
WHERE 100*TotalSalesPerStore/TotalSales > 50
GROUP BY store_id


-- 2. number of customers who spent the largest amount of their total in the store by store


WITH temp AS (
SELECT sf.store_id, sf.customer_id, SUM(sf.store_sales) AS TotalSalesPerStore,
MAX(SUM(sf.store_sales)) OVER (PARTITION BY sf.customer_id) AS Max_TotalSalesPerStore
FROM sales_fact sf
GROUP BY sf.store_id, sf.customer_id
)
SELECT store_id, 
SUM(CASE WHEN TotalSalesPerStore = Max_TotalSalesPerStore THEN 1 ELSE 0 END) AS NCustomers
FROM temp
GROUP BY store_id


-- 3. number of customers with total sales in the store lower or equal than 100 by store

WITH temp AS (
SELECT sf.store_id, sf.customer_id, SUM(sf.store_sales) AS TotalSalesPerStore
FROM sales_fact sf
GROUP BY sf.store_id, sf.customer_id
)
SELECT store_id, SUM(CASE WHEN TotalSalesPerStore <= 100 THEN 1 ELSE 0 END) AS NCustomers
FROM temp
GROUP BY store_id

-- 4. number of customers with at least one day with total sales in the store greater or 
--    equal than 100 by store

-- Fai attenzione che potrebbero esserci clienti che hanno acquistato nello stesso negozio in due giorni diversi e hanno
-- speso più di 100. Questi clienti vanno contati una sola volta.

WITH temp AS (
SELECT sf.store_id, sf.customer_id, tbd.the_date, SUM(sf.store_sales) AS TotalSalesPerStore
FROM sales_fact sf, time_by_day tbd 
WHERE sf.time_id = tbd.time_id
GROUP BY sf.store_id, sf.customer_id, tbd.the_date
)
SELECT store_id, COUNT(DISTINCT CASE WHEN TotalSalesPerStore >= 100 THEN customer_id ELSE NULL END) AS NCustomers
FROM temp
GROUP BY store_id


-- 5. number of customers with no day with total sales in the store greater or equal than 
--    100 (but with at least one sale in the store) by store

WITH temp AS (
SELECT sf.store_id, sf.customer_id, tbd.the_date, SUM(sf.store_sales) AS TotalSalesPerStore,
CASE WHEN SUM(sf.store_sales) >= 100 THEN 1 ELSE 0 END AS Flag
FROM sales_fact sf, time_by_day tbd 
WHERE sf.time_id = tbd.time_id
GROUP BY sf.store_id, sf.customer_id, tbd.the_date
),
temp2 AS (
SELECT store_id, customer_id
FROM temp
GROUP BY store_id, customer_id
HAVING SUM(Flag) = 0
)
SELECT store_id, COUNT(*) AS NCustomers
FROM temp2
GROUP BY store_id

-- 6. all triples customer_id, the_year, month_of_the_year in which the customer bought 
--    something in that month but nothing in the next month.

WITH temp AS (
SELECT sf.customer_id, tbd.the_year, tbd.month_of_year
FROM sales_fact sf, time_by_day tbd
WHERE sf.time_id = tbd.time_id
GROUP BY sf.customer_id, tbd.the_year, tbd.month_of_year
),
temp2 AS (
SELECT customer_id, the_year, month_of_year,
LEAD(month_of_year, 1, NULL) OVER (PARTITION BY customer_id ORDER BY the_year, month_of_year) AS NextMonth
FROM temp
)
SELECT customer_id, the_year, month_of_year
FROM temp2
WHERE ABS(NextMonth - month_of_year) > 1
ORDER BY customer_id, the_year, month_of_year

-- 7. the ratio of total sales to a customer in a year-month over the total sales to the 
--    customer in that year, by customer and year-month

SELECT sf.customer_id, tbd.the_year, tbd.month_of_year, SUM(sf.store_sales) AS TotalMonthSales,
SUM(SUM(sf.store_sales)) OVER (PARTITION BY customer_id, the_year) AS TotalYearSales,
100.0*SUM(sf.store_sales)/SUM(SUM(sf.store_sales)) OVER (PARTITION BY customer_id, the_year) AS PctRatioOverTotalYear
FROM sales_fact sf, time_by_day tbd 
WHERE sf.time_id = tbd.time_id
GROUP BY sf.customer_id, tbd.the_year, tbd.month_of_year 
ORDER BY sf.customer_id, tbd.the_year, tbd.month_of_year  


-- 8. the top spending day of week, by customer

WITH temp AS (
SELECT sf.customer_id, tbd.the_day, SUM(sf.store_sales) AS TotalSalesPerWeekDay,
RANK () OVER(PARTITION BY customer_id ORDER BY SUM(sf.store_sales) DESC) AS TopSalesDay
FROM sales_fact sf, time_by_day tbd 
WHERE sf.time_id = tbd.time_id
GROUP BY sf.customer_id, tbd.the_day
)
SELECT customer_id, the_day, TotalSalesPerWeekDay
FROM temp
WHERE TopSalesDay = 1
ORDER BY customer_id

-- ALternative version (not using the RANK() function) 

with temp as (
	SELECT sf.customer_id, tbd.the_day, SUM(sf.store_sales) as TotalWeekDay,
	MAX(SUM(sf.store_sales)) OVER (PARTITION BY customer_id) as MaxSpentWeekDay
	FROM sales_fact sf, time_by_day tbd
	WHERE sf.time_id = tbd.time_id
	GROUP BY customer_id, tbd.the_day
), temp2 as (
	SELECT customer_id,
	       CASE
	       	WHEN TotalWeekDay = MaxSpentWeekDay THEN the_day ELSE NULL
	       END as best_day,
	       TotalWeekDay
	FROM temp
)
SELECT customer_id, best_day, TotalWeekDay
FROM temp2
WHERE best_day IS NOT NULL
ORDER BY customer_id
 

-- 9. the 10 top spending customers and the ratio of their spending over the total sales of 
--    the store, by store_id

WITH temp AS (
SELECT sf.store_id, sf.customer_id, SUM(sf.store_sales) AS TotalSales,
RANK () OVER (PARTITION BY store_id ORDER BY SUM(sf.store_sales) DESC) AS RankCust,
100.0*SUM(sf.store_sales)/SUM(SUM(sf.store_sales)) OVER (PARTITION BY store_id) AS Ratio
FROM sales_fact sf 
GROUP BY sf.store_id, sf.customer_id
)
SELECT store_id, customer_id, TotalSales, RankCust, Ratio
FROM temp
WHERE RankCust <= 10
ORDER BY store_id, RankCust


-- 10. add to the previous query also the running total of the top k customers, for k=1, …, 10

WITH temp AS (
SELECT sf.store_id, sf.customer_id, SUM(sf.store_sales) AS TotalSales,
RANK () OVER (PARTITION BY store_id ORDER BY SUM(sf.store_sales) DESC) AS RankCust,
100.0*SUM(sf.store_sales)/SUM(SUM(sf.store_sales)) OVER (PARTITION BY store_id) AS Ratio
FROM sales_fact sf 
GROUP BY sf.store_id, sf.customer_id
),
temp2 AS (
SELECT store_id, customer_id, TotalSales, RankCust, Ratio
FROM temp
WHERE RankCust <= 10
)
SELECT store_id, customer_id, TotalSales, RankCust, Ratio,
SUM(TotalSales) OVER (PARTITION BY store_id ORDER BY RankCust ROWS UNBOUNDED PRECEDING) AS RunningTotal
FROM temp2
ORDER BY store_id, RankCust

--  11. add to the previous query also the delta between customer k and k+1, for k=1,…,9

WITH temp AS (
SELECT sf.store_id, sf.customer_id, SUM(sf.store_sales) AS TotalSales,
RANK () OVER (PARTITION BY store_id ORDER BY SUM(sf.store_sales) DESC) AS RankCust,
100.0*SUM(sf.store_sales)/SUM(SUM(sf.store_sales)) OVER (PARTITION BY store_id) AS Ratio
FROM sales_fact sf 
GROUP BY sf.store_id, sf.customer_id
),
temp2 AS (
SELECT store_id, customer_id, TotalSales, RankCust, Ratio
FROM temp
WHERE RankCust <= 10
),
temp3 AS (
SELECT store_id, customer_id, TotalSales, RankCust, Ratio,
SUM(TotalSales) OVER (PARTITION BY store_id ORDER BY RankCust ROWS UNBOUNDED PRECEDING) AS RunningTotal,
LEAD(TotalSales, 1, 0) OVER (PARTITION BY store_id ORDER BY RankCust) AS NextTotSales
FROM temp2
)
SELECT store_id, customer_id, TotalSales, RankCust, Ratio, RunningTotal, NextTotSales,
TotalSales - NextTotSales AS Delta
FROM temp3
ORDER BY store_id, RankCust

-- Same query but more compact (with one less view)

WITH temp AS (
SELECT sf.store_id, sf.customer_id, SUM(sf.store_sales) AS TotalSales,
RANK () OVER (PARTITION BY store_id ORDER BY SUM(sf.store_sales) DESC) AS RankCust,
100.0*SUM(sf.store_sales)/SUM(SUM(sf.store_sales)) OVER (PARTITION BY store_id) AS Ratio
FROM sales_fact sf 
GROUP BY sf.store_id, sf.customer_id
),
temp2 AS (
SELECT store_id, customer_id, TotalSales, RankCust, Ratio
FROM temp
WHERE RankCust <= 10
)
SELECT store_id, customer_id, TotalSales, RankCust, Ratio,
SUM(TotalSales) OVER (PARTITION BY store_id ORDER BY RankCust ROWS UNBOUNDED PRECEDING) AS RunningTotal,
TotalSales - LEAD(TotalSales, 1, 0) OVER (PARTITION BY store_id ORDER BY RankCust) AS Delta
FROM temp2
ORDER BY store_id, RankCust

/* Consider the reference period from 1 July 1998 (included) to 30 September 1998 
(included). The RFM index (Recency-Frequency-Monetary) of a customer is a three digit 
string:

 •the first digit is the quintile (1 = bottom 20%, 5 = top 20%) of the customer w.r.t. 
recency (days from 30 September 1998 since the last purchase in the reference 
period);
 •the second digit is the quintile (1 = top 20%, 5 = bottom 20%) of the customer w.r.t. 
frequency (number of distinct days of purchases in the reference period);
 •the third digit is the quintile (1 = top 20%, 5 = bottom 20%) of the customer w.r.t. 
monetary (money spent in the reference period).
 
 Output for every customer_id, its rfm index.*/



WITH temp AS (
SELECT sf.customer_id, -- tbd.the_date,
DATEDIFF(day, MAX(tbd.the_date), '1998-09-30') AS Recency,
--RANK() OVER(PARTITION BY customer_id ORDER BY DATEDIFF(day, tbd.the_date, '1998-09-30')) AS RankRecency,
COUNT(DISTINCT tbd.time_id) /*OVER (PARTITION BY sf.customer_id)*/ AS Frequency,
SUM(sf.store_sales) /*OVER (PARTITION BY customer_id)*/ AS Monetary
FROM sales_fact sf, time_by_day tbd 
WHERE sf.time_id = tbd.time_id AND (tbd.the_date BETWEEN '1998-07-01' AND '1998-09-30')
-- WHERE tbd.the_month IN ('July', 'August', 'September') AND tbd.the_year = 1998
GROUP BY sf.customer_id--, tbd.the_date
--ORDER BY sf.customer_id, tbd.the_date
),
temp2 AS (
SELECT customer_id,-- the_date, Recency, Frequency, Monetary,
CUME_DIST() OVER (ORDER BY Recency) AS CumeDistRecency,
CUME_DIST() OVER (ORDER BY Frequency DESC) AS CumeDistFrequency,
CUME_DIST() OVER (ORDER BY Monetary DESC) AS CumeDistMonetary
FROM temp
--WHERE RankRecency = 1
--ORDER BY customer_id, the_date
),
temp3 AS (
SELECT customer_id, /*the_date,*/ CumeDistRecency, CumeDistFrequency, CumeDistMonetary,
	   CASE
	        WHEN CumeDistRecency < 0.2 THEN '1'
	       	WHEN CumeDistRecency < 0.4 THEN '2'
	       	WHEN CumeDistRecency < 0.6 THEN '3'
	       	WHEN CumeDistRecency < 0.8 THEN '4'
	       	ELSE '5'
	       END AS FirstDigit,
	       CASE
	       	WHEN CumeDistFrequency < 0.2 THEN '1'
	       	WHEN CumeDistFrequency < 0.4 THEN '2'
	       	WHEN CumeDistFrequency < 0.6 THEN '3'
	       	WHEN CumeDistFrequency < 0.8 THEN '4'
	       	ELSE '5'
	       END AS SecondDigit,
	       CASE
	       	WHEN CumeDistMonetary < 0.2 THEN '1'
	       	WHEN CumeDistMonetary < 0.4 THEN '2'
	       	WHEN CumeDistMonetary < 0.6 THEN '3'
	       	WHEN CumeDistMonetary < 0.8 THEN '4'
	       	ELSE '5'
	       END AS ThirdDigit
FROM temp2
)
SELECT customer_id, FirstDigit + SecondDigit + ThirdDigit AS RFM,
CONCAT(FirstDigit, SecondDigit, ThirdDigit) AS RFM2
FROM temp3
ORDER BY customer_id



WITH temp AS (
SELECT sf.customer_id, -- tbd.the_date,
DATEDIFF(day, MAX(tbd.the_date), '1998-09-30') AS Recency,
--RANK() OVER(PARTITION BY customer_id ORDER BY DATEDIFF(day, tbd.the_date, '1998-09-30')) AS RankRecency,
COUNT(DISTINCT tbd.time_id) /*OVER (PARTITION BY sf.customer_id)*/ AS Frequency,
SUM(sf.store_sales) /*OVER (PARTITION BY customer_id)*/ AS Monetary
FROM sales_fact sf, time_by_day tbd 
WHERE sf.time_id = tbd.time_id AND (tbd.the_date BETWEEN '1998-07-01' AND '1998-09-30')
-- WHERE tbd.the_month IN ('July', 'August', 'September') AND tbd.the_year = 1998
GROUP BY sf.customer_id--, tbd.the_date
--ORDER BY sf.customer_id, tbd.the_date
),
temp2 AS (
SELECT customer_id, the_date, --Recency, Frequency, Monetary,
CUME_DIST() OVER (ORDER BY Recency) AS CumeDistRecency,
CUME_DIST() OVER (ORDER BY Frequency DESC) AS CumeDistFrequency,
CUME_DIST() OVER (ORDER BY Monetary DESC) AS CumeDistMonetary
FROM temp
--WHERE RankRecency = 1
--ORDER BY customer_id, the_date
),
temp3 AS (
SELECT customer_id, the_date, CumeDistRecency, CumeDistFrequency, CumeDistMonetary,
CASE WHEN CumeDistRecency < 0.2 THEN '5'
	 WHEN CumeDistRecency < 0.4 THEN '4'
	 WHEN CumeDistRecency < 0.6 THEN '3'
	 WHEN CumeDistRecency < 0.8 THEN '2'
	 ELSE '1'
	 END AS FirstDigit,
CASE WHEN CumeDistFrequency > 1 - 0.2 THEN '5'
	 WHEN CumeDistFrequency > 1 - 0.4 THEN '4'
	 WHEN CumeDistFrequency > 1 - 0.6 THEN '3'
	 WHEN CumeDistFrequency > 1 - 0.8 THEN '2'
	 ELSE '1'
	 END AS SecondDigit,
CASE WHEN CumeDistMonetary > 1 - 0.2 THEN '5'
	 WHEN CumeDistMonetary > 1 - 0.4 THEN '4'
	 WHEN CumeDistMonetary > 1 - 0.6 THEN '3'
	 WHEN CumeDistMonetary > 1 - 0.8 THEN '2'
	 ELSE '1'
	 END AS ThirdDigit
FROM temp2
)
SELECT customer_id, FirstDigit + SecondDigit + ThirdDigit AS RFM
FROM temp3
ORDER BY customer_id



-- Alternative version (pay attention to definitions!)

WITH temp AS (
	SELECT sf.customer_id, tbd.the_date,
	       DATEDIFF(day, tbd.the_date, '1998-09-30') AS Recency,
	       RANK() OVER ( PARTITION BY sf.customer_id ORDER BY DATEDIFF(day, tbd.the_date, '1998-09-30') ) AS RankRecency,
	       COUNT(tbd.the_date) OVER ( PARTITION BY sf.customer_id ) AS Frequency,
	       --SUM(sf.store_sales) as TotalSales,
	       SUM(SUM(sf.store_sales)) OVER ( PARTITION BY sf.customer_id ) AS Monetary
	FROM sales_fact sf, time_by_day tbd
	WHERE sf.time_id = tbd.time_id AND (tbd.the_date BETWEEN '1998-07-01' AND '1998-09-30')
	GROUP BY sf.customer_id, tbd.the_date
	--ORDER BY sf.customer_id, tbd.the_date
), temp2 AS (
	SELECT customer_id, the_date, --Recency, Frequency, Monetary,
	       CUME_DIST() OVER (ORDER BY Recency) AS CumeDistRecency,
	       CUME_DIST() OVER (ORDER BY Frequency DESC) AS CumeDistFrequency,
	       CUME_DIST() OVER (ORDER BY Monetary DESC) AS CumeDistMonetary
	FROM temp
	WHERE RankRecency = 1
	--ORDER BY customer_id, the_date
), temp3 AS (
	SELECT customer_id, the_date, CumeDistRecency, CumeDistFrequency, CumeDistMonetary,
	       CASE
	       	WHEN CumeDistRecency < 0.2 THEN '1'
	       	WHEN CumeDistRecency < 0.4 THEN '2'
	       	WHEN CumeDistRecency < 0.6 THEN '3'
	       	WHEN CumeDistRecency < 0.8 THEN '4'
	       	ELSE '5'
	       END AS FirstDigit,
	       CASE
	       	WHEN CumeDistFrequency < 0.2 THEN '1'
	       	WHEN CumeDistFrequency < 0.4 THEN '2'
	       	WHEN CumeDistFrequency < 0.6 THEN '3'
	       	WHEN CumeDistFrequency < 0.8 THEN '4'
	       	ELSE '5'
	       END AS SecondDigit,
	       CASE
	       	WHEN CumeDistMonetary < 0.2 THEN '1'
	       	WHEN CumeDistMonetary < 0.4 THEN '2'
	       	WHEN CumeDistMonetary < 0.6 THEN '3'
	       	WHEN CumeDistMonetary < 0.8 THEN '4'
	       	ELSE '5'
	       END AS ThirdDigit
	FROM temp2
)
SELECT customer_id, FirstDigit + SecondDigit + ThirdDigit AS RFM, CumeDistRecency, CumeDistFrequency, CumeDistMonetary
FROM temp3
ORDER BY customer_id


/*Output all store id, year, month number, n_new_customers 
  • where the value n_new_customers is the number of distinct customer_id's that for 
    a given store id, year, and month number had no purchases in the previous month.

•Hint: consider the bijective mapping:
the_year*12+month_of_year as monthn
transforming a date to the number of months since year 0.*/

-- 1st version: Interpreting 'new customer' as the one that for a given
-- store id, year, and month number had no purchases in the previous months (all of them).

WITH temp AS (
SELECT sf.customer_id, sf.store_id, tbd.the_year, tbd.month_of_year,
LAG(tbd.month_of_year, 1, NULL) OVER (PARTITION BY sf.customer_id, sf.store_id ORDER BY tbd.the_year, tbd.month_of_year) AS PrevMonth
FROM sales_fact sf, time_by_day tbd 
WHERE sf.time_id = tbd.time_id
GROUP BY sf.customer_id, sf.store_id, tbd.the_year, tbd.month_of_year
)
SELECT store_id, the_year, month_of_year, COUNT(customer_id) AS n_new_customers
FROM temp
WHERE PrevMonth IS NULL
GROUP BY store_id, the_year, month_of_year
ORDER BY store_id, the_year, month_of_year

-- 2nd version: Interpreting 'new customer' as the one that for a given
-- store id, year, and month number had no purchases in the previous month (only one).

WITH temp AS (
SELECT sf.customer_id, sf.store_id, tbd.the_year, tbd.month_of_year,
       LAG(tbd.month_of_year, 1, 0) OVER ( PARTITION BY  sf.customer_id, sf.store_id ORDER BY tbd.the_year, tbd.month_of_year) AS PrevMonth
       -- LAG restituisce NULL in corrispondeza della data primo acquisto di ogni cliente in ogni store
FROM sales_fact sf, time_by_day tbd
WHERE sf.time_id = tbd.time_id
GROUP BY sf.store_id, tbd.the_year, tbd.month_of_year, sf.customer_id
--ORDER BY customer_id, store_id, the_year, month_of_year
)
SELECT store_id, the_year, month_of_year, COUNT(*) AS n_new_customer
FROM temp
WHERE (month_of_year - PrevMonth > 1) OR PrevMonth = 0
GROUP BY store_id, the_year, month_of_year
ORDER BY store_id, the_year, month_of_year



 /*•The worst customer for a store_id s is the customer_id who spent the less (but non
zero) in that store s. 
Output for every store_id, its worst customer
 •Hint: search for the analytic function FIRST_VALUE*/

WITH temp AS (
SELECT sf.store_id, sf.customer_id, SUM(sf.store_sales) AS TotalSales,
RANK() OVER (PARTITION BY sf.store_id ORDER BY SUM(sf.store_sales)) AS RankCust
FROM sales_fact sf 
GROUP BY sf.store_id, sf.customer_id 
)
SELECT store_id, customer_id
FROM temp
WHERE RankCust = 1 
ORDER BY store_id, customer_id 

-- Alternative version (not using RANK())

WITH temp AS (
	SELECT store_id, customer_id, SUM(store_sales) AS TotalByCustomer,
	       MIN(SUM(store_sales)) OVER (PARTITION BY store_id) AS MinSales
	FROM sales_fact sf
	GROUP BY store_id, customer_id
)
SELECT store_id, customer_id
FROM temp
WHERE TotalByCustomer = MinSales
ORDER BY store_id, customer_id
 

-- Exercise done during Office Hour 1

WITH temp AS (
SELECT sf.store_id, sf.customer_id, c.gender
FROM sales_fact sf, customer c, time_by_day tbd 
WHERE sf.customer_id = c.customer_id  AND sf.time_id = tbd.time_id AND tbd.the_year = 1998
GROUP BY sf.store_id, sf.customer_id, c.gender
),
temp2 AS (
SELECT store_id,
SUM(CASE WHEN gender = 'M' THEN 1 ELSE 0 END) AS m_i,
SUM(CASE WHEN gender = 'F' THEN 1 ELSE 0 END) AS f_i
FROM temp
GROUP BY store_id
),
temp3 AS (
SELECT store_id, m_i, f_i, SUM(m_i) OVER () AS M, SUM(f_i) OVER () AS F
FROM temp2
)
SELECT 0.5*SUM(ABS(((1.0*f_i)/F)-((1.0*m_i)/M)))
FROM temp3


-- Queries in exam simulation
-- Use sales_exam view

--1) Total sales by product, but only for products bought by at least 2 distinct customers

WITH temp AS (
SELECT product, customer, COUNT(se.customer) OVER (PARTITION BY product) AS NCust, SUM(amount) as TotalSalesByCust
FROM sales_exam se 
GROUP BY product, customer
)
SELECT product, SUM(TotalSalesByCust) AS TotalSales
FROM temp
WHERE Ncust > 1
GROUP BY product
ORDER BY product

-- Prof solution

SELECT product, SUM(amount) as total
FROM sales_exam
GROUP BY product
HAVING COUNT(DISTINCT customer) > 1
ORDER BY product





--2) Product with the highest sale by store

WITH temp AS (
SELECT store, product, SUM(amount) AS TotalSalesByProd,
RANK() OVER (PARTITION BY store ORDER BY SUM(amount) DESC) AS Rank_index
FROM sales_exam se 
GROUP BY store, product
)
SELECT store, product, TotalSalesByProd
FROM temp
WHERE Rank_index = 1
ORDER BY store, product

--Prof solution

WITH tmp AS (
	SELECT store, product,
	  RANK() over(PARTITION BY store ORDER BY SUM(amount) DESC) AS rango
	FROM sales_exam
	GROUP BY store,product
)
SELECT store, product 
FROM tmp
where rango = 1





--3) Number of customers that bought in at least 2 distinct dates, by store

WITH temp AS (
SELECT store, customer, data, COUNT(data) OVER (PARTITION BY customer) NDistData
FROM sales_exam se
GROUP BY store, customer, data
)
SELECT store, COUNT(DISTINCT customer) AS NCust
FROM temp
WHERE NDistData > 1
GROUP BY store
ORDER BY store

-- Prof solution

WITH tmp AS (
	SELECT store, customer, COUNT(DISTINCT data) AS dates
	FROM sales_exam
	GROUP BY store, customer
--	ORDER BY store, customer
)
SELECT store, SUM(CASE WHEN dates > 1 THEN 1 ELSE 0 END) AS ncust
FROM tmp
GROUP BY store

-- Addition query related to the exam
-- Compute the total sales of each customer_id in the first day and in the last day in which the customer_id made a purchase

WITH temp AS (
SELECT customer, data, 
MIN(data) OVER (PARTITION BY customer) AS firstday,
MAX(data) OVER (PARTITION BY customer) AS lastday,
SUM(amount) AS TotSalesByDay
FROM sales_exam se
GROUP BY customer, data
)
SELECT customer, data, TotSalesByDay
FROM temp
WHERE data = firstday OR data = lastday
--GROUP BY customer
ORDER BY customer, data, TotSalesByDay

-- Exercise done during Office Hour 2

-- Total sales by store_country, product_family, quarter

SELECT r.sales_country, pc.product_family, tbd.quarter, SUM(sf.store_sales) AS TotalSales
FROM sales_fact sf, store s, region r, product p, product_class pc, time_by_day tbd 
WHERE sf.store_id = s.store_id AND s.region_id = r.region_id
AND sf.product_id = p.product_id AND p.product_class_id = pc.product_class_id
AND sf.time_id = tbd.time_id
GROUP BY r.sales_country, pc.product_family, tbd.quarter 
ORDER BY r.sales_country, pc.product_family, tbd.quarter

-- Slice of Ex. 1 for the_day = "Monday", and ordered by decreasing total sales

SELECT r.sales_country, pc.product_family, tbd.quarter, SUM(sf.store_sales) AS TotalSales
FROM sales_fact sf, store s, region r, product p, product_class pc, time_by_day tbd 
WHERE sf.store_id = s.store_id AND s.region_id = r.region_id
AND sf.product_id = p.product_id AND p.product_class_id = pc.product_class_id
AND sf.time_id = tbd.time_id
AND tbd.the_day = 'Monday'
GROUP BY r.sales_country, pc.product_family, tbd.quarter 
ORDER BY r.sales_country, pc.product_family, tbd.quarter, TotalSales DESC

-- Ex. 1 plus additional columns: 1. Rank wrt store_country ordered by decreasing total sales
 
SELECT r.sales_country, pc.product_family, tbd.quarter, SUM(sf.store_sales) AS TotalSales,
RANK () OVER (PARTITION BY s.store_country ORDER BY SUM(sf.store_sales) DESC)
FROM sales_fact sf, store s, region r, product p, product_class pc, time_by_day tbd 
WHERE sf.store_id = s.store_id AND s.region_id = r.region_id
AND sf.product_id = p.product_id AND p.product_class_id = pc.product_class_id
AND sf.time_id = tbd.time_id
AND tbd.the_day = 'Monday'
GROUP BY r.sales_country, pc.product_family, tbd.quarter, s.store_country 
ORDER BY r.sales_country, pc.product_family, tbd.quarter, TotalSales DESC

-- Output for every city in USA the difference in total sales between 1998 and 1997.

WITH temp AS (
SELECT c.city, tbd.the_year, SUM(sf.store_sales) AS Total
FROM sales_fact sf, time_by_day tbd, customer c
WHERE sf.time_id = tbd.time_id AND sf.customer_id = c.customer_id AND c.country = 'USA'
AND tbd.the_year IN (1997, 1998)
GROUP BY c.city, tbd.the_year 
),
temp2 AS (
SELECT city, the_year, Total,
LEAD(Total, 1, NULL) OVER (PARTITION BY city ORDER BY the_year) AS NextY
FROM temp
)
SELECT city, Total AS Total_1997, NextY AS Total_1998,
ABS(Total - NextY) AS Diff
FROM temp2
WHERE NextY IS NOT NULL


-- Exam

-- For every store, the difference between the total sales of the product with the highest sales 
-- and the total sales of the product with the smallest sales.

WITH temp AS (
SELECT store, product, SUM(amount) AS TotalSalesPerProduct,
MAX(SUM(amount)) OVER (PARTITION BY product) AS MaxSalesProd,
MIN(SUM(amount)) OVER (PARTITION BY product) AS MinSalesProd
FROM sales_exam se 
GROUP BY store, product
)
SELECT store, product, MaxSalesProd - MinSalesProd AS Diff
FROM temp
ORDER BY store, product


-- For each store, the average number of consecutive days without sales in the store
-- Hint: the function DATEDIFF(day, date1, date2) returns the number of days between date1 and date2

WITH temp AS (
SELECT store, data
FROM sales_exam se 
GROUP BY store, data
),
temp2 AS (
SELECT store, data, 
LEAD(data,1,NULL) OVER (PARTITION BY store ORDER BY data) AS NextD
FROM temp
),
temp3 AS (
SELECT store, data, NextD, DATEDIFF(day, data, NextD) AS Date_diff
--AVG(DATEDIFF(day, data, NextD)) OVER (PARTITION BY store)
FROM temp2
WHERE DATEDIFF(day, data, NextD) > 1
)
SELECT store, AVG(Date_diff) OVER (PARTITION BY store) AS AVG_Diff
FROM temp3
ORDER BY store

-- For each store, the number of customers who spent less than 10% in that store


WITH temp AS (
SELECT store, customer, SUM(amount) AS TotalPerCust
FROM sales_exam se
GROUP BY store, customer
),
temp2 AS (
SELECT store, customer, TotalPerCust,
SUM(TotalPerCust) OVER (PARTITION BY customer) AS TotalSales
FROM temp
)
SELECT store, COUNT(*) AS NCustomers
FROM temp2
WHERE 100*TotalPerCust/TotalSales < 10
GROUP BY store




























