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
**Question:** How many unique orders were placed in January?

**Approach:** Used `COUNT(orderID)` with filters to clean data.
```
SELECT COUNT(distinct orderID) FROM BIT_DB.JanSales
WHERE length(orderid) = 6
AND orderid <> 'Order ID';
```
***Insight:*** A total of 9268 orders were placed in January

**Question:** How many unique orders were placed in February?

**Approach:** Used `COUNT(orderID)` with filters to clean data.
```
SELECT COUNT(distinct orderID) FROM BIT_DB.FebSales
WHERE length(orderid) = 6
AND orderid <> 'Order ID';
```
***Insight:*** A total of 11507 orders were placed in January. Order volume increased by 24% from January to February.

### **2. Product Demand**
**Question:** Which product brought in the most revenue in January and how much revenue did it bring in total? 

**Approach:** Used `SUM(price*quantity)` to calculate revenue and sorted by revenue `desc`
```
SELECT Product, SUM(price*quantity) as Revenue FROM BIT_DB.JanSales
GROUP BY Product
ORDER BY Revenue DESC
LIMIT 1;
```
***Insight:*** The Macbook Pro Laptop brought in the most revenue at $399,500

**Question:** Which product brought in the most revenue in February and how much revenue did it bring in total? 

**Approach:** Used `SUM(price*quantity)` to calculate revenue and sorted by revenue `desc`
```
SELECT Product, SUM(price*quantity) as Revenue FROM BIT_DB.FebSales
GROUP BY Product
ORDER BY Revenue DESC
LIMIT 1;
```
***Insight:*** The Macbook Pro Laptop brought in the most revenue at $467,500. The Macbook Pro is the highest performing product in both months

**Question:** How many of each type of headphone was sold in February?

**Approach:** Grouped by `Product` and used `SUM(Quantity)`
```
SELECT Product, sum(Quantity) FROM BIT_DB.FebSales 
WHERE Product like '%Headphones%'
GROUP BY Product
```
***Insight:*** Wired Headphones had the highest numbers, followed by Apple, then Bose headphones.

**Question:** What was the best seller in terms of quantity in February?

**Approach:** Grouped by `Product` and used `SUM(Quantity)`
```
SELECT Product, sum(Quantity) FROM BIT_DB.FebSales 
GROUP BY Product
ORDER BY sum(Quantity) desc
```
***Insight:*** AAA batteries had the highest number of sales

### **3..Pricing and Revenue Insights**
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
***Insight:***
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


## Conclusion
- **Order Volume:** January saw 9268 orders, with February seeing a 24% increase.
- **Popular Products:** The Macbook Pro laptop was a high performer leading both January and February in terms of revenue. The item with the most units sold were AAA batteries.
- **Customer Trends:** X% of customers from January returned in February.
- **Geographic Insights:** Los Angeles and Seattle were key sales locations.
- **Revenue Insights:** The highest revenue-generating product in January was [Product Name].

## Next Steps
- **Customer Retention Strategies:** Offer promotions to encourage repeat purchases.
- **Product Stocking Strategy:** Ensure high-demand products are well-stocked.
- **Location-Specific Marketing:** Optimize marketing efforts based on regional demand.
