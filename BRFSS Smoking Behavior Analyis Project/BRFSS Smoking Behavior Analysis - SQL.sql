-- SQL Analysis Summary:
-- Validated Python findings
-- Calculated % smoking by demographic and socioeconomic categories
-- Ranked top 5 high-risk demographic groups
-- Analyzed income and education gradients


-- Create the brfss_2023 database and import the cleaned dataset as a table
CREATE DATABASE brfss_2023;
USE brfss_2023;

-- Data loading checks
select count(*) from cleaned_brfss2023;
-- There are 410187 rows, all rows from the cleaned dataset were loaded successfully

-- Check that all expected categories appear in each demographic variable
-- Ensures no categories were lost during cleaning or import
select distinct _state from cleaned_brfss2023;
select distinct sexvar from cleaned_brfss2023;
select distinct _ageg5yr from cleaned_brfss2023;
select distinct _incomg1 from cleaned_brfss2023;
select distinct _educag from cleaned_brfss2023;
select distinct _racegr3 from cleaned_brfss2023;
select distinct _smoker3 from cleaned_brfss2023;
select distinct region from cleaned_brfss2023;

-- Count unknown values for key demographics
-- These will be excluded from % calculations or rankings
select  
sum(case when _ageg5yr = 'Unknown' then 1 else 0 end) as age_unknown_count, 
sum(case when _incomg1 = 'Unknown' then 1 else 0 end) as income_unknown_count, 
sum(case when _educag = 'Unknown' then 1 else 0 end) as education_unknown_count, 
sum(case when _racegr3 = 'Unknown' then 1 else 0 end) as race_unknown_count 
from cleaned_brfss2023;
-- 6462 age unknowns
-- 72967 income unknowns
-- 1756 education unknowns
-- 8281 race unknowns
-- Provides insight into missing data distribution

-- Examine counts for each value in each variable
-- Pattern: group by variable, calculate count() per variable

select _smoker3, count(*) from cleaned_brfss2023
group by _smoker3
order by count(*) desc;

select _state, count(*) from cleaned_brfss2023
group by _state
order by count(*) desc;

select sexvar, count(*) from cleaned_brfss2023
group by sexvar
order by count(*) desc;

select _ageg5yr, count(*) from cleaned_brfss2023
group by _ageg5yr
order by count(*) desc;

select _incomg1, count(*) from cleaned_brfss2023
group by _incomg1
order by count(*) desc;

select _educag, count(*) from cleaned_brfss2023
group by _educag
order by count(*) desc;

select _racegr3, count(*) from cleaned_brfss2023
group by _racegr3
order by count(*) desc;

select region, count(*) from cleaned_brfss2023
group by region
order by count(*) desc;

-- Percentage calculations for smoking status by demographic
-- Pattern: group by demographic, use window function to sum counts per education category and compute % per status, exclude unknowns when present

select 
_educag, 
_smoker3, 
concat(round((count(*)/(sum(count(*)) over(partition by _educag)))*100, 2), '%') as '%'
from cleaned_brfss2023
where _educag != 'Unknown'
group by _educag, _smoker3
order by _educag,_smoker3;
-- The % of current smokers decreases as education level increases

select  
region,
_smoker3, 
concat(round((count(*)/(sum(count(*)) over(partition by region)))*100, 2), '%') as '%'
from cleaned_brfss2023
group by region, _smoker3
order by region, _smoker3;
-- Midwest and Southern regions have the highest % of current smokers

select  
sexvar,
_smoker3, 
concat(round((count(*)/(sum(count(*)) over(partition by sexvar)))*100, 2), '%') as '%'
from cleaned_brfss2023
group by sexvar, _smoker3
order by sexvar, _smoker3;
-- Males have a higher % of current smokers

select 
_ageg5yr, 
_smoker3, 
concat(round((count(*)/(sum(count(*)) over(partition by _ageg5yr)))*100, 2), '%') as '%'
from cleaned_brfss2023
where _ageg5yr != 'Unknown'
group by _ageg5yr, _smoker3
order by _ageg5yr,_smoker3;
-- Current smoker % increases into the 40s stays around the same until the 60s and goes back down again

select 
_incomg1, 
_smoker3, 
concat(round((count(*)/(sum(count(*)) over(partition by _incomg1)))*100, 2), '%') as '%'
from cleaned_brfss2023
where _incomg1 != 'Unknown'
group by _incomg1, _smoker3
order by _incomg1,_smoker3;
-- The % of current smokers decreases as income level increases

select 
_racegr3, 
_smoker3, 
concat(round((count(*)/(sum(count(*)) over(partition by _racegr3)))*100, 2), '%') as '%'
from cleaned_brfss2023
where _racegr3 != 'Unknown'
group by _racegr3, _smoker3
order by _racegr3,_smoker3;
-- Current smoking % is highest among Multiracial Non-Hispanics, and lowest among Hispanics

-- Calculate the % of "Never smoked" status per state
select 
_state, 
round(
sum(case when _smoker3 = 'Never smoked' then 1 else 0 end)
/(count(*))*100, 2) as never_smoked_pct
from cleaned_brfss2023
group by _state
order by never_smoked_pct desc;
-- The highest % of non-smoking is observed in the Virgin Islands, Puerto Rico, and Utah. The lowest is observed in Tennessee, Maine, and West Virginia


-- Calculate the combined % of "Current smoker" status per state
select 
_state, 
round(
sum(case when _smoker3 in ('Current smoker - every day', 'Current smoker - some days') then 1 else 0 end)
/(count(*))*100, 2) as combined_current_smoker_pct
from cleaned_brfss2023
group by _state
order by combined_current_smoker_pct desc;
--  The highest % of current smokers is observed in West Virginia, Guam, and Tennessee. The lowest is observed in District of Columbia, Utah, and Virgin Islands

-- Calculate the % for each smoking status by income and education combined
select 
_educag,
_incomg1, 
_smoker3, 
concat(round((count(*)/(sum(count(*)) over(partition by _educag, _incomg1)))*100, 2), '%') as '%'
from cleaned_brfss2023
where _incomg1 != 'Unknown' and _educag != 'Unknown'
group by _educag, _incomg1, _smoker3
order by _educag, _incomg1, _smoker3;
-- The highest rates of current smoking are observed in the lowest education levels and income levels


-- Rank all demographic categories by combined current smoking to identify top 5 high-risk groups
-- Uses CTEs for each demographic variable, then UNION ALL to combine
-- Calculates % current smokers per category and overall ranking
-- CTE 'sex': calculates % current smokers by sex
with sex as(
select
'sex' as variable, 
sexvar as category, 
round(
sum(case when _smoker3 in ('Current smoker - every day', 'Current smoker - some days') then 1 else 0 end)
/(count(*))*100, 2) as combined_current_smoker_pct
from cleaned_brfss2023
group by sexvar
),
-- CTE 'age': calculates % current smokers by age group, excluding unknowns
age as(
select 
'age' as variable, 
_ageg5yr as category, 
round(
sum(case when _smoker3 in ('Current smoker - every day', 'Current smoker - some days') then 1 else 0 end)
/(count(*))*100, 2) as combined_current_smoker_pct
from cleaned_brfss2023
where _ageg5yr != 'Unknown'
group by _ageg5yr
),
-- CTE 'income': calculates % current smokers by income group, excluding unknowns
income as(
select 
'income' as variable,
_incomg1 as category, 
round(
sum(case when _smoker3 in ('Current smoker - every day', 'Current smoker - some days') then 1 else 0 end)
/(count(*))*100, 2) as combined_current_smoker_pct
from cleaned_brfss2023
where _incomg1 != 'Unknown'
group by _incomg1
),
-- CTE 'education': calculates % current smokers by education, excluding unknowns
education as(
select 
'education' as variable,
_educag as category, 
round(
sum(case when _smoker3 in ('Current smoker - every day', 'Current smoker - some days') then 1 else 0 end)
/(count(*))*100, 2) as combined_current_smoker_pct
from cleaned_brfss2023
where _educag != 'Unknown'
group by _educag
),
-- CTE 'race': calculates % current smokers by race, excluding unknowns
race as(
select 
'race' as variable,
_racegr3 as category, 
round(
sum(case when _smoker3 in ('Current smoker - every day', 'Current smoker - some days') then 1 else 0 end)
/(count(*))*100, 2) as combined_current_smoker_pct
from cleaned_brfss2023
where _racegr3 != 'Unknown'
group by _racegr3
)
select 
variable,
category,
combined_current_smoker_pct,
rank() over(order by combined_current_smoker_pct desc) as overall_ranking -- RANK() assigns overall ranking based on highest % of current smokers
from( 
select * from sex
union all
select * from age
union all
select * from income
union all
select * from education
union all
select * from race
) all_demographics -- UNION ALL combines all demographic categories for overall ranking
order by combined_current_smoker_pct desc;
-- The top 5 are:
-- income level: <$15,000
-- education level: Did not graduate High School
-- income level: $15,000 - <$25,000
-- race: Multiracial, Non-Hispanic
-- education level: Graduated High School

-- Calculate decrease in combined current smoking across ordered income levels
-- Step 1: Assign numeric order to income levels using CASE statement
-- Step 2: Calculate % current smokers per income level
-- Step 3: Compute difference with next income level using LEAD() to identify largest drops
with ordered_incomes as(
select 
case 
    when _incomg1 = '<$15,000' then 1
    when _incomg1 = '$15,000 - <$25,000' then 2
    when _incomg1 = '$25,000 - <$35,000' then 3
    when _incomg1 = '$35,000 - <$50,000' then 4 
    when _incomg1 = '$50,000 - <$100,000' then 5
    when _incomg1 = '$100,000 - <$200,000' then 6
    when _incomg1 = '$200,000+' then 7
end as income_order, 
_incomg1, 
round(
sum(case when _smoker3 in ('Current smoker - every day', 'Current smoker - some days') then 1 else 0 end)
/(count(*))*100, 2) as combined_current_smoker_pct 
from cleaned_brfss2023
where _incomg1 != 'Unknown'
group by _incomg1
order by income_order
)
select  
_incomg1, 
combined_current_smoker_pct,  
(combined_current_smoker_pct - lead(combined_current_smoker_pct) over(order by income_order)) as pct_change 
from ordered_incomes
order by income_order;
-- The biggest decrease in current smoking levels occurs from income level <$15,000 to $15,000 - <$25,000
-- There is a steady decrease in middle income levels

-- Calculate decrease in combined current smoking across ordered education levels
-- Step 1: Assign numeric order to education levels using CASE statement
-- Step 2: Calculate % current smokers per education level
-- Step 3: Compute difference with next education level using LEAD() to identify largest drops
with ordered_education as(
select 
case 
    when _educag = 'Did not graduate High School' then 1
    when _educag = 'Graduated High School' then 2
    when _educag = 'Attended College/Technical school' then 3
    when _educag = 'Graduated College/Technical school' then 4 
end as education_order,
_educag, 
round(
sum(case when _smoker3 in ('Current smoker - every day', 'Current smoker - some days') then 1 else 0 end)
/(count(*))*100, 2) as combined_current_smoker_pct 
from cleaned_brfss2023
where _educag != 'Unknown'
group by _educag
order by education_order
)
select  
_educag, 
combined_current_smoker_pct,  
(combined_current_smoker_pct - lead(combined_current_smoker_pct) over(order by education_order)) as pct_change 
from ordered_education
order by education_order;
-- The biggest decrease in current smoking levels occurs from education level Attended College/Technical school to Graduated College/Technical school
-- The second biggest decrease in current smoking levels occurs from education level Did not graduate High school to Graduated High School



