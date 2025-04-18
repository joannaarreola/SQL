# Layoffs Analysis

## Objective
The objective of this project is to perform comprehensive data cleaning and conduct initial exploratory data analysis (EDA) on a dataset containing information about layoffs from companies around the world. This includes identifying and handling missing or erroneous data, transforming variables as needed, and summarizing key statistics to uncover patterns and trends related to layoffs, such as industry, location, and time-based factors. The goal is to ensure the dataset is clean and ready for deeper analysis or modeling by addressing data quality issues and gaining an initial understanding of the key insights and relationships within the data.

## Dataset Overview
**Dataset Source:** The dataset used in this project was obtained from Alex the Analyst's Data Analytics Course and can be found in the same folder as this project as a csv file.

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
create table layoffs_staging
like layoffs;

insert layoffs_staging
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
- We create a new table `layoffs_staging2` to store the data with the newly calculated row_num column, which helps in identifying and removing duplicate entries
```
CREATE TABLE `layoffs_staging2` (
    `company` text,
    `location` text,
    `industry` text,
    `total_laid_off` int DEFAULT NULL,
    `percentage_laid_off` text,
    `date` date,
    `stage` text,
    `country` text,
    `funds_raised_millions` int DEFAULT NULL,
    `row_num` int
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

insert into layoffs_staging2
select *,
row_number() over(
partition by company, location, industry, total_laid_off,
percentage_laid_off, `date`, stage, country, funds_raised_millions) as row_num
from layoffs_staging;
```
**D. Delete duplicate entries**
- Lastly we delete the duplicate entries identified earlier by filtering the `row_num` column
```
delete from layoffs_staging2
where row_num > 1;
```

### **2. Data Standardization**
**A. Update the company column**
- Use trim to remove any leading or trailing spaces
- Other columns were check but only the `industry` column appeared to have this issue
```
update layoffs_staging2
set company = trim(company);
```
**B. Update the industry column**
- Update all companies in the crypto industry to have a consistent value
- Other columns and values in the industry column were checked, but only the crypto industry appeared to have this issue
```
update layoffs_staging2
set industry = 'Crypto'
where industry like 'Crypto%';
```
**C. Update the country column**
- Remove any trailing periods for companies in the United states
- Other columns and vaues in the country column were checked, but only the United states value appeared to have this issue
```
update layoffs_staging2
set country = trim(trailing '.' from country)
where country like 'United States%';
```
**D. Change the date column to a date datatype**
- First change the text string to a date, then cast to date datatype
- All other columns were of the correct data type
```
update layoffs_staging2
set `date` = str_to_date(`date`, '%m/%d/%Y');

alter table layoffs_staging2
modify column `date` date;
 ```
### **3. Address Null Values**
**A. Identify null values**
- We use the industry column since we can populate some of these values
```
select * from layoffs_staging2
where industry is null
or industry = '';
```
**B. Convert blanks into nulls**
- We convert the blanks into nulls in order to work will them more easily
```
update layoffs_staging2
set industry = null
where industry = '';
```
**C. Populate values for nulls**
- We use values from other rows to populate missing industry values for rows of the same company
```
update layoffs_staging2 t1
join layoffs_staging2 t2
on t1.company = t2.company
set t1.industry = t2.industry
where t1.industry is null
and t2.industry is not null;
```

### **4. Row & Column Removal**
**A. Identify and remove unecessary rows**
- Rows without sufficient layoff data including totals and percentages will not be useful for our analysis
```
select * from layoffs_staging2
where total_laid_off is null
and percentage_laid_off is null;

delete from layoffs_staging2
where total_laid_off is null
and percentage_laid_off is null;
```
B. Remove unecessary columns
- We remove the previously created row_num column as it was for data cleaning purposes only
```
alter table layoffs_staging2
drop column row_num;
```

## Exploratory Data Analysis

**Question:** What were the maximum number of people and percentage of the total company laid off in one round of layoffs?

**Approach:** 
```
select max(total_laid_off), max(percentage_laid_off) from layoffs_staging2;
```
***Insight:***  
- The maximum number of people laid off was 12000
- The maximum percent laid off was 100%

**Question:** Which companies went completely under? (percent laid off = 100%)

**Approach:** 
```
select * from layoffs_staging2
where percentage_laid_off = 1;
```

***Insight:*** A lot of the companies that went out of business were start-ups.

**Question:** What are the layoff totals per company?

**Approach:** 
```
select company, sum(total_laid_off) from layoffs_staging2
group by company
order by 2 desc;
```

**Question:** What is the date range of this dataset?

**Approach:** 
```
select min(`date`), max(`date`) from layoffs_staging2;
```
***Insight:*** The date range is 3/11/2020 to 3/6/2023

**Question:** What industry was most affected by these layoffs?

**Approach:** 

```
select industry, sum(total_laid_off) from layoffs_staging2
group by industry
order by 2 desc;
```

***Insight:*** The consumer industry was most affected by the layoffs in this dataset

**Question:** Which country was most affected by these layoffs?

**Approach:** 

```
select country, sum(total_laid_off) from layoffs_staging2
group by country
order by 2 desc;
```

***Insight:*** The United States was most affected by the layoffs in this dataset

**Question:** What were the total layoffsper year?

**Approach:** 

```
select year(`date`), sum(total_laid_off) from layoffs_staging2
group by year(`date`)
order by 1 desc;
```

**Question:** Display a rolling sum of layoffs by month

**Approach:** 

```
with rolling_total as(
select substring(`date`, 1, 7) as `month` , sum(total_laid_off) as total_off
from layoffs_staging2
where substring(`date`, 1, 7) is not null
group by `month`
order by 1 asc
)
select `month`, total_off, sum(total_off) over(order by `month`) as rolling_total2
from rolling_total;
```

***Insight:*** The biggest jumps in layoff numbers occurred in 2022

**Question:** Display the top 5 companies that laid off the most employees per year

**Approach:** 

```
with company_year (company, years, total_laid_off) as (
select company, year(`date`), sum(total_laid_off)
from layoffs_staging2
group by company, year(`date`)
),
company_year_rank as(
select *,
dense_rank() over(partition by years order by total_laid_off desc) as ranking
from company_year
where years is not null
)
select * from company_year_rank
where ranking <= 5;
```
  
## Conclusion
- Through the data cleaning process, we addressed missing values, corrected inconsistencies, and ensured the dataset is in a usable format.
- The initial exploratory data analysis revealed trends in layoffs related to industry, region, and time period:
    - A lot of the companies that went out of business were start-ups
    - The date range is 3/11/2020 to 3/6/2023, with the biggest monthly increases in layoff numbers occurring in 2022
    - The consumer industry was most affected by layoffs
    - The United States was most affected by layoffs

## Next steps
- Next steps will involve conducting more detailed analysis to identify the key drivers of layoffs and potential predictive modeling.
- We may also look into segmenting the data by company size or explore additional factors, such as economic or political events, that could explain layoff trends.

