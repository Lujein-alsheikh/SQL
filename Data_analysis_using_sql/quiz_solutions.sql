use foodhunter;
/*

# question 1: what is the highest number of orders amongst customers? 14
select * from orders;

select customer_id, count(order_id) as num_orders
from orders
group by customer_id
order by num_orders desc;

# question 2:  
# What is the average calories per dish for each cuisine type? Values are close to nearest integer.
select r.cuisine, round(sum(fi.calories)/count(*)) as avg_calories

# Solution if you don't take the orders into consideration.
from food_items fi left join restaurants r on fi.restaurant_id = r.restaurant_id
group by r.cuisine;

select fi.item_id, fi.item_name, fi.calories, fi.restaurant_id, r.cuisine 
from food_items fi left join restaurants r on fi.restaurant_id = r.restaurant_id;

select r.cuisine, sum(fi.calories) as sum_calories, 
count(*) as cuisine_freq, round(sum(fi.calories)/count(*)) as avg_calories
from food_items fi left join restaurants r on fi.restaurant_id = r.restaurant_id
group by r.cuisine;

# Solution if you take the orders into consideration
SELECT r.cuisine, AVG(fi.calories) AS avg_calories_per_cuisine
FROM restaurants r
INNER JOIN food_items fi ON r.restaurant_id = fi.restaurant_id
INNER JOIN orders_items oi ON fi.item_id = oi.item_id
GROUP BY r.cuisine;

select * 
from restaurants r 
inner join food_items fi on r.restaurant_id = fi.restaurant_id;

select * from restaurants r
INNER JOIN food_items fi ON r.restaurant_id = fi.restaurant_id
INNER JOIN orders_items oi ON fi.item_id = oi.item_id;

# question 3:
select driver_id, avg(order_rating) as avg_rating 
from orders
group by driver_id
order by avg_rating desc;

# question 4: 
# retrieve the names of all those customers who have placed an order with FoodHunter along with the total number of orders they have placed.

SELECT c.customer_id, c.first_name, c.last_name, COUNT(o.order_id) AS total_orders
FROM customers c
RIGHT JOIN orders o ON c.customer_id = o.customer_id
GROUP BY c.customer_id ;
*/
# question 5:
# Find the items which have not been ordered by any customer so far.

SELECT f.item_id, COUNT(o.item_id) as item_count
FROM orders_items o RIGHT JOIN food_items f
ON o.item_id = f.item_id
GROUP BY f.item_id
having item_count =0;

select * from orders_items o RIGHT JOIN food_items f
ON o.item_id = f.item_id;

select * from orders_items o RIGHT JOIN food_items f
ON o.item_id = f.item_id
where f.item_id = 414;