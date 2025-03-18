# Spotify Analytics

## Objective
The goal of this project is to analyze Spotify's Top 50 song dataset using SQL to uncover trends in music popularity, artist performance, and song characteristics. By performing various queries, we aim to identify the most popular artists, explore correlations between musical features, and rank songs based on key metrics

## Dataset Overview
**Dataset Source:** The dataset used in this project was obtained from Break Into Tech's Data Analytics Certificate Course and can be found in the same folder as this project as a csv file.

The dataset consists of a single table:

`Spotifydata`: Contains information about the top 50 most popular songs on Spotify, including their artist, track name, popularity score, and various musical attributes such as danceability, energy, loudness, and tempo.

Key columns include:

- `id`: Unique identifier for each song.
- `artist_name`: Name of the artist.
- `track_name`: Title of the song.
- `popularity`: Popularity score of the song (higher means more popular).
- `danceability`: A score representing how suitable the song is for dancing.
- `energy`: A measure of the song’s intensity and activity level.
- `loudness`: The overall loudness of the track in decibels (dB).
- `tempo`: The speed of the song, measured in beats per minute (BPM).
- `duration_ms`: Song duration in milliseconds.

## Data Preparation
Before analyzing the data, I first structured it in a SQL database. I performed the following steps:

Created a Table Schema:

- Defined appropriate data types for each column to ensure consistency and accuracy.
- Used `INTEGER`, `DECIMAL`, and `VARCHAR` data types based on the nature of each attribute.
- Set `NOT NULL` constraints to enforce data integrity.
```
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
```

Loaded the CSV File into SQL:

- Inserted the data into the structured table.
- Ensured that the data was correctly mapped to the defined schema.

Initial Exploration:

- Checked for missing values, duplicates, or incorrect data types.
- Verified that the data loaded correctly by running SELECT queries to inspect the first few rows.

## Data Cleaning


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

## Conclusion
**Order Volume:**


## Next Steps


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

