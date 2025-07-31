use walmart_db;
-- Business Problems
-- Q1) Find the different payment method and no. of transactions, no. od Qty sold? 
SELECT payment_method, count(*) as no_payments ,sum(quantity) as no_qty_sold 
FROM walmart_db.walmart_db group by payment_method  ;

-- Q2) Identify the highest -rated category in each branch, displaying the branch ,category, avg_rating?
SELECT * FROM ( 
SELECT branch, category , round(avg(rating),2) as avg_rating ,rank() over(partition by  branch 
order by avg(rating)  desc) as ranks 
FROM walmart_db.walmart_db  group by   branch,category
order by branch, avg_rating desc ) as subquery_alias
where ranks=1;

-- Q3) Identify the busiest day for each branch on the number of transcation?
SELECT * FROM (
SELECT branch, date_format(str_to_date(date, '%d/%m/%y'),'%W') as day_of_week , 
count(*) as no_of_transaction ,dense_rank() over(partition by branch order by count(*) desc ) as ranks
FROM walmart_db group by branch,  day_of_week 
) as subquery_alias where ranks=1;

-- Q4) identify busiest day for branch on the number of transaction?
SELECT  day_of_week ,count(day_of_week)  as total_no_of_days from (select * from (
SELECT branch, date_format(str_to_date(date, '%d/%m/%y'),'%W') as day_of_week , 
count(*) as no_of_transaction ,dense_rank() over(partition by branch order by count(*) desc ) as ranks
FROM walmart_db group by branch,  day_of_week 
) as subquery_alias where ranks=1) as subquery_alias group by day_of_week order by total_no_of_days desc;

-- Q5) Determine the avg , min, max rating of category for each city list the city avg_rating, max_rating and min_rating?
SELECT city , category , round(avg(rating),2) as avg_rating, round(min(rating),2) as min_rating, round(max(rating),2) 
as max_rating
 from walmart_db group by city , category;
 
 -- Q6) Calculate the total profit for each category by considering total_profit as (unit_price*quantity*profit_margin) 
 -- list category and total_profit ,ordered from highest to lowest profit?
 SELECT category, round(sum(total_amount),3) as revenue, round(sum(total_amount*profit_margin),3) as total_profit 
 from walmart_db group by category 
 order by total_profit desc;
 
 -- Q7) Determine the most comman payment method for each Branch 
 -- display branch and the preferred payment method?
 SELECT * FROM (
 SELECT branch , payment_method , count(*) as total_transaction, rank() over(partition by branch order by count(*) desc) as ranks
 from walmart_db group by branch , payment_method
 order by branch , total_transaction desc) as subquery_alias where ranks=1;
 
 -- Q8) Categorize sales into 3 group morning, afternoon, evening 
 -- find out each of the shift and number of invoices ?
 SELECT branch, CASE 
 WHEN time BETWEEN '12:00:00' AND '17:59:59' THEN 'afternoon'
   WHEN time BETWEEN '18:00:00' AND '23:59:58' THEN 'evening'
   else 'morning'
end as sales_shift , count(*) as no_of_invoices 
 from walmart_db group by branch, sales_shift order by branch ,no_of_invoices desc;
 
 -- Q9) Identify 5 branch with highest decrease ratio in revenue compare to last year
 -- (current year 2023 last year 2022)?
 WITH revenue_2022
 as 
 (SELECT branch, round(sum(total_amount),2) as revenue
 from walmart_db where year(str_to_date(date, '%d/%m/%y')) = 2022 group by branch),
 revenue_2023 as 
 (
 SELECT branch, round(sum(total_amount),2) as revenue
 from walmart_db where year(str_to_date(date, '%d/%m/%y')) = 2023 group by branch)

 SELECT ly.branch , ly.revenue as last_year_revenue , cy.revenue as current_year_revenue , 
 round((ly.revenue-cy.revenue)/ly.revenue*100,2) as revenue_dec_ratio
 from revenue_2022 as ly
 join revenue_2023 as cy on ly.branch= cy.branch where ly.revenue>cy.revenue order by revenue_dec_ratio desc limit 5;