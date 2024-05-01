 

 /*  SQL queries you run will operate on tables and data within the "new_wheels" database  */
 
 
  USE new_wheels;
  
/*-- QUESTIONS RELATED TO CUSTOMERS
     [Q1] What is the distribution of customers across states?
     Hint: For each state, count the number of customers.*/

SELECT 
	state,
	COUNT(customer_id) AS CUSTOMERS
FROM customer_t
 GROUP BY 1
 ORDER BY 2 DESC;

-- QUERY LOGIC: 
-- Selects the 'state' column and counts the occurrences of each state in the 'customer_t' table, 
-- grouping the results by state and ordering them by the count in ascending order.

-- ---------------------------------------------------------------------------------------------------------------------------------

/* [Q2] What is the average rating in each quarter?
-- Very Bad is 1, Bad is 2, Okay is 3, Good is 4, Very Good is 5.

Hint: Use a common table expression and in that CTE, assign numbers to the different customer ratings. 
      Now average the feedback for each quarter. 

Note: For reference, refer to question number 4. Week-2: mls_week-2_gl-beats_solution-1.sql. 
      You'll get an overview of how to use common table expressions from this question.*/

WITH QUATER_FEEDBACK AS (
SELECT 
	quarter_number,
	customer_feedback,
		CASE
			WHEN customer_feedback = 'Very Bad' THEN 1
			WHEN customer_feedback = 'Bad' THEN 2
			WHEN customer_feedback = 'Okay' THEN 3
			WHEN customer_feedback = 'Good' THEN 4
			WHEN customer_feedback = 'Very Good' THEN 5
			END AS RATING    
FROM order_t) 
SELECT 
	CONCAT("Q " , quarter_number) AS QUATER,
	ROUND(AVG(RATING), 2) AS AVG_RATING
 FROM QUATER_FEEDBACK
GROUP BY 1
ORDER BY 1;

-- QUERY LOGIC:
-- By using CTE(common table expression), Selects the quarter_number and customer_feedback columns, converting the qualitative feedback into numerical values using a CASE statement. 
-- Then, groups the results by quarter, calculating the rounded average of the numerical conversion.


-- ---------------------------------------------------------------------------------------------------------------------------------

/* [Q3] Are customers getting more dissatisfied over time?

Hint: Need the percentage of different types of customer feedback in each quarter. Use a common table expression and
	  determine the number of customer feedback in each category as well as the total number of customer feedback in each quarter.
	  Now use that common table expression to find out the percentage of different types of customer feedback in each quarter.
      Eg: (total number of very good feedback/total customer feedback)* 100 gives you the percentage of very good feedback.
      
Note: For reference, refer to question number 4. Week-2: mls_week-2_gl-beats_solution-1.sql. 
      You'll get an overview of how to use common table expressions from this question.*/
      
WITH quarter_feedback AS 
(
    SELECT 
        DISTINCT quarter_number,
        customer_feedback,
        COUNT(order_id) OVER (PARTITION BY quarter_number, customer_feedback) AS CATEGORY_ORDERS,
        COUNT(order_id) OVER (PARTITION BY quarter_number) AS QUART_ORDERS
	FROM order_t
)

SELECT
	CONCAT("Q " , quarter_number) AS QUATER,
    customer_feedback,
    CATEGORY_ORDERS,
    QUART_ORDERS,
    ROUND(CATEGORY_ORDERS*100/QUART_ORDERS , 2) AS '% RATING'
FROM quarter_feedback;
    
-- QUERY LOGIC:
-- Selects distinct quarter_number, customer_feedback, and utilizes COUNT() with window functions to calculate the number of orders for each feedback category (CATEGORY_ORDERS) 
-- and the total orders for each quarter (QUART_ORDERS). Then, computes the percentage of orders for each feedback category relative to the total orders for the quarter.


-- ---------------------------------------------------------------------------------------------------------------------------------

/*[Q4] Which are the top 5 vehicle makers preferred by the customer.

Hint: For each vehicle make what is the count of the customers.*/

SELECT 
	vehicle_maker,
    COUNT(customer_id) AS TOTAL_CUSTOMERS
FROM product_t AS P RIGHT JOIN order_t AS O ON P.product_id = O.product_id
GROUP BY 1
ORDER BY 2 DESC
LIMIT 5;

-- QUERY LOGIC:
-- Selects the 'vehicle_maker' column from the 'product_t' table and counts the number of distinct 'customer_id' values for each vehicle maker.
--  Uses a RIGHT JOIN with the 'order_t' table to link products and orders. Groups the results by 'vehicle_maker', 
-- orders them by the total customers in descending order, and limits the output to the top 5 vehicle makers.

-- ---------------------------------------------------------------------------------------------------------------------------------

/*[Q5] What is the most preferred vehicle make in each state?

Hint: Use the window function RANK() to rank based on the count of customers for each state and vehicle maker. 
After ranking, take the vehicle maker whose rank is 1.*/

WITH ALL_VALUES AS
(
SELECT 
	P.vehicle_maker,
    C.state,
    COUNT(O.customer_id) AS TOTAL_CUSTOMERS
      FROM ORDER_T AS O LEFT JOIN PRODUCT_T AS p ON O.PRODUCT_ID = P.PRODUCT_ID
                        left join CUSTOMER_T AS C ON O.CUSTOMER_ID = C.CUSTOMER_ID
GROUP BY 1,2
ORDER BY 2 DESC
),
 RANKING_STATES AS
 (
SELECT
	vehicle_maker,
    state,
    TOTAL_CUSTOMERS,
    RANK() OVER(PARTITION BY state ORDER BY TOTAL_CUSTOMERS DESC) AS RANKING
FROM ALL_VALUES
 )
SELECT 
	state,
	vehicle_maker AS 'NO.1_VEHICLE_MAKER',
    TOTAL_CUSTOMERS AS 'TOTAL_BUYERS',
    RANKING 
FROM RANKING_STATES
	WHERE RANKING = 1;

-- QUERY LOGIC:
-- Creates a Common Table Expression (CTE) named ALL_VALUES, which counts the total customers for each combination of vehicle maker and state. 
-- Utilizes LEFT JOINs to link orders, products, and customers. Then, defines another CTE named RANKING_STATES, which calculates the ranking of each vehicle maker within each state based on the total customers.
-- Finally, selects the state, the top vehicle maker in each state (NO.1_VEHICLE_MAKER), total buyers for that vehicle maker (TOTAL_BUYERS), and the ranking. 
-- Filters the results to only include the top-ranked vehicle maker in each state.

-- ---------------------------------------------------------------------------------------------------------------------------------

/*QUESTIONS RELATED TO REVENUE and ORDERS 

-- [Q6] What is the trend of number of orders by quarters?

Hint: Count the number of orders for each quarter.*/
SELECT
	CONCAT("Q " , quarter_number) AS QUATER,
	COUNT(order_id) AS TOTAL_ORDERS
FROM order_t
GROUP BY 1
ORDER BY QUATER;

-- QUERY LOGIC:
-- Selects the quarter_number and counts the number of orders for each quarter from the 'order_t' table.
-- Uses the CONCAT function to format the quarter number as "Q X". Groups the results by the formatted quarter and orders them based on the chronological order of quarters.

-- ---------------------------------------------------------------------------------------------------------------------------------

/* [Q7] What is the quarter over quarter % change in revenue? 

Hint: Quarter over Quarter percentage change in revenue means what is the change in revenue from the subsequent quarter to the previous quarter in percentage.
      To calculate you need to use the common table expression to find out the sum of revenue for each quarter.
      Then use that CTE along with the LAG function to calculate the QoQ percentage change in revenue.
*/
WITH SUM_REVENUE AS
(
SELECT 
	CONCAT("Q " , quarter_number) AS QUATER,
	SUM(vehicle_price * quantity) AS REVENUE
FROM order_t 
 GROUP BY 1
)
SELECT
	 QUATER,
     CONCAT("$ ", REVENUE) AS REVENUE,
	 CONCAT("$" , LAG(REVENUE) OVER (ORDER BY QUATER)) AS PREVIOUS_REVENUE,
     ROUND(((LAG(REVENUE) OVER (ORDER BY QUATER) - REVENUE) / LAG(REVENUE) OVER (ORDER BY QUATER))*100, 2) AS 'QoQ_%' 
FROM SUM_REVENUE;

-- QUERY LOGIC:
-- Creates a Common Table Expression (CTE) named SUM_REVENUE, which calculates the total revenue for each quarter by multiplying 'vehicle_price' with 'quantity' and then summing the result.
-- Formats the quarter number as "Q X". Then, selects the formatted quarter, revenue, previous revenue (using LAG function), and computes the quarter-over-quarter percentage change in revenue. 
-- The percentage change is rounded to two decimal places.

-- ---------------------------------------------------------------------------------------------------------------------------------

/* [Q8] What is the trend of revenue and orders by quarters?

Hint: Find out the sum of revenue and count the number of orders for each quarter.*/

SELECT 
	CONCAT("Q " , quarter_number) AS QUATER,
    SUM(vehicle_price * quantity) AS REVENUE,
    COUNT(order_id) AS TOTAL_ORDERS
FROM order_t
GROUP BY 1
ORDER BY 1;

-- QUERY LOGIC:
-- Selects the formatted quarter, calculates the total revenue by multiplying 'vehicle_price' with 'quantity' and summing the result,
-- and counts the total number of orders for each quarter from the 'order_t' table.
-- Formats the quarter number as "Q X" and groups the results by the formatted quarter, providing insights into revenue and total orders by quarter.

-- ---------------------------------------------------------------------------------------------------------------------------------

/* QUESTIONS RELATED TO SHIPPING 
    [Q9] What is the average discount offered for different types of credit cards?

Hint: Find out the average of discount for each credit card type.*/

SELECT
	UPPER(C.credit_card_type) AS CREDIT_CARD,
    ROUND(AVG(O.discount) , 2) AS AVG_DISCOUNT
FROM order_t AS O LEFT JOIN customer_t AS C ON O.customer_id = C.customer_id
GROUP BY 1
ORDER BY 2 DESC;


-- QUERY LOGIC:
-- Selects the credit card type (converted to uppercase using UPPER function) from the 'customer_t' table and 
-- calculates the rounded average discount from the 'order_t' table, using a LEFT JOIN to link orders and customers. Groups the results by credit card type.

-- ---------------------------------------------------------------------------------------------------------------------------------

/* [Q10] What is the average time taken to ship the placed orders for each quarters?
	Hint: Use the dateiff function to find the difference between the ship date and the order date.
*/
SELECT
	CONCAT("Q " , quarter_number) AS QUATER,
    CONCAT(ROUND(AVG(DATEDIFF(ship_date, order_date))), "   DAYS") AS ORDER_PROCESSING_TIME
FROM order_t
GROUP BY 1
ORDER BY 1;

-- QUERY LOGIC:
-- Selects the formatted quarter and calculates the average order processing time in days using the DATEDIFF function 
-- to find the difference between 'ship_date' and 'order_date'. Formats the result as "X DAYS". Groups the results by the formatted quarter.

-- --------------------------------------------------------Done----------------------------------------------------------------------
-- ----------------------------------------------------------------------------------------------------------------------------------



