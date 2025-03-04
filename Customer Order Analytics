#Customer Order Data Analytics

##Objective
The goal of this analysis is to extract key business insights from customer order data across multiple months. By querying a structured database, we aim to uncover trends in sales, revenue, and customer behavior.

##Dataset Overview
The dataset consists of multiple tables:

JanSales: Contains order data for January.
FebSales: Contains order data for February.
customers: Contains customer account details.

The data includes key columns such as orderID, product, price, quantity, location, and acctnum (customer account number).

##Key Business Questions and analysis

###**1. Order Volume Analysis**
**Question:** How many orders were placed in January?
**Approach:** Used `COUNT(orderID)` with filters to clean data.
```
SELECT COUNT(orderID) FROM BIT_DB.JanSales
WHERE length(orderid) = 6
AND orderid <> 'Order ID';
```
***Insight:*** A total of X orders were placed in January

--Question: How many of those orders were for an iPhone? 
--Approach: To get the number of iPhone orders we use the count function as before, but add a where clause to specify the product name 
'iPhone' and keep the orderid filters.

SELECT COUNT(orderID) FROM BIT_DB.JanSales
WHERE Product = 'iPhone'
AND length(orderid) = 6
AND orderid <> 'Order ID';

--Question: Select the customer account numbers for all the orders that were placed in February.
--Approach: We select the acctnum column and use the distinct function in order to avoid duplicates. The customers table is joined with 
the FebSales table using an inner join to retrieve the matching values among these two tables, that tells us which acctnum ordered in
February since the customers table contains acctnum data. We once again add the orderid filters.

SELECT distinct acctnum FROM BIT_DB.customers
INNER JOIN BIT_DB.FebSales
on customers.order_id = FebSales.orderid
WHERE length(orderid) = 6
AND orderid <> 'Order ID';

--Question: Which product was the cheapest one sold in January, and what was the price? 
--Approach: First we construct the subquery to retrieve the minimum price. We use a where clause to retrive the product with this price and
also display the price next to it. We add distinct to product to avoid duplicates.

SELECT distinct Product, price
FROM BIT_DB.JanSales
WHERE  price = (SELECT min(price) FROM BIT_DB.JanSales);

--Question: What is the total revenue for each product sold in January?
--Approach: We want to display product next to revenue. In order to calculate revenue, we need to multiply the price of each product by the
total quantity of product sold. For the toal quantity we use the sum function. We lastly group by product.

SELECT product, price * SUM(quantity) AS revenue
FROM BIT_DB.JanSales
GROUP BY product;

--Question: Which products were sold in February at 548 Lincoln St, Seattle, WA 98101, how many of each were sold, and what was the total 
revenue?
--Approach: We select the product name, use the sum function for the quantity to get the total quantity,and calculate revenue as before using
the sum of quantity and multiplying by price. We use the where clause to filter to a specific location. Lastly, we group by product to get these
results for each product ordered.

SELECT product, SUM(quantity), price * SUM(quantity) AS revenue FROM BIT_DB.FebSales 
WHERE location = '548 Lincoln St, Seattle, WA 98101'
GROUP BY product;

--Question: How many customers ordered more than 2 products at a time, and what was the average amount spent for those customers (in February)? 
--Approach: We first think about joining the FebSales table to the customers table since we can determine the number of customers from the 
acctnum column. We join on their column in common orderid. We use a where clause in order to filter the results to quantity greater than 2.
We use the orderid filters as well since we are using data from this column. we want to display a count of the customers fitting this criteria 
so we use a count function in our select statement and add distinct in front of acctnum. We also want an average amount spent which will be 
quantity*price. We use the avg function for this.

SELECT COUNT(distinct customers.acctnum), AVG(quantity*price) FROM BIT_DB.FebSales
LEFT JOIN BIT_DB.customers
ON FebSales.orderid = customers.order_id 
WHERE FebSales.Quantity > 2
AND length(orderid) = 6
AND orderid <> 'Order ID';

--Question: List all the products sold in Los Angeles in February, and include how many of each were sold.
--Approach: We want to filter by a specific location, so we use a LIKE operator in our where clause with % on either side since the city name 
is in the middle of the addresses listed in the location column. We use product in our select statement to list the product and use sum to 
add up the total quantity of each product. Lastly, we group by product.

SELECT product, SUM(quantity) 
FROM BIT_DB.FebSales
WHERE location LIKE '%Los Angeles%'
GROUP BY product

--Question: Which locations in New York received at least 3 orders in January, and how many orders did they each receive?
--Approach: We determine we only want to show orders from New York so we use a where clause and the like operator to select onky those loactions
containing NY in the address. We want to display the location and count of orders for each location so we include these in our select statement.
we group by location since we are using the aggregate count function. We aso include the orderid filters. Lastly, we use the having function
to limit our answer to 3 or more orders.

SELECT location, COUNT(orderID) FROM BIT_DB.JanSales
WHERE location LIKE '%NY%'
AND length(orderid) = 6 
AND orderid <> 'Order ID'
GROUP BY location
HAVING count(orderID) >= 3

--Question: How many of each type of headphone was sold in February?
--Approach: We want to display the product next to the total quantity of each product so we include product and sum(quantity) in our select 
statement. We use a where clause and like operator to select only the products that contain the word Headphones. Lastly, we group by product.

SELECT Product, sum(Quantity) FROM BIT_DB.FebSales 
WHERE Product like '%Headphones%'
GROUP BY Product

--Question: What was the average amount spent per account in February?
--Approach: In order to get data per account we need to join the customers table. We use a left join and join on orderid. We want the average
amount spent per customer so we use a ratio: sum of price*quantity in the numerator and a count of the total number of accounts in the 
denominator.

SELECT SUM(Quantity*price)/COUNT(acctnum) FROM BIT_DB.FebSales 
LEFT JOIN BIT_DB.customers
ON FebSales.orderid = customers.order_id 
WHERE length(orderid) = 6
AND orderid <> 'Order ID';

--Question:What was the average quantity of products purchased per account in February? 
--Approach: We can use the framework from the last question and just change our select statement to read sum(quantity) rather than multiplying
by price since we only want the quantity in this instance.

SELECT SUM(Quantity)/COUNT(acctnum) FROM BIT_DB.FebSales
LEFT JOIN BIT_DB.customers 
ON FebSales.orderid=customers.order_id
WHERE length(orderid) = 6 
AND orderid <> 'Order ID'

--Question: Which product brought in the most revenue in January and how much revenue did it bring in total? 
--Approach: we calculate revenue using price*quantity. We want total revenue per item so we use a sum to get our total. we include product in
our select statement and group by product. to irder the results from highest to lowest we use the order by function and add desc. Lastly, we limit
th output to 1 to get the top item.
SELECT Product, SUM(price*quantity) as Revenue FROM BIT_DB.JanSales
GROUP BY Product
ORDER BY Revenue DESC
LIMIT 1;
