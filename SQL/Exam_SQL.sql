-- 1. List firstname, surname and occupation of customers in Burnaby with a name starting with "M" and finishing with "y"
 
-- Interpreting "name" as "firstname"
SELECT c.fname, c.lname, c.occupation
FROM customer c
WHERE c.city = 'Burnaby' and c.fname LIKE 'M%y'
 


-- 2. List the products bought by only woman customers with a store cost > 2.00
 
-- Referring the word "only" exclusively to "woman customers".
SELECT sf.product_id, p.product_name
FROM customer c join sales_fact sf on c.customer_id = sf.customer_id
join product p on p.product_id = sf.product_id
WHERE c.gender = 'F' and sf.store_cost > 2.00
EXCEPT
SELECT sf.product_id, p.product_name
FROM customer c join sales_fact sf on c.customer_id = sf.customer_id
join product p on p.product_id = sf.product_id
WHERE c.gender = 'M'
 

-- Referring the word "only" to both conditions ("woman customers" and "store_cost > 2.00")
SELECT sf.product_id, p.product_name
FROM customer c join sales_fact sf on c.customer_id = sf.customer_id
join product p on p.product_id = sf.product_id
WHERE c.gender = 'F' and sf.store_cost > 2.00
EXCEPT
SELECT sf.product_id, p.product_name
FROM customer c join sales_fact sf on c.customer_id = sf.customer_id
join product p on p.product_id = sf.product_id
WHERE c.gender = 'M'
EXCEPT
SELECT sf.product_id, p.product_name
FROM customer c join sales_fact sf on c.customer_id = sf.customer_id
join product p on p.product_id = sf.product_id
WHERE sf.store_cost <= 2.00
 
 

-- 3. List of products (ID and name of the product) bought in 1998 and belonging to the brand "Washington" or "Bravo".

SELECT p.product_id, p.product_name
FROM product p join sales_fact sf on p.product_id = sf.product_id
join time_by_day tbd on sf.time_id = tbd.time_id
WHERE tbd.the_year = 1998 and (p.brand_name = 'Washington' or p.brand_name = 'Bravo')
 
 

-- 4. List the products bought only in 1998

SELECT sf.product_id
FROM sales_fact sf join time_by_day tbd on sf.time_id = tbd.time_id
WHERE tbd.the_year = 1998
EXCEPT
SELECT sf.product_id
FROM sales_fact sf join time_by_day tbd on sf.time_id = tbd.time_id
WHERE tbd.the_year <> 1998
 
 
 
-- 5. List the products (indicating the code and the name) bought with the promotion "Price Winners"
--    and that in 1997 have been bought at least once with store sales > 15.00, while in 1998 with store sales > 10.00.
 
-- We want to return all products that have been bought in 1997 at least once with store sales > 15.00 with promotion "Price Winners"
-- AND that have been also bought in 1998 at least once with store sales > 10.00 with the same promotion
SELECT p.product_id, p.product_name
FROM product p join sales_fact sf on p.product_id = sf.product_id
join promotion pr on sf.promotion_id = pr.promotion_id
join time_by_day tbd on sf.time_id = tbd.time_id
WHERE tbd.the_year = 1997 AND sf.store_sales > 15.00 AND pr.promotion_name = 'Price Winners'
INTERSECT
SELECT p.product_id, p.product_name
FROM product p join sales_fact sf on p.product_id = sf.product_id
join promotion pr on sf.promotion_id = pr.promotion_id
join time_by_day tbd on sf.time_id = tbd.time_id
WHERE tbd.the_year = 1998 AND sf.store_sales > 10.00 AND pr.promotion_name = 'Price Winners'
 

 
-- 6. List customers (indicating the firstname, surname, and number of children) who bought products of the category
--    "Fruit" in January 1997 or "Seafood" in January 1998.  
 
SELECT DISTINCT c.fname, c.lname, c.total_children
FROM customer c join sales_fact sf on c.customer_id = sf.customer_id
JOIN product p on p.product_id = sf.product_id
JOIN product_class pc on p.product_class_id = pc.product_class_id
JOIN time_by_day tbd on sf.time_id = tbd.time_id
WHERE ( pc.product_category = 'Fruit' AND tbd.the_month= 'January' AND tbd.the_year = 1997 )
   OR ( pc.product_category = 'Seafood' AND tbd.the_month= 'January' AND tbd.the_year = 1998 )
 
 
   
-- 7. List store cities with at least 100 active customers in September 1998.
 
SELECT DISTINCT s.store_city
FROM customer c join sales_fact sf on c.customer_id = sf.customer_id
join store s on sf.store_id = s.store_id
join time_by_day tbd on sf.time_id = tbd.time_id
WHERE tbd.the_month = 'September' and tbd.the_year = 1998
GROUP BY s.store_city
HAVING COUNT(DISTINCT c.customer_id) >= 100
 

 
-- 8. List for each store country the number of female customers and
--    the number of male customers. Order the result with respect to the store country.
 
SELECT s.store_country, c.gender, COUNT(DISTINCT c.customer_id) as count_customers
FROM customer c join sales_fact sf on c.customer_id = sf.customer_id
join store s on sf.store_id = s.store_id
GROUP BY c.gender, s.store_country
ORDER BY s.store_country
 

 
-- 9. For each month provide the number of distinct customers who bought at least 10 distinct product categories
 
with customer_month_category as (
SELECT sf.customer_id, tbd.the_month, pc.product_category
FROM sales_fact sf JOIN product p ON sf.product_id = p.product_id
JOIN product_class pc ON p.product_class_id = pc.product_class_id
JOIN time_by_day tbd ON sf.time_id = tbd.time_id
),
customer_month_category_count as (
SELECT customer_id, the_month, COUNT(DISTINCT product_category) as category_count
FROM customer_month_category
GROUP BY customer_id, the_month
HAVING COUNT(DISTINCT product_category) >= 10
)
SELECT the_month, COUNT(DISTINCT customer_id) as num_customers
FROM customer_month_category_count
GROUP BY the_month
 
 

-- 10. Given the year 1998, provide for each store and month the average gain with respect
--     to the number of customers and the ratio of that value with respect to yearly gain of that store.
--     Thus, assuming that the average gain with respect to the number of customers of a store is the number
--     K and that the yearly gain of that store is T, then the ratio is K/T.
 
with sales_per_month as (
SELECT tbd.the_month, sf.store_id, SUM((sf.store_sales - sf.store_cost) * 1.0) as gain_per_month
FROM time_by_day tbd join sales_fact sf on tbd.time_id = sf.time_id
WHERE tbd.the_year = 1998
GROUP BY tbd.the_month, sf.store_id
),
y_g as (
SELECT spm.store_id, SUM(spm.gain_per_month) as yearly_gain
FROM sales_per_month spm
GROUP BY spm.store_id
)
SELECT tbd.the_month, sf.store_id, SUM((sf.store_sales - sf.store_cost) * 1.0) / COUNT(DISTINCT sf.customer_id) as gain_per_cust_K,
y_g.yearly_gain as yearly_gain_T,
SUM((sf.store_sales - sf.store_cost) * 1.0) / COUNT(DISTINCT sf.customer_id) / y_g.yearly_gain as ratio_K_over_T
FROM time_by_day tbd join sales_fact sf on tbd.time_id = sf.time_id
join y_g on y_g.store_id = sf.store_id
WHERE tbd.the_year = 1998
GROUP BY tbd.the_month, sf.store_id, y_g.yearly_gain
ORDER BY sf.store_id, tbd.the_month -- Not required. Added only for readability of the output