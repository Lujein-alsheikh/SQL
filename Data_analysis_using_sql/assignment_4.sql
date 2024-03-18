
# qustion 1: retrieve Customer Name, Order ID, Order Date, Amount of all customers who have placed orders
select t1.customer_name, t2.order_id, t2.order_date, t2.amount
from customers t1
right join orders t2 on t1.customer_id = t2.customer_id;

# question 2: calculate the total amount for only those customers who have placed an order.
select t2.customer_id, t1.customer_name, sum(t2.amount) as total_amount
from customers t1
right join orders t2 on t1.customer_id = t2.customer_id
group by t2.customer_id;

# question 3: display the order count (number of orders) for each Customer ID.
select t1.customer_id, count(t2.order_id) as order_count
from customers t1 left join orders t2 on t1.customer_id = t2.customer_id;

# question 4: output the customer names along with their orders for orders placed on or after August 12, 2023

select t1.customer_name, t2.order_id, t2.order_date, t2.amount
from customers t1 right join orders t2 on t1.customer_id = t2.customer_id
where t2.order_date >= '2023-08-12';

