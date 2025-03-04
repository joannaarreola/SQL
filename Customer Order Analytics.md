# Customer Order Data Analytics

## Objective
The goal of this analysis is to extract key business insights from customer order data across multiple months. By querying a structured database, we aim to uncover trends in sales, revenue, and customer behavior.

## Dataset Overview
The dataset consists of multiple tables:

- `JanSales`: Contains order data for January.
- `FebSales`: Contains order data for February.
- `customers`: Contains customer account details.

The data includes key columns such as `orderID`, `product`, `price`, `quantity`, `location`, and `acctnum` (customer account number).

## Key Business Questions and analysis

### **1. Order Volume Analysis**
**Question:** How many orders were placed in January?

**Approach:** Used `COUNT(orderID)` with filters to clean data.
```
SELECT COUNT(orderID) FROM BIT_DB.JanSales
WHERE length(orderid) = 6
AND orderid <> 'Order ID';
```
***Insight:*** A total of X orders were placed in January


### **2. Product Demand**
**Question:** How many January orders were for an iPhone? 

**Approach:** Applied a `WHERE` clause to filter for iPhone orders.
```
SELECT COUNT(orderID) FROM BIT_DB.JanSales
WHERE Product = 'iPhone'
AND length(orderid) = 6
AND orderid <> 'Order ID';
```
***Insight:*** The iPhone was one of the most ordered products, indicating high demand

### **3. Customer Behavior**
**Question:** Select the customer account numbers for all the orders that were placed in February.

**Approach:** Used `DISTINCT` to count unique customer account numbers.
```
SELECT distinct acctnum FROM BIT_DB.customers
INNER JOIN BIT_DB.FebSales
on customers.order_id = FebSales.orderid
WHERE length(orderid) = 6
AND orderid <> 'Order ID';
```
***Insight:*** X unique customers placed orders in February, showing a retention rate of Y% compared to January.

### **4.Pricing and Revenue Insights**
**Question:** Which product was the cheapest one sold in January, and what was the price? 

**Approach:** Used `MIN(price)` to find the lowest price.
```
SELECT distinct Product, price
FROM BIT_DB.JanSales
WHERE  price = (SELECT min(price) FROM BIT_DB.JanSales);
```
***Insight:*** The cheapest product sold was [Product Name] at $X.XX.


**Question:** What is the total revenue for each product sold in January?
**Approach:** Multiplied `price * SUM(quantity)` to calculate revenue per product.
```
SELECT product, price * SUM(quantity) AS revenue
FROM BIT_DB.JanSales
GROUP BY product;
```
***Insight:*** The highest revenue-generating product was [Product Name] with $X,XXX in sales.

### **5. Location-based Sales Analysis**
**Question:** Which products were sold in February at 548 Lincoln St, Seattle, WA 98101, how many of each were sold, and what was the total 
revenue?

**Approach:** Used `WHERE` to filter by location and calculated total revenue.
```
SELECT product, SUM(quantity), price * SUM(quantity) AS revenue FROM BIT_DB.FebSales 
WHERE location = '548 Lincoln St, Seattle, WA 98101'
GROUP BY product;
```
***Insight:*** The top-selling product at this location was [Product Name], generating $X,XXX in revenue.


**Question:** List all the products sold in Los Angeles in February, and include how many of each were sold.

**Approach:** Used `LIKE '%Los Angeles%'` to filter and `SUM(quantity)`.
```
SELECT product, SUM(quantity) 
FROM BIT_DB.FebSales
WHERE location LIKE '%Los Angeles%'
GROUP BY product
```
***Insight:*** Los Angeles had strong sales, with [Product Name] leading.

**Question:** Which locations in New York received at least 3 orders in January, and how many orders did they each receive?

**Approach:** Used `SUM(price * quantity)`, `ORDER BY DESC`, and `LIMIT 1`.
```
SELECT location, COUNT(orderID) FROM BIT_DB.JanSales
WHERE location LIKE '%NY%'
AND length(orderid) = 6 
AND orderid <> 'Order ID'
GROUP BY location
HAVING count(orderID) >= 3
```

### **6. Customer Spending**
**Question:** How many customers ordered more than 2 products at a time, and what was the average amount spent for those customers (in February)? 

**Approach:** Used `COUNT(DISTINCT acctnum)` and `AVG(quantity * price)`.
```
SELECT COUNT(distinct customers.acctnum), AVG(quantity*price) FROM BIT_DB.FebSales
LEFT JOIN BIT_DB.customers
ON FebSales.orderid = customers.order_id 
WHERE FebSales.Quantity > 2
AND length(orderid) = 6
AND orderid <> 'Order ID';
```
***Insight:*** X customers placed bulk orders, with an average spend of $X.XX.


### **8. High-performing products**

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

Conclusion
Order Volume: January saw X orders, with February seeing a Y% increase/decrease.
Popular Products: The iPhone was a top seller, and [Product Name] had the highest revenue.
Customer Trends: X% of customers from January returned in February.
Geographic Insights: Los Angeles and Seattle were key sales locations.
Revenue Insights: The highest revenue-generating product in January was [Product Name].

Next Steps
Customer Retention Strategies: Offer promotions to encourage repeat purchases.
Product Stocking Strategy: Ensure high-demand products are well-stocked.
Location-Specific Marketing: Optimize marketing efforts based on regional demand.
