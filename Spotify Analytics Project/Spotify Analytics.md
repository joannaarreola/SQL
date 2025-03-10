# Spotify Analytics

## Objective
The goal of this project is to analyze Spotify's Top 50 song dataset using SQL to uncover trends in music popularity, artist performance, and song characteristics. By performing various queries, we aim to identify the most popular artists, explore correlations between musical features, and rank songs based on key metrics

## Dataset Overview
**Dataset Source:** The dataset used in this project was obtained from Break Into Tech's Data Analytics Certificate Course and can be found in the same folder as this project.

The dataset consists of a single table:

Spotifydata: Contains information about the top 50 most popular songs on Spotify, including their artist, track name, popularity score, and various musical attributes such as danceability, energy, loudness, and tempo.
Key columns include:

id: Unique identifier for each song.
artist_name: Name of the artist.
track_name: Title of the song.
popularity: Popularity score of the song (higher means more popular).
danceability: A score representing how suitable the song is for dancing.
energy: A measure of the song’s intensity and activity level.
loudness: The overall loudness of the track in decibels (dB).
tempo: The speed of the song, measured in beats per minute (BPM).
duration_ms: Song duration in milliseconds.

## Data Cleaning
Before analyzing the dataset, we need to clean the orderID column, which contains missing and potentially invalid values. Specifically:
- Some rows have missing Order IDs. These should be removed.
- Valid Order IDs should always be 6-character alphanumeric values.

To ensure only valid Order IDs are included in our analysis, we will filter the data using the following SQL condition:
```
WHERE length(order_id) = 6
AND order_id <> 'Order ID'
```
This ensures that Order IDs are exactly 6 characters long (filtering out missing or incorrectly formatted entries).

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

### **3. Location-based Sales Analysis**
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

***Insight:*** The top 3 cities were San Francisco, Los Angeles, and New York City in both months. Revenue for San Francisco was 1.5x that of Los Angeles. Los Angeles and New York brought in similar numbers. The city that generated the least revenue was Austin in both months.

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

### **4. Customer Behavior**
**Question:** How many customers placed orders in January and February?

**Approach:** Used `DISTINCT` to count unique customer account numbers.
```
SELECT count(distinct acctnum) FROM BIT_DB.customers
INNER JOIN BIT_DB.JanSales
on customers.order_id = JanSales.orderid
WHERE length(JanSales.orderid) = 6
AND JanSales.orderid <> 'Order ID';
```
*Repeat for February*

***Insight:*** 9681 unique customers placed orders in January. 11986 unique customers placed orders in January. There was an increase of 24% customers from January to February

**Question:** How many repeat customers were there from January to February? 

**Approach:** Used joins to join both months to the `customers` table and used `COUNT(DISTINCT acctnum)`.
```
SELECT count(DISTINCT customers.acctnum)
FROM BIT_DB.customers
JOIN BIT_DB.JanSales jan ON customers.order_id = jan.orderid
JOIN BIT_DB.FebSales feb ON customers.order_id = feb.orderid
;
```
***Insight:*** 34 customers were repeat customers.

**Question:** What was the average quantity of products purchased per account?

**Approach:** Used `COUNT(DISTINCT acctnum)` and `SUM(Quantity)`.
```
SELECT SUM(Quantity)/COUNT(acctnum) FROM BIT_DB.JanSales
LEFT JOIN BIT_DB.customers 
ON JanSales.orderid=customers.order_id
WHERE length(orderid) = 6 
AND orderid <> 'Order ID'
```
*Repeat for February*

***Insight:*** The average quantity of products purchased per account was 1 in both January and February

**Question:** How many customers ordered more than 2 products at a time? 

**Approach:** Used `COUNT(DISTINCT acctnum)` and filtered to `Quantity` >= 2.
```
SELECT COUNT(distinct customers.acctnum) FROM BIT_DB.JanSales
LEFT JOIN BIT_DB.customers
ON JanSales.orderid = customers.order_id 
WHERE JanSales.Quantity >= 2
AND length(orderid) = 6
AND orderid <> 'Order ID';
```
*Repeat for February*

***Insight:*** 932 customers ordered 2 or more items in January. 1172 customers ordered 2 or more items in February. This is ~9.7% of all customers 

**Question:** What was the average amount spent per account in February? 

**Approach:** Divided `SUM(Quantity * price) by `COUNT(DISTINCT acctnum)`.
```
SELECT SUM(Quantity*price)/COUNT(distinct acctnum) FROM BIT_DB.JanSales 
LEFT JOIN BIT_DB.customers
ON JanSales.orderid = customers.order_id 
WHERE length(orderid) = 6
AND orderid <> 'Order ID';
```
*Repeat for February*

***Insight:*** An average of $210 was spent per account in January. An average of $206 was spent per account in February.

## Conclusion
**Order Volume:**
  - There was a 24% increase in orders from January to February.

**Popular Demand:**
  - The Macbook Pro laptop was a high performer leading both January and February in terms of revenue.
  - The most popular product in the headphones category was wired headphones, outperforming Apple and Bose headphones
  - The item with the most units sold were AAA batteries.

**Geographic Insights:**
  - The top revenue-generating cities were San Francisco, Los Angeles, and New York City in that order for both months
  - San Francisco's revenue was ~1.5x that of Los Angeles. Revenue in New York City was similar to Los Angeles.
  - Austin generated the least revenue
  - The top products in the top cities were the Macbook Pro Laptop, iPhone, Google Phone, and ThinkPad Laptop.

**Customer Trends:**
  - There was an increase of 24% customers from January to February
  - February saw 34 repeat customers from January
  - The average customer ordered 1 item with ~9.7% of customers ordering 2 or more products at a time in both January and February
  - The average account spend was $208 for January and February combined, with not much change from one month to the other 

## Next Steps
**Time Series Analysis:**
  - Watch for a change in trends in the upcoming months. January and February are close together and likely won't reflect significant patterns that might change throughout     the year

**Product Stocking Strategy:**
  - Ensure high-demand products well-stocked especially in top regions

**Pricing Strategy:**
  - Analyze profit margins for the top performing Macbook Pro laptop and AAA batteries
  - Consider room for price increases, bundling, or seasonal sales for these high-demand products

**Location-Specific Marketing:**
  - Optimize marketing efforts based on regional demand
  - Consider targeting promotions in Austin to boost revenue there

**Customer Retention Strategies:**
  - Offering special promotions to encourage more repeat customers
  - Bundling deals may help boost the quantity of items sold per order--For this project, I downloaded a Spotify dataset from Kaggle, created a table to insert Spotify data into and performed SQL queries on the data.

--Created the table: 
CREATE TABLE BIT_DB.Spotifydata (
id integer PRIMARY KEY,
artist_name varchar NOT NULL,
track_name varchar NOT NULL,
track_id varchar NOT NULL,
popularity integer NOT NULL,
danceability decimal(4,3) NOT NULL,
energy decimal(4,3) NOT NULL,
key integer NOT NULL,
loudness decimal(5,3) NOT NULL,
mode integer NOT NULL,
speechiness decimal(5,4) NOT NULL,
acousticness decimal(6,5) NOT NULL,
instrumentalness text NOT NULL,
liveness decimal(5,4) NOT NULL,
valence decimal(4,3) NOT NULL,
tempo decimal(6,3) NOT NULL,
duration_ms integer NOT NULL,
time_signature integer NOT NULL 
)

--Inserted Spotify Data .csv into the table.

--Explored the data using the following SQL:

--Question: What artists had more than 1 song on the top 50 chart, and how many songs did they each have?
--Approach: We want to select the artist_name column from the table so we use that in the select statement. We use the count function in order to gather the totals per artist. We use
group by since we used the aggregate count function. Lastly we filter the results with the having clause.

SELECT artist_name, COUNT(artist_name) FROM BIT_DB.Spotifydata
GROUP BY artist_name
HAVING COUNT(artist_name) > 1;


--Question: Which songs on the top 50 were the 5 longest songs and how long were they?
--Approach: We need the song names and durations to answer this question so we use these columns in our select statement. To gather the top 5 we order the results from longest to 
shortest and limit to 5 results.

SELECT track_name, duration_ms FROM BIT_DB.Spotifydata
ORDER BY duration_ms DESC
LIMIT 5;

--Question: Select the top 10 songs and their respective artists in terms of popularity.
--Approach: We want to show the song name and artist so we use these in our select statement. We then, sort the results by popularity and limit the answer to 10.

SELECT artist_name, track_name FROM BIT_DB.Spotifydata
ORDER BY popularity DESC
LIMIT 10;

--Question: What was the average danceability by artist
--Approach: We use the average function to get the average danceability and use the round function to get a more usable result. We group by artist since avg is an aggregate function.

SELECT artist_name, ROUND(AVG(danceability),3) FROM BIT_DB.Spotifydata
GROUP BY artist_name;

--Question: Calculate the average popularity for the artists in the Spotify data table. Then, for every artist with an average popularity of 90 or above,
show their name, their average popularity, and label them as a "Top Star"
--Approach: We use a cte to create a temporary table with the avergae popularity by artist. We then reference that temporary table to retrieve the artists with popularity 90 or above 
using a where clause.

WITH avg_pop_CTE AS (
SELECT s.artist_name, AVG(s.popularity) as avgpop
FROM Spotifydata s
GROUP BY s.artist_name
)

SELECT artist_name, avgpop, 'Top Star' AS tag
FROM avg_pop_CTE
WHERE avgpop >= 90;

