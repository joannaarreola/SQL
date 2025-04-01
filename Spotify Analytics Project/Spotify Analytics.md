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

Created a structured SQL table with appropriate data types and constraints.

- Defined appropriate data types for each column to ensure consistency and accuracy.
- Used `INTEGER`, `DECIMAL`, and `VARCHAR` data types based on the nature of each attribute.
- Set `NOT NULL` constraints to enforce data integrity.
``` 
CREATE TABLE BIT_DB.Spotifydata (
id integer PRIMARY KEY,
artist_name varchar NOT NULL,
track_name varchar NOT NULL,
track_id varchar NOT NULL,
popularity integer NOT NULL,
danceability decimal(4,3) NOT NULL,
energy decimal(4,3) NOT NULL,
song_key integer NOT NULL,
loudness decimal(5,3) NOT NULL,
song_mode integer NOT NULL,
speechiness decimal(5,4) NOT NULL,
acousticness decimal(6,5) NOT NULL,
instrumentalness decimal(8,7) NOT NULL,
liveness decimal(5,4) NOT NULL,
valence decimal(4,3) NOT NULL,
tempo decimal(6,3) NOT NULL,
duration_ms integer NOT NULL,
time_signature integer NOT NULL )
```

Loaded the CSV File into SQL:

- Inserted the data into the structured table.
- Ensured that the data was correctly mapped to the defined schema.
- During the import process, two rows were skipped due to datatype mismatches. These rows contained values that did not align with the defined schema and were omitted to maintain data integrity.

Initial Exploration:
- Verified that the data loaded correctly by running SELECT queries to inspect the first few rows.

## Key Business Questions and analysis

### **1. Music Popularity**
Rank songs based on their popularity and streaming performance.
A. Trends in Music Popularity
Top 10 Most Popular Songs by Streams:
This will allow you to see which songs are performing best in terms of overall popularity.

Average Popularity of Songs by Genre:
If your dataset includes genre data, this query can help explore how different genres are performing.

Rank Songs by Popularity Score:
If your dataset includes a popularity score, you can rank the songs directly based on this metric.

Rank Songs by Streams:
You might also want to rank based on total streams to see which tracks have the most plays.
**Question:** How many unique orders were placed in January? in February?

**Approach:** Used `COUNT(orderID)` with filters to clean data.
```
SELECT COUNT(distinct orderID) FROM BIT_DB.JanSales
WHERE length(orderid) = 6
AND orderid <> 'Order ID';
```
***Insight:*** A total of 9268 orders were placed in January. 11507 orders were placed in February. Order volume increased by 24% from January to February.

### **1. Artist Performance** 
Identify the most popular artists by the number of songs they have in the top 50, total streams, or popularity.
Top 10 Artists with Most Songs in the Top 50:
This will show which artists have the highest number of songs in the top 50, which is a good indicator of an artist's overall performance.

Top 10 Artists by Total Streams:
Identify which artists have the most streams across all their songs in the Top 50.
### **1. Song Characteristics** 
Explore correlations between various musical features such as energy, danceability, tempo, loudness, and popularity.
Correlations Between Danceability and Popularity:
Are songs that are more danceable generally more popular?

Energy vs. Popularity:
Explore whether higher energy levels correlate with popularity.

Valence (Positivity) and Popularity:
Does a more positive (or happier) song tend to be more popular?

Average Tempo of Top 50 Songs:
Get a sense of the tempo distribution in the Top 50.

Rank Songs by Danceability:
You could rank the songs based on their danceability score to see if more danceable songs tend to be more popular.


## Conclusion
**Order Volume:**
Which genres and artists are leading the charts.

The key features (like danceability, energy, or tempo) that are most strongly correlated with popularity.

Any trends or patterns, like whether songs with higher tempo are generally more popular, or if certain artists dominate the charts in terms of number of songs or total streams.





