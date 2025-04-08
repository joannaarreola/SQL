# Layoffs Analysis

## Objective
The goal of this project is to analyze Spotify's Top 50 song dataset using SQL to uncover trends in music popularity, artist performance, and song characteristics. By performing various queries, we aim to identify the most popular artists, explore correlations between musical features, and rank songs based on key metrics

## Dataset Overview
**Dataset Source:** The dataset used in this project was obtained from Alex the Analyst's Data Analytics Course and can be found in the same folder as this project as a json file.

The dataset consists of a single table:

`layoffs`: Contains information about layoffs in companies from around the world ranging from 2020 to 2023.

Key columns include:

- `company`: company name.
- `location`: city or greater location attribute.
- `industry`: industry category for the company.
- `total_laid_off`: total number of people laid off.
- `percentage_laid_off`: percentage of the total company employees laid off.
- `date`: date of the layoff.
- `stage`: company funding stage.
- `country`: country name.
- `funds_raised_millions`: funds raised by the company in millions of dollars.

## Data Cleaning

### **1. Remove Duplicates**
**A. Create staging stable**
- First we create a staging table in order to edit the dataset while keeping the raw data intact.
```
create table layoffs_staging as
select * from layoffs;
```
**B. Identify duplicate rows**
- Next we use a cte to add a row_num column and filter based on this column. We create the row_num column in such a way that it identifies repeat instances of rows with the same values across all the columns specified.
```
with duplicate_cte as (
select *,
row_number() over(
partition by company, location, industry, total_laid_off,
percentage_laid_off, `date`, stage, country, funds_raised_millions) as row_num
from layoffs_staging
)
select * from duplicate_cte
where row_num > 1;
```

**C. Copy the data into a new table**
- Next we copy the data with the newly created row_num column into a new table.
```
CREATE TABLE "layoffs_staging2" (
    company text,
    location text,
    industry text,
    total_laid_off int,
    percentage_laid_off text,
    date date,
    stage text,
    country text,
    funds_raised_millions int,
    row_num int
);

insert into layoffs_staging2
select *,
row_number() over(
partition by company, location, industry, total_laid_off,
percentage_laid_off, `date`, stage, country, funds_raised_millions) as row_num
from layoffs_staging;
```
**D. Delete duplicate entries**
- Latslty we delete the duplicate entries we identified earlier
```
delete from layoffs_staging2
where row_num > 1;
```

### **2. Data Standardization**
A. Update the company column
- Use trim to remove any leading or trailing spaces
```
update layoffs_staging2
set company = trim(company);
```
B. Update the industry column
- Update all companies in the crypto industry to have a consistent value 
```
update layoffs_staging2
set industry = 'Crypto'
where industry like 'Crypto%';
```
C. Update the country column
- Remove any trailing periods for companies in the United states
```
UPDATE layoffs_staging2
SET country = CASE
    WHEN country LIKE 'United States%' AND SUBSTR(country, LENGTH(country), 1) = '.'
    THEN SUBSTR(country, 1, LENGTH(country) - 1)
    ELSE country
END
WHERE country LIKE 'United States%';
```
D. Update the date column
```
UPDATE layoffs_staging2
SET "date" = 
    DATE(substr("date", 7, 4) || '-' || substr("date", 1, 2) || '-' || substr("date", 4, 2))
WHERE "date" LIKE '%/%/%';
```
### **3. Address Null Values**
### **4. Column Removal**



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
