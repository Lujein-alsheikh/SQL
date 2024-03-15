use foodhunter;

# question 1: rank restaurants based on the number of food items they offer
select *, DENSE_RANK() OVER(order by num_food_items desc) as restaurant_rank
from
(
select restaurant_id, count(item_name) as num_food_items
from food_items
group by restaurant_id
) as query_1;

# question 2:
# How can we use ranking functions to find the top 3 food items (based on the quantity ordered) for each restaurant?
/* 
I looked at the food_items table and we can safely say that two restaurants can NOT share the same item_id.

Note: some item_ids from the food_items table were never ordered! For example, items with ids: 401, 402, 
and 403. 
select * from orders_items where item_id = 401; This line doesn't output anything. 
select restaurant_id, count(item_name) from food_items group by restaurant_id; 
*/

select * from
(
select *, rank() over (partition by restaurant_id order by total_quantity desc ) as item_rank
from 
(
SELECT 
    f.restaurant_id,
    f.item_id, 
    f.item_name,
    (
        SELECT COALESCE(SUM(quantity), 0) 
        FROM orders_items 
        WHERE item_id = f.item_id
        group by item_id
    ) AS total_quantity
FROM 
    food_items f
) t1
) t2
where item_rank <= 3;    

# question 3: classify customers into different categories (like "low", "medium", and "high") based on 
# the total amount they've spent on orders? Write a SQL query using the CASE statement to achieve this.
# select max(final_price) from orders;
# select min(final_price) from orders;
 
select customer_id, final_price from orders;
select customer_id, sum(final_price) as total_amount_spent,
case
 when sum(final_price) < 50.0 then "Low"
 when sum(final_price) between 50.0 and 85.0 then "Medium"
 else "High"
end as customer_category
from orders
group by customer_id;
  
# question 4: 
# classify orders based on delivery time: "fast" if the delivery time is less than 30 minutes,
# "medium" if it's between 30 minutes and 1 hour, and "slow" if it's more than 1 hour. Then find the number of deliveries that come under “fast” category.  
 
# There are no items ordered before midnight and delivered after midnight. Hence, all items were delivered on the same day.
/*
SELECT *
FROM orders
WHERE order_date <> delivered_date;
*/
  
select order_id, customer_id, order_time, delivered_time,
 TIMESTAMPDIFF(MINUTE, order_time, delivered_time) AS time_difference,
 case
 when TIMESTAMPDIFF(MINUTE, order_time, delivered_time) < 30 then 'Fast'
 when TIMESTAMPDIFF(MINUTE, order_time, delivered_time) between 30 and 60 then 'Medium'
 else 'Slow'
 end as Delivery_speed
from orders;
 
# Number of orders that were delivered in under 30 minutes is 35734. 
select count(order_id) from 
(
select order_id, customer_id, order_time, delivered_time,
 TIMESTAMPDIFF(MINUTE, order_time, delivered_time) AS time_difference,
 case
 when TIMESTAMPDIFF(MINUTE, order_time, delivered_time) < 30 then 'Fast'
 when TIMESTAMPDIFF(MINUTE, order_time, delivered_time) between 30 and 60 then 'Medium'
 else 'Slow'
 end as Delivery_speed
from orders
) as sub_query
where Delivery_speed = 'Fast';

 



