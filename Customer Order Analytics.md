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
**Question:** How many unique orders were placed in January? in February?

**Approach:** Used `COUNT(orderID)` with filters to clean data.
```
SELECT COUNT(distinct orderID) FROM BIT_DB.JanSales
WHERE length(orderid) = 6
AND orderid <> 'Order ID';
```
*Repeat for February*

***Insight:*** A total of 9268 orders were placed in January. 11507 orders were placed in February. Order volume increased by 24% from January to February.

### **2. Product Demand**
**Question:** Which product brought in the most revenue in January and how much revenue did it bring in total? in February?

**Approach:** Used `SUM(price*quantity)` to calculate revenue and sorted by revenue `desc`
```
SELECT Product, SUM(price*quantity) as Revenue FROM BIT_DB.JanSales
GROUP BY Product
ORDER BY Revenue DESC
LIMIT 1;
```
*Repeat for February*

***Insight:*** The Macbook Pro Laptop brought in the most revenue in January at $399,500. The Macbook Pro Laptop also brought in the most revenue in February at $467,500. 

**Question:** How many of each type of headphone were sold in January and February?

**Approach:** Grouped by `Product` and used `SUM(Quantity)`
```
SELECT Product, sum(Quantity) FROM BIT_DB.JanSales 
WHERE Product like '%Headphones%'
GROUP BY Product
```
*Repeat for February*

***Insight:*** Wired Headphones had the highest numbers, followed by Apple, then Bose headphones in both months.

**Question:** What was the best seller in terms of quantity?

**Approach:** Grouped by `Product` and used `SUM(Quantity)`
```
SELECT Product, sum(Quantity) FROM BIT_DB.JanSales 
GROUP BY Product
ORDER BY sum(Quantity) desc
```
*Repeat for February*

***Insight:*** AAA batteries had the highest number of sales

### **5. Location-based Sales Analysis**
**Question:** Which 3 cities brought in the most revenue in January and February? Which city brought in the least revenue?

**Approach:** Used `substr` to filter by city and calculated revenue per city.
```
SELECT 
    substr(location, instr(location, ',') + 1, 
        instr(substr(location, instr(location, ',') + 1), ',') - 1) AS city,
    sum(price*quantity) as revenue
FROM BIT_DB.JanSales
group by city
order by revenue desc
```
*Repeat for February*

***Insight:*** The top 3 cities were San Francisco, Los Angeles, and New York City in both months. Revenue for San Francisco was 1.5 that of Los Angeles. Los Angeles and New York brought in similar numbers. The city that generated the least revenue was Austin in both months.

**Question:** Identify the top performing products in each major revenue-generating city. Are there any differences in preferences?

**Approach:** Used `substr` to filter by city and included product along with revenue per city.
```
SELECT 
    substr(location, instr(location, ',') + 1, 
        instr(substr(location, instr(location, ',') + 1), ',') - 1) AS city,
    product,
    sum(price*quantity) as revenue
FROM BIT_DB.JanSales
group by city, product
order by revenue desc
```
*Repeat for February*

***Insight:*** The top products in San Francisco, Los Angeles and New York City were the Macbook Pro Laptop, iPhone, Google Phone, and ThinkPad Laptop.

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
- **Order Volume**
  - There was a 24% increase in orders from January to February.
- **Popular Demand:**
  - The Macbook Pro laptop was a high performer leading both January and February in terms of revenue.
  - The most popular product in the headphones category was wired headphones, outperforming Apple and Bose headphones
  - The item with the most units sold were AAA batteries.
- **Geographic Insights:**
  - Distribution of sales by location stayed pretty consistent in January and February
  - The top revenue-generating cities were San Francisco, Los Angeles, and New York City in that order for both months
  - San Francisco's revenue was ~1.5x that of Los Angeles. Revenue in New York City was similar to Los Angeles.
  - Austin generated the least revenue
  - The top products in the top cities were the Macbook Pro Laptop, iPhone, Google Phone, and ThinkPad Laptop.
  - **Customer Trends:** X% of customers from January returned in February.


## Next Steps
- **Customer Retention Strategies:** Offer promotions to encourage repeat purchases.
- **Time Series Analysis:** Watch for a change in trends in the upcoming months. January and February are close together and likely won't reflect significant patterns that might change throughout the year.
- **Product Stocking Strategy:** Ensure high-demand products well-stocked especially in top regions.
- **Pricing Strategy:** Analyze profit margins for the top performing Macbook Pro laptop and AAA batteries. Consider room for price increases, bundling, or seasonal sales for these high-demand products
- **Location-Specific Marketing:** Optimize marketing efforts based on regional demand. For example, consider targeting promotions in Austin to boost revenue there.
