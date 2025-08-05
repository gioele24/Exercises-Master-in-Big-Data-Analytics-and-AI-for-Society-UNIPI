-- 1. List Italian customers with age greater then 50

SELECT *
FROM USERS u 
WHERE u.NATIONALITY = 'italiana' AND year(GETDATE()) - u.YEAR_OF_BIRTH > 50
-- there is the function year(date) -> year
-- Ex. year(2020/09/25) -> 2020
-- another function is GETDATE() which gives the current date
-- so we can write year(GETDATE())

-- 2. List customers from Livorno who have written a review 

SELECT u.ID, u.SURNAME, u.NAME, r.TEXT 
FROM USERS u join REVIEWS r on u.ID = r.USER_REVIEW 
WHERE u.CITY = 'Livorno'

-- 3. List customers who have written a review on a product of the category "Elettrodomestici" 
 
SELECT DISTINCT u.ID, u.SURNAME, u.NAME 
from USERS u join REVIEWS r on u.ID = r.USER_REVIEW 
			 join PRODUCTS p on r.PRODUCT = p.ID 
WHERE p.CATEGORY = 'elettrodomestici'

-- 4. List customers from Messina who have written at least a review with rate equal to 5 
-- Notice the 'at least' word. This means that it can be done
-- without using sets

SELECT DISTINCT u.ID, u.SURNAME, u.NAME 
from USERS u join REVIEWS r on u.ID = r.USER_REVIEW 
WHERE u.CITY = 'Messina' and r.RATE = 5

-- 5. List of products with only reviews with rate less than 3 

-- i.e. all the reviews for a given product have to have a rate less then 3.
-- Watch out when in the text of an exercise there is the word 'only'.
-- Generally this means that a set operation has to be done!

SELECT p.*
FROM PRODUCTS p join REVIEWS r on p.ID = r.PRODUCT 
WHERE r.RATE < 3
EXCEPT 
SELECT p.*
FROM PRODUCTS p join REVIEWS r on p.ID = r.PRODUCT 
WHERE r.RATE >= 3

-- or analogously

SELECT DISTINCT p.* -- In the 'except' case repetition are automatically removed
FROM PRODUCTS p join REVIEWS r on p.ID = r.PRODUCT 
WHERE r.RATE < 3 and p.ID not in (
SELECT r.PRODUCT 
from REVIEWS r
where r.RATE >= 3
)
-- order by p.id, p.DESCRIPTION -> use it to see if there are repetition 

-- 6. List products with a price less than 100 euro and with reviews written only by customers from France 
-- Watch out when in the text of the exercise there is the word 'only'.
-- Generally this means that a set operation has to be done!
SELECT p.*
FROM PRODUCTS p join REVIEWS r on p.ID = r.PRODUCT 
				join USERS u on r.USER_REVIEW = u.ID 
WHERE p.PRICE < 100 and u.NATIONALITY = 'francese'
EXCEPT 
SELECT p.*
FROM PRODUCTS p join REVIEWS r on p.ID = r.PRODUCT 
				join USERS u on r.USER_REVIEW = u.ID 
WHERE u.NATIONALITY <> 'francese' -- In SQL '<>' stands for '!='

-- 7. List products with category containing the char 't' or the char 'c' and with price > than 25 euro

SELECT *
FROM PRODUCTS p 
WHERE (p.CATEGORY LIKE '%t%' or p.CATEGORY LIKE '%c%') and p.PRICE > 25

-- 8. List Products with price less than 20 euro 

SELECT *
FROM PRODUCTS p 
WHERE p.PRICE < 20

-- 9. List products with category 'Alimentare' with a price between 5 and 10 euro

SELECT *
FROM PRODUCTS p 
WHERE p.CATEGORY = 'Alimentare' and p.PRICE >= 5 and p.PRICE <= 10




-- Exercises done during lesson

-- the total sales

SELECT sum(pr.PRICE) as total_sale
from PRODUCTS pr join PURCHASES pu on pr.ID = pu.PRODUCT 

-- for each product the total sales
-- Every time 'for each' is used then a 'group by' operation is needed

SELECT pr.ID, pr.DESCRIPTION, sum(pr.PRICE) as total_sale
from PRODUCTS pr join PURCHASES pu on pr.ID = pu.PRODUCT
GROUP BY pr.ID, pr.DESCRIPTION 

-- for each customer (id) its average amount of purchases and the number of them

SELECT pu.USER_PURCH, AVG(pr.PRICE), COUNT(*) as n_purchase
-- count(distinct pr.id) -> doesn't count the purchase of more copies of the same product 
FROM PURCHASES pu 
join PRODUCTS pr on pu.PRODUCT = pr.ID 
group by pu.USER_PURCH 

-- return the number of products sold per gender

SELECT u.GENDER, count(*) as num_product
FROM USERS u 
join PURCHASES p on u.ID = p.USER_PURCH 
GROUP by u.GENDER

-- return the number of product per nationality
-- only in case a nationality has more than 900
-- purchased products

SELECT u.NATIONALITY, count(*) as num_product
FROM USERS u 
join PURCHASES p on u.ID = p.USER_PURCH 
GROUP by u.NATIONALITY 
HAVING COUNT(*) > 900
ORDER BY num_product DESC 

-- return the number of product per nationality
-- only in case a nationality of female
-- customers has more than 300 purchased products

SELECT u.NATIONALITY, count(*) as num_product
FROM USERS u 
join PURCHASES p on u.ID = p.USER_PURCH 
WHERE u.GENDER = 'F'
GROUP by u.NATIONALITY 
HAVING COUNT(*) > 300 

-- return for each product the number of male
-- customers 

SELECT p.PRODUCT, pr.DESCRIPTION, count(distinct u.id) as num_of_male_customer
FROM USERS u 
join PURCHASES p on u.ID = p.USER_PURCH
join PRODUCTS pr on p.PRODUCT = pr.ID -- not necessary (only to have more info on the purchased product)
WHERE u.GENDER = 'M'
GROUP BY p.PRODUCT, pr.DESCRIPTION

-- Return the total amount spent for each product with category
-- 'arte' with a total number of purchases greater than 2
-- and a total amount spent for the product more than 20

-- for long requests solve the query step by step

SELECT pr.id, pr.DESCRIPTION, sum(pr.PRICE) as total_amount, COUNT(*) as num_purchases 
FROM PRODUCTS pr join PURCHASES pu on pu.PRODUCT = pr.ID
WHERE pr.CATEGORY = 'arte'
GROUP BY pr.ID, pr.DESCRIPTION 
HAVING COUNT(*) > 2 and sum(pr.PRICE) > 20 

-- For each nationality return the ratio of customers who
-- wrote a review on products with description containing the string 'ag'

-- ratio = NCustomer_with_review_ag/NCustomer_with_review
-- ratio1 = NCustomer_with_review_ag/NCustomer
-- tables : review, user, products

-- write only one 'with' and then concatenate the views with commas 
with Customers_Reviews_AG as (
SELECT u.nationality, count(distinct r.user_review) as NCustomer_with_review_ag
from Users u
join Reviews r on u.ID = r.user_review
join Products pr on r.product = pr.ID
where pr.description LIKE '%ag%' -- removing this condition we obtain the NCustomer_with_review. We need another query to adress both things
GROUP by u.nationality
),
Customers_Reviews as (
SELECT u.nationality, count(distinct r.user_review) as NCustomer_with_review
from Users u
join Reviews r on u.ID = r.user_review
join Products pr on r.product = pr.ID
GROUP by u.nationality
)
SELECT crag.nationality, crag.NCustomer_with_review_ag,
cr.NCustomer_with_review, crag.NCustomer_with_review_ag*1.0/cr.NCustomer_with_review
from Customers_Reviews_AG crag join Customers_Reviews cr on
cr.nationality = crag.nationality

-- you can't execute a view singularly (it gives an error)
-- You either execute only what is between parantheses or
-- you complete the query (that uses the views) and execute 
-- the entire block

-- count(*) = count(r.USER_REVIEW) is the same if there are no null values

-- including also ratio1

with Customers_Reviews_AG as (
SELECT u.nationality, count(distinct r.user_review) as NCustomer_with_review_ag
from Users u
join Reviews r on u.ID = r.user_review
join Products pr on r.product = pr.ID
where pr.description LIKE '%ag%' -- removing this condition we obtain the NCustomer_with_review. We need another query to adress both thing
GROUP by u.nationality
),
Customers_Reviews as (
SELECT u.nationality, count(distinct r.user_review) as NCustomer_with_review
from Users u
join Reviews r on u.ID = r.user_review
join Products pr on r.product = pr.ID
GROUP by u.nationality
),
Customers as (
SELECT u.nationality, count(*) as NCustomer -- In Users all customers are different (so we only put count(*))
from Users u
GROUP by u.nationality
)
SELECT crag.nationality, crag.NCustomer_with_review_ag,
cr.NCustomer_with_review, c.NCustomer, crag.NCustomer_with_review_ag*1.0/cr.NCustomer_with_review,
crag.NCustomer_with_review_ag*1.0/c.NCustomer
from Customers_Reviews_AG crag join Customers_Reviews cr on
cr.nationality = crag.nationality join Customers c on
cr.nationality = c.nationality


-- query in groups

-- for each client who bought at least 10 (distinct)
-- products, return the average amount spent by that client


SELECT u.ID, u.name, u.surname, COUNT(p.product) as Counts, AVG(pr.price) as AVG
FROM Users u join Purchases p on u.ID = p.USER_PURCH
join Products pr on p.PRODUCT = pr.ID
GROUP BY u.ID, u.name, u.surname
having count(distinct p.PRODUCT) >= 10


-- for each female customer return the max amount spent
-- for each product category

SELECT u.id, p.category, max(p.price) as max_price
FROM Users u join purchases pu on pu.USER_PURCH = u.ID
join products p on pu.product = p.ID
where u.GENDER = 'F'
group by u.id, p.category


-- for each nationality provide the total female
-- and male customers who made at least a purchase.
-- Then, compute the difference between females and males

with female_customers as (
SELECT u.nationality, count(distinct p.USER_PURCH) as f_count
FROM Users u join purchases p on u.ID = p.USER_PURCH
WHERE u.GENDER = 'F'
GROUP BY u.NATIONALITY
--HAVING count(p.product) >= 1 -> This is not necessary since it's always satisfied
),
male_customers as (
SELECT u.nationality, count(distinct p.USER_PURCH) as m_count
FROM Users u join purchases p on u.ID = p.USER_PURCH
WHERE u.GENDER = 'M'
GROUP BY u.NATIONALITY
--HAVING count(p.product) >= 1 -> This is not necessary since it's always satisfied
)
SELECT fc.nationality, f_count, m_count, abs(f_count-m_count) as diff
FROM female_customers fc join male_customers mc on fc.nationality = mc.nationality

-- For each gender, return the total number of reviews,
-- the total number of purchases and the average rate of reviews
 
SELECT u.GENDER, COUNT(distinct r.ID) as tot_reviews, COUNT(distinct p.id) as tot_purchases,
AVG(r.RATE) as avg_rate_review
FROM PURCHASES p join USERS u on p.USER_PURCH = u.ID
join REVIEWS r on u.ID = r.USER_REVIEW
GROUP BY u.GENDER
-- Instead of COUNT(p.USER_PURCH) we could simply put COUNT(*)

-- Correct solution to address all problems
-- For each gender, return the total number of reviews,
-- the total number of purchases and the average rate of reviews

with review_info as (
SELECT u.gender, COUNT(*) as Nreviews, avg(r.rate) as avg_rate
from USERS u join REVIEWS r on u.ID = r.USER_REVIEW 
group by u.gender
),
purch_info as (
SELECT u.gender, COUNT(*) as Npurch
from USERS u join PURCHASES p on u.ID = p.user_purch
group by u.gender
)
SELECT r.*, Npurch
from review_info r join purch_info p on p.gender = r.gender


-- For each product category return the average rate got each month
 
SELECT p.CATEGORY, month(r.DATE_REVIEW) as month, AVG(r.rate) as avg_rate
FROM PRODUCTS p JOIN REVIEWS r on p.ID = r.PRODUCT
GROUP BY p.CATEGORY, month(r.DATE_REVIEW)
order by p.category, month(r.DATE_REVIEW)

-- For each month provide the percentage of products rated more than 3
-- from females with respect to all products rated

use MARKET_EN

with nproduct_3 as (
SELECT month(r.DATE_REVIEW) as month, count(r.product) as prod_rate_gt3
FROM Users u join REVIEWS r on u.ID = r.USER_REVIEW
where u.GENDER = 'F' and r.RATE > 3
GROUP BY month(r.DATE_REVIEW)
),
nproducts as (
SELECT month(r.DATE_REVIEW) as month, count(r.product) as tot_num_prod
FROM Users u join REVIEWS r on u.ID = r.USER_REVIEW
GROUP BY month(r.DATE_REVIEW)
)
SELECT np.month as month, np3.prod_rate_gt3*1.0/np.tot_num_prod as percentage
FROM nproducts np join nproduct_3 np3 on np.month = np3.month 


-- Return the best seller product with respect to
--customers from Livorno, given that it is never bought
--from customers from Napoli

with product_count as ( 
SELECT p.PRODUCT as product , count(p.PRODUCT) as p_count
FROM USERS u join PURCHASES p on u.ID = p.USER_PURCH
WHERE u.CITY = 'Livorno' AND p.PRODUCT NOT IN (
SELECT p.PRODUCT 
FROM USERS u join PURCHASES p on u.ID = p.USER_PURCH
WHERE u.CITY = 'Napoli'
)
group by p.PRODUCT 
)
SELECT pr.*, pc.p_count
FROM product_count pc join PRODUCTS pr on pc.product = pr.ID
where pc.p_count = (SELECT max(p_count) FROM product_count)


-- List the number of sales for each day of the week

SELECT DATENAME(weekday, p.DATE_PURCH) as week_day, COUNT(*) as sales_number
FROM PURCHASES p
group by DATEPART(weekday, p.DATE_PURCH), DATENAME(weekday, p.DATE_PURCH) 
order by DATEPART(weekday, p.DATE_PURCH)