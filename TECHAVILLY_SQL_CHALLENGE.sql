/*Using SQL Server, I downloaded the movie data, pizza data I used for questions 1 to 5*/
/* DAY 1-Q1 Using the Movie Data, write a query to show the titles of movies released in 2017 whose vote count is more
than 15 and runtime is more than 100*/
SELECT original_title
FROM [Movies].[dbo].[Movie Data]
WHERE release_date LIKE '%2017%'
AND vote_count > 15
AND runtime > 100;

/* DAY 2 -Q2 - Using the Pizza Data, write a query to show how many Pizzas were ordered.*/

/*As the order_id uniquely identifies each order made, a count of the total order_id
will give us the total pizza orderd*/
SELECT COUNT(order_id) AS Total_Pizza_Ordered
FROM [Pizza Data].[dbo].[customer_orders];

/*DAY 3 -Q3 - Using the Pizza Data, write a query to show how many successful order were delivered by each runner*/

--Each runner can be identified by their runner id so, to get a count of the successful order of each runner, we need
-- a count of all the order_id where cancellation is null.

SELECT runner_id, COUNT(order_id) AS successful_orders
FROM [Pizza Data].[dbo].[runner_orders]
WHERE cancellation IS NULL
GROUP BY runner_id;

/*DAY 4 -Q4 using the movie data, write a query to show the top 10 movie titles whose language is
English and French and the budget is more than 1,000,000.*/


/*DAY 5 -Q5 Using the Pizza Data, write a query to show the number of each type of pizza was delivered*/
/*To answer the question, I need to join a few tables together and then aggregate the results
to get the count of each type of pizza that was delivered. See my approach below:
1. Join customer_orders to pizza_names using the pizza_id column to get the names of the pizzas and join
the runners_orders using the order_id to get the delivered orders.
2. Filter only the delivered orders. I know that in the runner_orders table orders are delivered 
when they do not have a cancellation so I can use that as my criteria.
3. Group by the pizza name and count the number of times each pizza appears in the result set.
Below is the SQL query to get the desired result*/
SELECT 
    pn.pizza_name,
    COUNT(co.order_id) as Number_of_Pizzas_Delivered
FROM  
    [Pizza Data].[dbo].[customer_orders] co
JOIN 
    [Pizza Data].[dbo].[pizza_names] pn ON co.pizza_id = pn.pizza_id
JOIN 
    [Pizza Data].[dbo].[runner_orders] ro ON co.order_id = ro.order_id
WHERE 
     ro.cancellation IS NULL
GROUP BY 
    pn.Pizza_name;

/* I used PostgreSQL to answer the remaining questions. I created the tables orders, people, returns_,
employee, share_price tables and imported the datasets*/

CREATE TABLE orders(
	Row_ID INT, 
	Order_ID VARCHAR(50),
	Order_Date DATE,
	Ship_Date DATE,
	Ship_Mode VARCHAR(50),
	Customer_ID VARCHAR(50),
	Customer_Name VARCHAR(50),
	Segment VARCHAR(50),
	Country VARCHAR(100),
	City VARCHAR(100),
	State_ VARCHAR(100),
	Postal_Code INT,
	Region VARCHAR(20),
	Product_ID VARCHAR(50),
	Category VARCHAR(50),
	Sub_Category VARCHAR(50),
	Product_Name VARCHAR(150),
	Sales NUMERIC,
	Quantity INT,
	Discount NUMERIC,
	Profit NUMERIC
);
CREATE TABLE people(
	Person VARCHAR(50),
	Region VARCHAR(20)
);
CREATE TABLE returns_(
	Returned VARCHAR(10),
	Order_ID VARCHAR(30)
);
/* DAY 6 -BONUS QUESTION 1
The Briggs Company wants to ship some of their products to customers in selected cities
but they want to know the average days it'll take to deliver those items to Dallas,
Los Angeles, Seattle and Madison. Using the Sample Superstore Data, write a query to show
the average delivery to those cities. Only show the city and Average delivery days columns
in your output*/

SELECT city, ROUND(AVG(ship_date - order_date)::numeric,2) AS average_delivery_days
FROM orders
WHERE city IN ('Dallas', 'Los Angeles', 'Seattle', 'Madison' )
GROUP BY city;

/*DAY 9 -Q6 - It's getting to the end of the year, and the Briggs Company
wants to reward the customer who made the highest sales ever.Using the 
sample superstore, write a query to help the company identify this customer
and the category of business driving the sales. Let your output show the 
customer name, category and total sales. Round the total sales to the 
nearest whole number*/
SELECT customer_name, category, CEIL(MAX(sales)) AS total_sales
FROM orders
GROUP BY customer_name, category
ORDER BY total_sales DESC
LIMIT 1;
_OR_
WITH CustomerCategorySales AS (
    SELECT 
        customer_name, 
        category, 
        SUM(sales) AS total_sales
    FROM orders
    GROUP BY customer_name, category
)

SELECT 
    customer_name,
    category,
    total_sales
FROM CustomerCategorySales
ORDER BY total_sales DESC
LIMIT 1;

/*DAY 10- Q7 The briggs company has 3 categories of business generating revenue 
for the company. They want to know which one of them is driving the business.
Write a query to show the total sales and percentage contribution by each 
category. Show category, total sales and percentage contribution columns in
your output*/

SELECT 
    category, 
    SUM(sales) as total_sales,
    ROUND(
        (SUM(sales) / (SELECT SUM(sales) FROM orders) * 100)::numeric,
        2
    ) as percentage_contribution
FROM orders
GROUP BY category
ORDER BY percentage_contribution DESC;

_OR_

WITH CategorySales AS (
    SELECT 
        category,
        SUM(sales) as category_sales
    FROM orders
    GROUP BY category
),

TotalSales AS (
    SELECT SUM(sales) as overall_sales
    FROM orders
)

SELECT 
    cs.category,
    cs.category_sales,
    ROUND(
        (cs.category_sales / ts.overall_sales * 100)::numeric,
        2
    ) as percentage_contribution
FROM CategorySales cs
CROSS JOIN TotalSales ts
ORDER BY percentage_contribution DESC;

/*DAY 11 -Q8 - After seeing the sales by category, the Briggs company became curious
and wanted to dig deeper to see which sub-category is selling the most. They
need the help of an analyst. Please help the company to write a query to show
the sub category and the total sales of each sub category. Let your query 
display only the subcategory and the total sales columns to see which 
product sells the most*/
SELECT sub_category, CEIL(SUM(sales)::numeric) AS total_sales
FROM orders
GROUP BY sub_category
ORDER BY total_sales DESC;

/*DAY 12-Q9 - Now that you have identified phones as the business driver 
in terms of revenue. The company wants to know the total phone sales by
year to understand how each year performed. As the Analyst, please help them to
show the breakdown of the total sales by year in decending order. Let your
output show only Total Sales and Sales by year column*/
SELECT EXTRACT(YEAR FROM order_date) AS sales_by_year,
	CEIL(SUM(sales)::numeric) AS total_sales
FROM orders
WHERE sub_category = 'Phones'
GROUP BY sales_by_year
ORDER BY total_sales DESC;

/*DAY 13-Q10 The Director of Analytics has requested a detailed analysis of the Briggs 
Company. To fulfill this request, he needs you to generate a table that 
displays the profit margin of each segment. The table should include the
segments, total sales, total profit, and the profit margin. To ensure
accuracy, the profit margin should be arranged in descending order*/
SELECT segment, ROUND(SUM(sales)::numeric,2) AS total_sales,
	ROUND(SUM(profit)::numeric,2) AS total_profit,
	ROUND((SUM(profit) / SUM(sales) * 100)::numeric,2) AS profit_margin
FROM orders
GROUP BY segment
ORDER BY profit_margin DESC;

/*DAY 14 -BONUS QUESTION 2
As we conclude the analysis for the Briggs Company, they got some reviews
on their website regarding their new product. Please use the bonus table
to write a query that returns only the meaningful reviews. These are reviews
that are readable in english. There are two columns in the table, let your
output return only the review column.*/
SELECT review
FROM bonus_table
WHERE translation_ IS NULL;

/*DAY 16-Q11 - Your Company started started consulting for Micro Bank who needs to
analyze their marketing data to understand their customers better.
This willl help them plan their neXt marketing campaign. You are brought 
onboard as the Analyst for this job. They have an offer for customers 
who are divorced but they need data to back up the campaign. 
Using the marketing data, write a query to show the percentage of
customers who are divorced and have balances greater than 2000*/

WITH Total_Divorced_High_Bal AS (
    SELECT 
        COUNT(marital) AS total_divorced       
    FROM marketing_data
	WHERE marital = 'divorced' AND balance > 2000
  ),
Total_Marital_Status AS (
    SELECT COUNT(marital) as overall_marital_status
    FROM marketing_data
)
SELECT 
    ROUND((td.total_divorced ::FLOAT/ tm.overall_marital_status *100)::numeric,2)
	AS percentage_divorced
FROM Total_Divorced_High_Bal td, Total_Marital_Status tm;

_OR_

SELECT ROUND(COUNT(*)
		FILTER(WHERE marital = 'divorced' AND balance > 2000)*100.0/COUNT(*),2) 
		AS percentage_divorced
FROM marketing_data;		

/*DAY 17- Q12 - Micro Bank wants to be sure they have enough data for this campaign
and would like to see the total count of each job as contained in the dataset.
Using the marketing data, write a query to show the count of each job, 
arrange the total count in Desc order*/

SELECT DISTINCT job, COUNT(*) AS job_count
FROM marketing_data
GROUP BY job
ORDER BY job_count DESC;
/*DAY 18 -Q13-- Just for Clarity purpose your company wants to see which education
level got to the management job the most. Using the marketing data, write a
query to show the education level that gets the management position the most
Let your output show the education, job and the count of the jobs column*/

SELECT DISTINCT job, COUNT(job) AS job_count, education
FROM marketing_data
WHERE job = 'management'
GROUP BY job, education
ORDER BY job_count DESC
LIMIT 1;

SELECT ROUND(AVG(duration / 52)::numeric,2) AS average_duration
FROM marketing_data
WHERE job = 'management';

/*DAY 19-Q14-Write a query to show the average duration of customer's employment
in management positions. The duration should be calculated in years*/

SELECT ROUND(AVG(duration / 52)::numeric,2) AS average_duration
FROM marketing_data
WHERE job = 'management';

/*DAY 20-Q15-Whats's the total number of customers that have housing, loan and are
single?*/

SELECT loan, housing, marital, COUNT(*) AS single_with_loan_and_housing
FROM marketing_data
WHERE loan = 'yes' AND housing = 'yes'
	AND marital = 'single'
GROUP BY loan, housing, marital;

-- DAY 21 -Bonus Question 3--
/**/
SELECT title, runtime
FROM public.movie_data
WHERE runtime >= 250;

CREATE TABLE employee (
	employee_id INT,
	first_name VARCHAR(50),
	last_name VARCHAR(50),
	date_of_birth DATE,
	hire_date DATE,
	job_title VARCHAR(50),
	department VARCHAR(50),
	salary INT
);

CREATE TABLE share_price (
	_date DATE,
	_ticker VARCHAR(10),
	_company VARCHAR(50),
	_open NUMERIC,
	_close NUMERIC
);

/*DAY 23 -Q16-Using the employee data table dataset, write a query to show all the employees first name and
last name and their respective salaries. Also, show the overall salary of the company and 
calculate the difference between each employee's salary and the company average salary*/

WITH average_employee_salary AS (
	SELECT CEIL(AVG(salary)::NUMERIC) AS company_average
	FROM employee)
SELECT
	ed.first_name, ed.last_name, ed.salary, aes.company_average,
	CEIL((ed.salary - aes.company_average)::NUMERIC) AS salary_diff
FROM average_employee_salary aes, employee ed;


WITH average_employee_salary AS (
	SELECT CEIL(AVG(salary)::NUMERIC) AS company_average
	FROM employee
),
employee_details AS (
	SELECT first_name, last_name, salary
	FROM employee
)
SELECT
	ed.first_name, ed.last_name, ed.salary, aes.company_average,
	CEIL((ed.salary - aes.company_average)::NUMERIC) AS salary_diff
FROM average_employee_salary aes, employee_details ed;
--_OR_ BUT NOTE THAT THE CTE APPROACH IS MORE EFFICIENT--
SELECT first_name, last_name, salary,
	(SELECT CEIL(AVG(salary)) AS avg_salary
	FROM employee), salary - (SELECT CEIL(AVG(salary)) AS avg_salary
	FROM employee) AS salary_diff
FROM employee;

/*DAY 24-Q17 - Using the share price dataset, write a query to show a table that displays the highest daily
decrease and the highest daily increase in share price*/

SELECT 
	MIN(daily_difference) AS highest_daily_decrease,
	MAX(daily_difference) AS highest_daily_increase
FROM 
	(SELECT (_close - _open) AS daily_difference
	FROM share_price) AS daily_diff_table
;
/*DAY 25 -Q18- Our client is planning their logistics for 2024, they want to know the average number
of days it takes to ship to the top 10 states. Using the sample superstore dataset, write a query
to show the state and the average number of days between the order date and the ship date to the
top 10 states*/
SELECT state_, FLOOR((AVG(ship_date - order_date)::numeric)) AS avg_no_of_days
FROM orders
GROUP BY state_
ORDER BY avg_no_of_days
LIMIT 10;


/*Day 26 - Bonus Question -- Write a query to find the 3rd highest sales from the Sample Superstore data*/
SELECT SALES
FROM orders
ORDER BY sales DESC
LIMIT 1 OFFSET 2;

/*DAY 27 -Q19- The Company received a lot of bad reviews about some of your products lately and the 
management wants to  see which products they are and how many have been returned so far. Using 
the orders and returns table, write a query to see the top 5 most returned products from the company*/

SELECT o.product_name, o.product_id, COUNT(r.returned) AS product_count
FROM orders o
JOIN returns_ r
ON o.order_id = r.order_id
GROUP BY o.product_name, o.product_id
ORDER BY product_count DESC
LIMIT 5;

/*DAY 28-Q20- using the employee table dataset, write a query to show the ratio of the analyst job
title to the entire job titles*/
WITH
Count_of_Analyst AS (
	SELECT COUNT(*) AS analyst_count
	FROM employee
	WHERE job_title = 'Analyst'
),
Total_Job_Count AS (
	SELECT COUNT(job_title) AS total_job
	FROM employee)
SELECT 
	ca.analyst_count, CEIL(ca.analyst_count * 100.0/tj.total_job) AS analyst_to_total_ratio
FROM 
	Count_of_Analyst ca, Total_Job_Count tj;
	
/*DAY 29-Q21- Using the employee dataset, please write a query to show the job title and department
with the highest salary*/

SELECT job_title, department
FROM employee
WHERE salary = (SELECT MAX(salary)
				FROM employee)
LIMIT 1;

_OR_

SELECT job_title, department
FROM employee
ORDER BY salary DESC
LIMIT 1;

/*DAY 30-Q22- Using the employee dataset, write a query to determine the rank of employees 
based on their salaries in each department. For each department, find the employee(s)
with the highest salary and rank them in Desc order*/

SELECT 
	first_name, last_name, department, salary, 
	DENSE_RANK()OVER(PARTITION BY department ORDER BY salary DESC) department_salary_rank
FROM employee;







