create database zomatoo

use zomatoo

drop table if exists goldusers_signup;
CREATE TABLE goldusers_signup(userid integer,gold_signup_date date); 

INSERT INTO goldusers_signup(userid,gold_signup_date) 
 VALUES (1,'09-22-2017'),
(3,'04-21-2017');

drop table if exists users;
CREATE TABLE users(userid integer,signup_date date); 

INSERT INTO users(userid,signup_date) 
 VALUES (1,'09-02-2014'),
(2,'01-15-2015'),
(3,'04-11-2014');

drop table if exists sales;
CREATE TABLE sales(userid integer,created_date date,product_id integer); 

INSERT INTO sales(userid,created_date,product_id) 
 VALUES (1,'04-19-2017',2),
(3,'12-18-2019',1),
(2,'07-20-2020',3),
(1,'10-23-2019',2),
(1,'03-19-2018',3),
(3,'12-20-2016',2),
(1,'11-09-2016',1),
(1,'05-20-2016',3),
(2,'09-24-2017',1),
(1,'03-11-2017',2),
(1,'03-11-2016',1),
(3,'11-10-2016',1),
(3,'12-07-2017',2),
(3,'12-15-2016',2),
(2,'11-08-2017',2),
(2,'09-10-2018',3);


drop table if exists product;
CREATE TABLE product(product_id integer,product_name text,price integer); 

INSERT INTO product(product_id,product_name,price) 
 VALUES
(1,'p1',980),
(2,'p2',870),
(3,'p3',330);


select * from users
select * from sales
select * from product
select * from goldusers_signup


# What is the total amount each customer spent on zomato?

select s.userid,sum(p.price) as Total_amount from sales s INNER JOIN product p
ON p.product_id=s.product_id
group by s.userid


# How many days each user visited zomato?

select userid,COUNT(distinct created_date) as total_distinct_days  from sales group by userid;


# What was the first product purchased by each customer ?

select * from sales 

with CTE_purchased as
 
(select *,rank() over(partition by userid order by created_date) rnk  from sales) 


select * from CTE_purchased where rnk=1

# What is the most purchased item on the menu and how many times it was purchased by all the customers 


select userid,count(product_id) cnt  from sales where product_id =
(select top 1 product_id from sales group by product_id order by count(product_id) desc)
group by userid


# Which item was most popular for each customer ??

select * from 
(select *,rank() over (partition by userid order by cnt desc) rnk from 
(select userid,product_id,count(product_id) cnt from sales group by userid,product_id)a)b
where rnk=1


# Which item was purchased first by the customer after they become a member?

select * from 
(select c.* ,rank() over(partition by userid order by created_date) rnk from 
(select s.userid,s.created_date,g.gold_signup_date from sales s inner join goldusers_signup g
on s.userid=g.userid and created_date>=gold_signup_date)c)d where rnk=1


# WHich item was purchased just before customer become member ??

select * from 
(select c.* ,rank() over(partition by userid order by created_date desc) rnk from 
(select s.userid,s.created_date,g.gold_signup_date from sales s inner join goldusers_signup g
on s.userid=g.userid and created_date<=gold_signup_date)c)d where rnk=1


#What is the total orders and amount spent for each member before they become member ?


select userid,count(created_date) as order_purchased ,sum(price) as total_amt_spent from
(select c.*,d.price from
(select a.userid,a.created_date,a.product_id,b.gold_signup_date from sales a 
inner join goldusers_signup b
on a.userid=b.userid and created_date<=gold_signup_date) c
inner join product d 
on c.product_id=d.product_id)e
group by userid;



# Rankk all the transactions for each member whenever they are a zomato gold member for every non gold member transaction mark  as na 

select e.*,case when rnk=0 then 'na' else rnk end as rnkk  from 
(select c.* ,cast((case when gold_signup_date is null then 0  else rank() over(partition by userid order by created_date desc)end) as varchar) as  rnk from 
(select a.userid,a.created_date,a.product_id,b.gold_signup_date from sales a left join  goldusers_signup b
on a.userid=b.userid and created_date>=gold_signup_date)c)e; 


