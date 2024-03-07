use foodhunter;

# question 1: group the restaurants on the basis of the cuisines served from the restaurants table.
# select * from restaurants group by cuisine; This gives an error because we need to decide what to do with the
# non-aggregated columns i.e., which information we need to retrieve exactly.
# one suggestion is to show names of restaurants for each cuisine:
SELECT cuisine, GROUP_CONCAT(restaurant_name ORDER BY restaurant_name ASC SEPARATOR ', ') AS restaurant_names
FROM restaurants
GROUP BY cuisine;

# question 2: What is the total number of restaurants under each cuisine?
select cuisine, count(*) as Number_of_restaurants from restaurants group by cuisine;

# question 3: retrieve the restaurant_id and item_names of all the non-vegetarian dishes from the food_items table.
select restaurant_id, item_name from food_items where food_type= 'non-vegetarian' or food_type = 'Non-veg';

# question 4: find the number of orders placed on each Monday in the month of September. 
# (Hint: The dates are 5th, 12th, 19th and 26th of September)
select order_date , count(*) as Number_of_orders from orders 
where order_date IN ('2022-09-05', '2022-09-12', '2022-09-19', '2022-09-26')
group by order_date;
# or 
select order_date , count(*) as Number_of_orders from orders 
group by order_date
having order_date IN ('2022-09-05', '2022-09-12', '2022-09-19', '2022-09-26');

# question 5: find the number of orders placed during each week in the month of September. 
# Hint: Use cases and group by

select count(*) as Number_of_Orders,
case 
when order_date between '2022-09-01' and '2022-09-07' then 'first week'
when order_date between '2022-09-08' and '2022-09-14' then 'second week'
when order_date between '2022-09-15' and '2022-09-21' then 'third week'
when order_date between '2022-09-22' and '2022-09-28' then 'fourth week'
when order_date between '2022-09-29' and '2022-09-30' then 'fifth week'
else 'not in september'
end as Order_Date_Week
from orders
where order_date BETWEEN '2022-09-01' AND '2022-09-30'
group by Order_Date_Week;

# or 
select count(*) as Number_of_Orders,
case 
when order_date between '2022-09-01' and '2022-09-07' then 'first week'
when order_date between '2022-09-08' and '2022-09-14' then 'second week'
when order_date between '2022-09-15' and '2022-09-21' then 'third week'
when order_date between '2022-09-22' and '2022-09-28' then 'fourth week'
when order_date between '2022-09-29' and '2022-09-30' then 'fifth week'
else 'not in september'
end as Order_Date_Week
from orders
group by Order_Date_Week
having Order_Date_Week <> 'not in september';
