use hotel_bookings;
select * from bookings;
select * from customers;
select * from hotels;
/* 
create database hotel_bookings;  
# Creating the tables:

CREATE table bookings
(
booking_id int,
customer_id int,
hotel_id int,
check_in_date datetime,
check_out_date datetime,
booking_status varchar(20),
room_type varchar(20),
room_rate int,
customer_rating int
);

Note: the "Check_Out_Date" column has '-' values which were not imported into the bookings table
The error is: Incorrect datetime value
The same error occurs if I preprocess the csv file with Python and convert the column to datetime type
(which converts '-' to NaT)
The same error occurs as well if I replace '-' with '' or with '0000-00-00 00:00:00'
What works is replacing '-' with some special value (like '2024-12-31 00:00:00' which is out of the range
of dates and then replace it with null in sql. 

select count(*) from bookings; # there are 16900 rows

select count(*) from bookings
where check_out_date ='2024-12-31 00:00:00'; # this gives 3500 rows

UPDATE bookings
SET check_out_date = NULL
WHERE check_out_date = '2024-12-31 00:00:00';

select count(*) from bookings; # this gives 16900 as it should.

select count(*) from bookings 
where check_out_date is null;  This gives 3500 as it should
-----------------------------------------------------------------------------
create table customers 
(
customer_id int,
customer_name varchar(255),
email varchar(255),
loyalty_program_status varchar(255)
);

create table hotels
(
hotel_id int primary key,
hotel_name varchar(255),
city varchar(255),
country varchar(255)
);

------------------------------------------------------------------------------------------
# question 1:  Booking Trends Over Time
# Method 1:
select *, ((num_of_reservations- previous_num_of_reservations)/previous_num_of_reservations)*100 as percentage
from 
(
select *, lag(num_of_reservations) over (order by month_of_year) as previous_num_of_reservations
from 
(
select month(check_in_date) as month_of_year, count(*) as num_of_reservations
from bookings
group by month_of_year
order by month_of_year
) as sub_query_1
) as sub_query_2
;  

# Method 2:
WITH monthly_reservations AS (
    SELECT 
        MONTH(check_in_date) AS month_of_year, 
        COUNT(*) AS num_of_reservations 
    FROM 
        bookings
    GROUP BY 
        month_of_year
    ORDER BY 
        month_of_year
)
SELECT 
    *, LAG(num_of_reservations) OVER (ORDER BY month_of_year) as previous_num_reservations,
    ((num_of_reservations - LAG(num_of_reservations) OVER (ORDER BY month_of_year)) / LAG(num_of_reservations) OVER (ORDER BY month_of_year)) * 100 AS percentage_change
FROM 
    monthly_reservations;

# Method 3:
select *, lag(num_of_reservations) over (order by month_of_year) as previous_num_reservations,
((num_of_reservations - lag(num_of_reservations) over (order by month_of_year))/lag(num_of_reservations) over (order by month_of_year))*100 as percentage_change
from 
(
select month(check_in_date) as month_of_year, count(*) as num_of_reservations
from bookings
group by month_of_year
order by month_of_year
) t;

---------------------------------------------------------------------------------------------------
# question 2:  Hotel Ratings Analysis
select t1.hotel_id,  avg(t1.customer_rating) as avg_rating, t2.hotel_name, t2.city, t2.country
from bookings t1 left join hotels t2 on t1.hotel_id = t2.hotel_id
group by t1.hotel_id
order by avg_rating desc;

# The hotels that have the highest average ratings are: Skyline Hotel with id 34, Orchard Hotel with id
# 40 and Classic Elegance Hotel with id 10. All three hotels have an average rating of 5.

-----------------------------------------------------------------------------------------------------
# question 3: Popular Room Categories
# Which room types are the most popular among customers?

select room_type, count(*) as num_reservations
from bookings
group by room_type
order by num_reservations;
# Single rooms are the most popular.
---------------------------------------------------------------------------------------------------

# question 4: Loyalty Program Analysis
# How many customers are enrolled in the loyalty program, and how does it correlate with their booking frequency?

Note: 
select count(distinct customer_id) from bookings; # 8707
select count(distinct customer_id) from customers; # 5000 ranging from 1 to 5000

select count(distinct customer_id) from bookings
where customer_id > 5000;  # 4312

In the bookings table, there are customers whose information does not exist in the customers table.
There are 8707 customers, 4312 of them don't exist in the customers table and 4395 of them do.

# part 1: How many customers are enrolled in the loyalty program?

# solution 1: using left join
# To calculating the number of customers in each loyalty program category taking into consideration only 
# customers who actually booked at least a room (i.e., customers who exist in the booking table but not
# necessarily in the customers table), we apply left join between bookings and customers tables.  
select loyalty_program_status, COUNT(DISTINCT bookings_customer_id) as num_customers
from
(
select t1.customer_id as bookings_customer_id, t1.booking_id,
t2.customer_id as customer_customer_id, t2.loyalty_program_status
from bookings t1 left join customers t2 on t1.customer_id = t2.customer_id
) as t
group by loyalty_program_status;
#----------------------------------------------------------------------------------------------------

# solution 2: using full outer join
# If we are interested in calculating the number of customers in each loyalty program regardless of the 
# cases where:
# 1. they exist in the booking table and not in the customers table
# 2. they exist in the customers table and not in the bookings table.
# then we do full outer join.
# Note that there is no full outer join in mysql so we need to find a workaround.
select loyalty_program_status, count(distinct customer_id) as num_customers
from
(
select COALESCE(booking_customer_id, customer_customer_id) as customer_id, booking_id,
loyalty_program_status
from
(
SELECT t1.customer_id as booking_customer_id, t1.booking_id as booking_id, 
 t2.customer_id as customer_customer_id, t2.loyalty_program_status as loyalty_program_status
FROM bookings t1
LEFT JOIN customers t2 ON t1.customer_id = t2.customer_id
UNION
SELECT t1.customer_id as booking_customer_id, t1.booking_id as booking_id, 
 t2.customer_id as customer_customer_id, t2.loyalty_program_status as loyalty_program_status
FROM bookings t1
RIGHT JOIN customers t2 ON t1.customer_id = t2.customer_id
) t
) shorter_table
group by loyalty_program_status;
--------------------------------------------------------------------------------------------------------
# part 2: To look at the booking frequency, it makes sense to apply left join between bookings and customers
# What I want to calculate is the average bookings per customer for each loyalty program category.

select loyalty_program_status, avg(num_bookings) as avg_of_bookings
from
(
SELECT t1.customer_id as bookings_customer_id, COUNT(t1.booking_id) AS num_bookings,
        t2.loyalty_program_status
FROM bookings t1 LEFT JOIN customers t2 ON t1.customer_id = t2.customer_id
GROUP BY t2.loyalty_program_status, bookings_customer_id
) as t
group by loyalty_program_status
order by avg_of_bookings;
-----------------------------------------------------------------------------------------------------

# question 5: 
# Which customers have more than 1 bookings, and what is their contact information?

select * from customers t1 right join
( 
select customer_id, count(booking_id) as num_bookings
from bookings
group by customer_id
having num_bookings >1
) t2
on t1.customer_id = t2.customer_id
order by num_bookings;
-----------------------------------------------------------------------------------------------------

# question 6:
# On which days of the week do hotels experience the highest booking activity?

# The day on which the highest bookings happened was Wednesday.
select day_, count(booking_id) as num_bookings
from
(
select booking_id, dayname(check_in_date) as day_
from bookings
) t
group by day_
order by num_bookings desc;

# The trend of bookings of each day throughout all months
SELECT *, 
       LAG(num_bookings) OVER (partition by day_ ORDER BY month_) AS prev_num_bookings,
       ((num_bookings - LAG(num_bookings) OVER (partition by day_ ORDER BY month_)) / LAG(num_bookings) OVER (partition by day_ ORDER BY month_)) AS growth_rate
FROM
(
    SELECT day_, month_, COUNT(booking_id) AS num_bookings
    FROM
    (
        SELECT booking_id, DAYNAME(check_in_date) AS day_, MONTH(check_in_date) AS month_
        FROM bookings
    ) t1
    GROUP BY day_, month_
) t2
order by 
	CASE 
			WHEN day_ = 'Monday' THEN 1
			WHEN day_ = 'Tuesday' THEN 2
			WHEN day_ = 'Wednesday' THEN 3
			WHEN day_ = 'Thursday' THEN 4
			WHEN day_ = 'Friday' THEN 5
			WHEN day_ = 'Saturday' THEN 6
			WHEN day_ = 'Sunday' THEN 7
	END,
    month_
;
# -------------------------------------------------------------------------------------------------------

# question 7: Who are the top 5 customers with the highest number of bookings, 
# and what is their loyalty program status?

SELECT t1.customer_id,
       t2.customer_name,
       t2.loyalty_program_status,
       t1.num_bookings
FROM (
    SELECT customer_id, COUNT(booking_id) AS num_bookings
    FROM bookings
    GROUP BY customer_id
    ORDER BY num_bookings DESC
    LIMIT 5
) AS t1
LEFT JOIN customers t2 ON t1.customer_id = t2.customer_id;
#------------------------------------------------------------------------------------------------------

# question 8: Which city have a most number of bookings?
# It is New York.
select city, count(booking_id) as num_bookings
from
(
select t1.booking_id, t2.city
from
( bookings t1 left join hotels t2 on t1.hotel_id = t2.hotel_id)
) t 
group by city
order by num_bookings
limit 1;

*/






