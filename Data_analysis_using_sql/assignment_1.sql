use foodhunter;
select * from restaurants;
select item_name, price, calories from food_items;
select order_id, customer_id, total_price from orders;
select count(*) from restaurants;
select count(distinct cuisine) from restaurants;
select count(distinct item_name) from food_items;
