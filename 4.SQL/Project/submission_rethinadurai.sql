/*

-----------------------------------------------------------------------------------------------------------------------------------
													    Guidelines
-----------------------------------------------------------------------------------------------------------------------------------

The provided document is a guide for the project. Follow the instructions and take the necessary steps to finish
the project in the SQL file			

-----------------------------------------------------------------------------------------------------------------------------------
                                                         Queries
                                               
-----------------------------------------------------------------------------------------------------------------------------------*/
  
/*-- QUESTIONS RELATED TO CUSTOMERS
     [Q1] What is the distribution of customers across states?
     Hint: For each state, count the number of customers.*/
use project;

select state , count(customer_id) as total_customers
from customer_t
group by state
order by total_customers desc;

-- ---------------------------------------------------------------------------------------------------------------------------------

/* [Q2] What is the average rating in each quarter?
-- Very Bad is 1, Bad is 2, Okay is 3, Good is 4, Very Good is 5.

Hint: Use a common table expression and in that CTE, assign numbers to the different customer ratings. 
      Now average the feedback for each quarter. */

select sub_order.quarter_number, avg(sub_order.rating) as average_rating
from (select * , 
case 
 when customer_feedback = 'Very Good' then 5
 when customer_feedback = 'Good' then 4
 when customer_feedback = 'Okay' then 3
 when customer_feedback = 'Bad' then 2
 when customer_feedback = 'Very Bad' then 1
 end as rating
 
 from order_t) as sub_order
group by sub_order.quarter_number
order by sub_order.quarter_number;

-- ---------------------------------------------------------------------------------------------------------------------------------

/* [Q3] Are customers getting more dissatisfied over time?

Hint: Need the percentage of different types of customer feedback in each quarter. Use a common table expression and
	  determine the number of customer feedback in each category as well as the total number of customer feedback in each quarter.
	  Now use that common table expression to find out the percentage of different types of customer feedback in each quarter.
      Eg: (total number of very good feedback/total customer feedback)* 100 gives you the percentage of very good feedback.*/
      
      select sub_order.quarter_number , 
		  (sub_order.very_good/sub_order.total_ratings)*100 as Very_Good_Rating_Percentage,
		  (sub_order.good/sub_order.total_ratings)*100 as Good_Rating_Percentage,
		  (sub_order.okay/sub_order.total_ratings)*100 as Okay_Rating_Percentage,
		  (sub_order.bad/sub_order.total_ratings)*100 as Bad_Rating_Percentage,
		  (sub_order.very_bad/sub_order.total_ratings)*100 as Very_Bad_Rating_Percentage
	  from 			(select  quarter_number,
					  count(case when customer_feedback = 'Very Good' then 1 end) as very_good,
					  count(case when customer_feedback = 'Good' then 1 end) as good,
					  count(case when customer_feedback = 'Okay' then 1 end) as okay,
					  count(case when customer_feedback = 'Bad' then 1 end) as bad,
					  count(case when customer_feedback = 'Very Bad' then 1 end) as very_bad,
					  count(customer_feedback) AS total_ratings
					from order_t
					group by quarter_number
					order by quarter_number) as sub_order
                    
		order by sub_order.quarter_number;
	

-- ---------------------------------------------------------------------------------------------------------------------------------

/*[Q4] Which are the top 5 vehicle makers preferred by the customer.

Hint: For each vehicle make what is the count of the customers.*/

select prod.vehicle_maker, count(cust.customer_id) as overall_orders
from product_t prod
inner join order_t ord on prod.product_id = ord.product_id
inner join customer_t cust on ord.customer_id = cust.customer_id
group by prod.vehicle_maker
order by overall_orders desc
limit 5;

-- ---------------------------------------------------------------------------------------------------------------------------------


/*[Q5] What is the most preferred vehicle make in each state?

Hint: Use the window function RANK() to rank based on the count of customers for each state and vehicle maker. 
After ranking, take the vehicle maker whose rank is 1.*/

select sub_joined.* from 
(select cust.state, prod.vehicle_maker , count(cust.customer_id) as overall_customers, 
rank() over (partition by state order by count(cust.customer_id) desc) ranking

from product_t prod
inner join order_t ord on prod.product_id = ord.product_id
inner join customer_t cust on ord.customer_id = cust.customer_id

group by  cust.state, prod.vehicle_maker) as sub_joined
where sub_joined.ranking = 1;



---------------------------------------------------------------------------------------------------------------------------------

/*QUESTIONS RELATED TO REVENUE and ORDERS 

-- [Q6] What is the trend of number of orders by quarters?

Hint: Count the number of orders for each quarter.*/

-- use project;

select quarter_number , count(order_id) as total_orders
from order_t
group by quarter_number
order by quarter_number;

-- ---------------------------------------------------------------------------------------------------------------------------------

/* [Q7] What is the quarter over quarter % change in revenue? 

Hint: Quarter over Quarter percentage change in revenue means what is the change in revenue from the subsequent quarter to the previous quarter in percentage.
      To calculate you need to use the common table expression to find out the sum of revenue for each quarter.
      Then use that CTE along with the LAG function to calculate the QoQ percentage change in revenue.
*/

select qua_rev.quarter_number,qua_rev.total_revenue,
lag(qua_rev.total_revenue,1) over(order by qua_rev.quarter_number) as prev_qr_revenue,
((qua_rev.total_revenue - lag(qua_rev.total_revenue,1) over(order by qua_rev.quarter_number))/lag(qua_rev.total_revenue,1) over(order by qua_rev.quarter_number))*100 as qoq_percent_change
from 
	(select quarter_number , sum(vehicle_price) as total_revenue
	from order_t
	group by quarter_number
    order by quarter_number) as qua_rev;
    
    


 
  
  
  
      

-- ---------------------------------------------------------------------------------------------------------------------------------

/* [Q8] What is the trend of revenue and orders by quarters?

Hint: Find out the sum of revenue and count the number of orders for each quarter.*/

select quarter_number , sum(vehicle_price) as total_revenue,  count(order_id) as total_orders
from order_t
group by quarter_number
order by quarter_number;




-- ---------------------------------------------------------------------------------------------------------------------------------

/* QUESTIONS RELATED TO SHIPPING 
    [Q9] What is the average discount offered for different types of credit cards?

Hint: Find out the average of discount for each credit card type.*/

select cust.credit_card_type , avg(ord.discount) as average_discount
from order_t ord inner join customer_t cust on ord.customer_id = cust.customer_id
group by cust.credit_card_type;

-- ---------------------------------------------------------------------------------------------------------------------------------

/* [Q10] What is the average time taken to ship the placed orders for each quarters?
	Hint: Use the dateiff function to find the difference between the ship date and the order date.
*/

select sub_order.quarter_number, avg(sub_order.time_taken) as average_time_taken
from 
	(select * , datediff(ship_date,order_date) as time_taken
	from order_t) as sub_order
group by sub_order.quarter_number
order by sub_order.quarter_number;



-- --------------------------------------------------------Done----------------------------------------------------------------------
-- ----------------------------------------------------------------------------------------------------------------------------------



