drop database if exists churn;
create database churn;
use churn;
create table codebytes(
id int primary key,
subscription_start date ,
subscription_end date,
segment int);
select * from codebytes;
-- 1. Select the first 100 rows of the data in the codebytes table. 
select * from codebytes limit 100;
-- 2. Which months will you be able to calculate churn for? Check the range of months of data provided on subscription start.
select min(subscription_start) as min_start_month, max(subscription_start) as max_start_month
FROM codebytes;
select distinct date_format(subscription_start,'%m') as month
from codebytes
where subscription_start between '2016-12-01' AND '2017-03-30';
/*3. You’ll be calculating the churn rate for both segments (87 and 30) over the first 3 months of 2017 (you can’t calculate it for December,
     since there are no subscription_end values yet). To get started, create a temporary table of months that contains two columns: 
    first-day and last-day values containing the first day and last day of the month.*/

WITH months As
(select 
'2017-01-01' as first_day,
'2017-01-31' as last_day
union
select 
'2017-02-01' as first_day,
'2017-02-21' as last_day
union
select 
'2017-03-01' as first_day,
'2017-03-31' as last_day)
select * from months;
-- 4. Create a temporary table called cross_join, from table codebytes and your months. Be sure to SELECT every column
WITH months As
(select 
'2017-01-01' as first_day,
'2017-01-31' as last_day
union
select 
'2017-02-01' as first_day,
'2017-02-21' as last_day
union
select 
'2017-03-01' as first_day,
'2017-03-31' as last_day),
cross_join as 
(select * from codebytes cross join months) 
select * from cross_join;
/*
. Create a temporary table, status, from the cross_join table you created. This table should contain:
id selected from cross_join
month as an alias of first_day
is_active_87 created using a CASE WHEN to find any users from segment 87 who existed prior to the beginning of the month. This is 1 if true and 0 otherwise.
is_active_30 created using a CASE WHEN to find any users from segment 30 who existed prior to the beginning of the month. This is 1 if true and 0 otherwise.
*/
WITH months As
(select 
'2017-01-01' as first_day,
'2017-01-31' as last_day
union
select 
'2017-02-01' as first_day,
'2017-02-21' as last_day
union
select 
'2017-03-01' as first_day,
'2017-03-31' as last_day),
cross_join as 
(select * from codebytes cross join months),
status as 
(select id, first_day as month, 
       case when segment = 87 and subscription_start <= first_day and (subscription_end > first_day or subscription_end is null) then 1 else 0 end as is_active_87,
       case when segment = 30 and subscription_start <= first_day and (subscription_end > first_day or subscription_end is null) then 1 else 0 end as is_active_30
from cross_join)
select * from status;
-- 6. Add an is_canceled_87 and an is_canceled_30 column to the status temporary table. This should be 1 if the subscription is canceled during the month and 0 otherwise.
WITH months As
(select 
'2017-01-01' as first_day,
'2017-01-31' as last_day
union
select 
'2017-02-01' as first_day,
'2017-02-21' as last_day
union
select 
'2017-03-01' as first_day,
'2017-03-31' as last_day),
cross_join as 
(select * from codebytes cross join months),
status as 
(select id, first_day as month, 
case when segment = 87 and subscription_start <= first_day and (subscription_end > first_day or subscription_end is null) then 1 else 0 end as is_active_87,
case when segment = 30 and subscription_start <= first_day and (subscription_end > first_day or subscription_end is null) then 1 else 0 end as is_active_30,
case when (subscription_end Between first_day and last_day) and (segment = 87) then 1 else 0 end as is_canceled_87,
case when (subscription_end Between first_day and last_day) and (segment = 30) then 1 else 0 end as is_canceled_30
from cross_join) 
select * from status order by id ,month;
/*7. Create a status_aggregate temporary table that is a SUM of the active and canceled subscriptions for each segment, for each month.
The resulting columns should be:
sum_active_87
sum_active_30
sum_canceled_87
Sum_canceled_30*/
WITH months As
(select 
'2017-01-01' as first_day,
'2017-01-31' as last_day
union
select 
'2017-02-01' as first_day,
'2017-02-21' as last_day
union
select 
'2017-03-01' as first_day,
'2017-03-31' as last_day),
cross_join as 
(select * from codebytes cross join months),
status as 
(select id, first_day as month, 
case when segment = 87 and subscription_start <= first_day and (subscription_end > first_day or subscription_end is null) then 1 else 0 end as is_active_87,
case when segment = 30 and subscription_start <= first_day and (subscription_end > first_day or subscription_end is null) then 1 else 0 end as is_active_30,
case when (subscription_end Between first_day and last_day) and (segment = 87) then 1 else 0 end as is_canceled_87,
case when (subscription_end Between first_day and last_day) and (segment = 30) then 1 else 0 end as is_canceled_30
from cross_join),
status_aggregate as 
(select month, 
sum(is_active_87) as sum_active_87,
sum(is_active_30) as sum_active_30,
sum(is_canceled_87) as sum_canceled_87,
sum(is_canceled_30) as sum_canceled_30 from status
group by month) select * from status_aggregate;
-- 8.  Calculate the churn rates for the two segments over the three month period. Which segment has a lower churn rate?
WITH months As
(select 
'2017-01-01' as first_day,
'2017-01-31' as last_day
union
select 
'2017-02-01' as first_day,
'2017-02-21' as last_day
union
select 
'2017-03-01' as first_day,
'2017-03-31' as last_day),
cross_join as 
(select * from codebytes cross join months),
status as 
(select id, first_day as month, 
case when segment = 87 and subscription_start <= first_day and (subscription_end > first_day or subscription_end is null) then 1 else 0 end as is_active_87,
case when segment = 30 and subscription_start <= first_day and (subscription_end > first_day or subscription_end is null) then 1 else 0 end as is_active_30,
case when (subscription_end Between first_day and last_day) and (segment = 87) then 1 else 0 end as is_canceled_87,
case when (subscription_end Between first_day and last_day) and (segment = 30) then 1 else 0 end as is_canceled_30
from cross_join),
status_aggregate as 
(select month, 
sum(is_active_87) as sum_active_87,
sum(is_active_30) as sum_active_30,
sum(is_canceled_87) as sum_canceled_87,
sum(is_canceled_30) as sum_canceled_30 from status
group by month)
select month, 
(sum_canceled_87/sum_active_87) * 100 as churn_rate_87,
(sum_canceled_30/sum_active_30) * 100 as churn_rate_30 from status_aggregate;
         




