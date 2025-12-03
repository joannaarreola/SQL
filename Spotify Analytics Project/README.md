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

**Question:** What are the top 5 songs by popularity score?

**Approach:** ordered by popularity score and limited to 5
```
select track_name from Spotifydata
order by popularity desc
limit 5;
```
***Insight:*** 

The top 5 songs were:
1. good 4 you
2. Bad Habits
3. Heat Waves
4. Yonaguni
5. Blinding Lights

### **2. Artist Performance** 

**Question:** Calculate the average popularity for the artists in the Spotify data table. Then, for every artist with an average popularity of 90 or above, show their name, their average popularity, and label them as a “Top Star”.

**Approach:** Used a cte to store average popularities and selected those 90 or above
```
with pop_avgs as (
select artist_name, avg(popularity) as avg_pop from Spotifydata
group by artist_name
)

select artist_name, avg_pop, 'Top Star' as tag from pop_avgs
where avg_pop >= 90
order by avg_pop desc;
```
***Insight:*** 

The top stars were:
1. Ed Sheeran
2. Glass Animals
3. Olivia Rodrigo
4. The Neighbourhood
5. The Weeknd
6. Maneskin
7. Harry Styles
8. Justin Bieber
9. Lil Nas X

**Question:** Which artists have more than 1 song in the top 50?

**Approach:** Counted the number of songs per artist and filtered for those appearing more than once.
```
select artist_name from Spotifydata
group by artist_name
having count(artist_name) > 1;
```
***Insight:*** 

The artists with more than one song in the top 50 were:
Ariana Grande
BTS
Bad Bunny
Doja Cat
Dua Lipa
Lil Nas X
Olivia Rodrigo
The Kid LAROI
The Weeknd

**Question:** Which artist has the most songs in the top 50?

**Approach:** Used count(artist_name) and limited to one result
```
select artist_name from Spotifydata
group by artist_name
order by count(artist_name) desc
limit 1;
```
***Insight:*** The artist with the most songs in the top 50 was Olivia Rodrigo

### **3. Song Characteristics** 

**Question:** Are songs that are more danceable generally more popular?

**Approach:** Found the min and max danceabilities to get a sense of the range. Observed the danceabilities of the top songs in comparison to the bottom. Averaged the danceability of the top and bottom 10 songs.

```
select min(danceability), max(danceability) from Spotifydata;

select danceability from Spotifydata
order by popularity desc;

select avg(danceability) from (
    select danceability from Spotifydata 
    order by popularity desc 
    limit 10
) as top_10_avg;

select avg(danceability) from (
    select danceability from Spotifydata 
    order by popularity asc 
    limit 10
) as bottom_10_avg;
```

***Insight:*** 
- Minimum danceability was 0.38 and maximum was 0.903
- The top songs' danceabilities were not starkly different from the bottom songs' danceabilities
- The average danceability of the top 10 songs was 0.62. The average danceability of the bottom 10 songs was 0.76.
- Danceability alone is not a good indication of a song's popularity

Repeat analysis for energy, valence (positivity), and tempo

***Insight:*** 

- Energy, valence, and tempo alone are not good indicators of a song's popularity
  
## Conclusion
**Music Popularity:**
- The top 5 songs were:
1. good 4 you
2. Bad Habits
3. Heat Waves
4. Yonaguni
5. Blinding Lights
   
**Artist Performance:**
- The top artists in terms of popularity were:
1. Ed Sheeran
2. Glass Animals
3. Olivia Rodrigo
4. The Neighbourhood
5. The Weeknd
6. Maneskin
7. Harry Styles
8. Justin Bieber
9. Lil Nas X

- The artists with multiple songs in the top 50 were:
  - Ariana Grande
  - BTS
  - Bad Bunny
  - Doja Cat
  - Dua Lipa
  - Lil Nas X
  - Olivia Rodrigo (the most songs out of all)
  - The Kid LAROI
  - The Weeknd
   
**Song Characteristics:** 
- Danceability, energy, valence, and tempo alone are not good indicators of a song's popularity

## Next steps
- If the goal is simply to analyze the current top 50 songs and artists, this analysis provides a sufficient overview.
- If the objective is to find deeper correlations with popularity, consider expanding the analysis by:
  - Exploring a larger dataset, such as the top 100 songs
  - Examining interactions between different musical features (e.g., how danceability and energy together influence popularity)
  - Developing an artist popularity score based on multiple metrics (e.g., social media metrics, etc.).





