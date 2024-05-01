# Data-Driven Revitalization: Transforming 'New-Wheels' Sales and Customer Satisfaction
##  Data Analytics with SQL
## Overview
  This project is aimed at revitalizing New-Wheels sales and enhancing customer satisfaction through advanced data analytics techniques. In the face of declining sales and increasing customer concerns, the project focuses on scrutinizing essential feedback and sales data to provide crucial insights for informed decision-making by the CEO. Through the exploration of customer sentiments and market dynamics, WheelsRevive aims to redefine New Wheels within the competitive vehicle resale landscape.
## Objectives:
1. Utilize SQL and MYSQL for data analysis.
2. Employ Joins, Sub Queries, Analytical Functions, Group by clause, and Derived Class for in-depth data exploration.
3. Provide actionable insights to facilitate well-informed decision-making for business revival.
4. Address complex business challenges through problem-solving approaches.

### Step 1:  SQL queries you run will operate on tables and data within the "new_wheels" database
> USE new_wheels;
### [Q1] What is the distribution of customers across states?

 QUERY LOGIC: 
> 1. Selects the 'state' column and counts the occurrences of each state in the 'customer_t' table,
> 2. grouping the results by state and ordering them by the count in ascending order.

<img width="762" alt="Q1" src="https://github.com/Swetha-Reddy-Thumma/Power-BI-Projects/assets/168033156/6e2ffd18-8c61-4f39-8d72-b8f55d43230a"> 

###  [Q2] What is the average rating in each quarter?
> Very Bad is 1, Bad is 2, Okay is 3, Good is 4, Very Good is 5.

QUERY LOGIC:
> 1. By using CTE(common table expression), Selects the quarter_number and customer_feedback columns, converting the qualitative feedback into numerical values using a CASE statement.
> 2. Then, groups the results by quarter, calculating the rounded average of the numerical conversion.

<img width="310" alt="Q2" src="https://github.com/Swetha-Reddy-Thumma/Power-BI-Projects/assets/168033156/907e6467-78ff-44b0-aaa2-ed3628ca0d34">

### [Q3] Are customers getting more dissatisfied over time?
QUERY LOGIC:
> 1. Selects distinct quarter_number, customer_feedback, and utilizes COUNT() with window functions to calculate the number of orders for each feedback category (CATEGORY_ORDERS)
> 2.  and the total orders for each quarter (QUART_ORDERS). Then, computes the percentage of orders for each feedback category relative to the total orders for the quarter.

<img width="403" alt="Q3" src="https://github.com/Swetha-Reddy-Thumma/Power-BI-Projects/assets/168033156/ca391c73-7a30-4407-82cf-dc2f9471a4a6">

### [Q4] Which are the top 5 vehicle makers preferred by the customer.
 QUERY LOGIC:
> 1. Selects the 'vehicle_maker' column from the 'product_t' table and counts the number of distinct 'customer_id' values for each vehicle maker.
> 2. Uses a RIGHT JOIN with the 'order_t' table to link products and orders. Groups the results by 'vehicle_maker',
> 3. orders them by the total customers in descending order, and limits the output to the top 5 vehicle makers.

<img width="360" alt="Q4" src="https://github.com/Swetha-Reddy-Thumma/Power-BI-Projects/assets/168033156/1a7ad7cb-3d74-46d1-9c85-1b45bf630aad">

### [Q5] What is the most preferred vehicle make in each state?
 QUERY LOGIC:
> 1. Creates a Common Table Expression (CTE) named ALL_VALUES, which counts the total customers for each combination of vehicle maker and state. 
> 2. Utilizes LEFT JOINs to link orders, products, and customers. Then, defines another CTE named RANKING_STATES, which calculates the ranking of each vehicle maker within each state based on the total customers.
> 3. Finally, selects the state, the top vehicle maker in each state (NO.1_VEHICLE_MAKER), total buyers for that vehicle maker (TOTAL_BUYERS), and the ranking.
> 4. Filters the results to only include the top-ranked vehicle maker in each state.

<img width="370" alt="Q5" src="https://github.com/Swetha-Reddy-Thumma/Power-BI-Projects/assets/168033156/097d940f-a707-4537-aece-95f71e3b1130"> 

### QUESTIONS RELATED TO REVENUE and ORDERS 
### [Q6] What is the trend of number of orders by quarters?
 QUERY LOGIC:
> 1. Selects the quarter_number and counts the number of orders for each quarter from the 'order_t' table.
> 2. Uses the CONCAT function to format the quarter number as "Q X". Groups the results by the formatted quarter and orders them based on the chronological order of quarters.

<img width="387" alt="Q6" src="https://github.com/Swetha-Reddy-Thumma/Power-BI-Projects/assets/168033156/c5c8b2c4-9a3c-4694-a626-6537e6a5b939">

### [Q7] What is the quarter over quarter % change in revenue? 
 QUERY LOGIC:
> 1. Creates a Common Table Expression (CTE) named SUM_REVENUE, which calculates the total revenue for each quarter by multiplying 'vehicle_price' with 'quantity' and then summing the result.
> 2. Formats the quarter number as "Q X". Then, selects the formatted quarter, revenue, previous revenue (using LAG function), and computes the quarter-over-quarter percentage change in revenue.
> 3. The percentage change is rounded to two decimal places.

<img width="498" alt="Q7" src="https://github.com/Swetha-Reddy-Thumma/Power-BI-Projects/assets/168033156/200c6dd6-301c-41f2-99f8-8f7f1fe5d60a">

### [Q8] What is the trend of revenue and orders by quarters?
 QUERY LOGIC:
> 1. Selects the formatted quarter, calculates the total revenue by multiplying 'vehicle_price' with 'quantity' and summing the result,
-- and counts the total number of orders for each quarter from the 'order_t' table.
> 2. Formats the quarter number as "Q X" and groups the results by the formatted quarter, providing insights into revenue and total orders by quarter.

<img width="277" alt="Q8" src="https://github.com/Swetha-Reddy-Thumma/Power-BI-Projects/assets/168033156/642fa9c3-ad5f-4b7d-98ef-62f74946679e">

### QUESTIONS RELATED TO SHIPPING 
### [Q9] What is the average discount offered for different types of credit cards?
QUERY LOGIC:
> 1. Selects the credit card type (converted to uppercase using UPPER function) from the 'customer_t' table and
> 2. calculates the rounded average discount from the 'order_t' table, using a LEFT JOIN to link orders and customers. Groups the results by credit card type.

<img width="334" alt="Q9" src="https://github.com/Swetha-Reddy-Thumma/Power-BI-Projects/assets/168033156/6d94d2f8-696e-48fd-a285-68837088d070">

### [Q10] What is the average time taken to ship the placed orders for each quarters?
QUERY LOGIC:
> 1. Selects the formatted quarter and calculates the average order processing time in days using the DATEDIFF function
> 2. to find the difference between 'ship_date' and 'order_date'. Formats the result as "X DAYS". Groups the results by the formatted quarter.

<img width="432" alt="Q10" src="https://github.com/Swetha-Reddy-Thumma/Power-BI-Projects/assets/168033156/9a3ee51e-7754-40bf-b014-11f2274b54f5">



