## BRFSS Smoking Analysis SQL Output

The following are selected SQL outputs from the full script that validate and highlight key findings in the analysis

### SQL Scripts & Output

-- Percentage calculations for smoking status by demographic

-- Pattern: group by demographic, use window function to sum counts per education category and compute % per status, exclude unknowns when present

```
select 
_educag, 
_smoker3, 
concat(round((count(*)/(sum(count(*)) over(partition by _educag)))*100, 2), '%') as '%'
from cleaned_brfss2023
where _educag != 'Unknown'
group by _educag, _smoker3
order by _educag,_smoker3;
```
<img width="392" height="273" alt="Screen Shot 2025-12-03 at 12 59 46 PM" src="https://github.com/user-attachments/assets/57c0c386-6165-4af9-a58e-bb3baf18efb0" />

-- The % of current smokers decreases as education level increases

```
select  
region,
_smoker3, 
concat(round((count(*)/(sum(count(*)) over(partition by region)))*100, 2), '%') as '%'
from cleaned_brfss2023
group by region, _smoker3
order by region, _smoker3;
```
<img width="281" height="334" alt="Screen Shot 2025-12-03 at 1 02 03 PM" src="https://github.com/user-attachments/assets/b769a18f-a00d-49fd-bd15-f190a925b92b" />

-- Midwest and Southern regions have the highest % of current smokers

```
select  
sexvar,
_smoker3, 
concat(round((count(*)/(sum(count(*)) over(partition by sexvar)))*100, 2), '%') as '%'
from cleaned_brfss2023
group by sexvar, _smoker3
order by sexvar, _smoker3;
```
<img width="249" height="153" alt="Screen Shot 2025-12-03 at 1 03 12 PM" src="https://github.com/user-attachments/assets/c7f35752-ab24-4a00-af93-f875ad9edfce" />

-- Males have a higher % of current smokers

```
select 
_ageg5yr, 
_smoker3, 
concat(round((count(*)/(sum(count(*)) over(partition by _ageg5yr)))*100, 2), '%') as '%'
from cleaned_brfss2023
where _ageg5yr != 'Unknown'
group by _ageg5yr, _smoker3
order by _ageg5yr,_smoker3;
```
<img width="249" height="331" alt="Screen Shot 2025-12-03 at 1 04 26 PM" src="https://github.com/user-attachments/assets/1483d860-b88c-43bb-9986-609bac2caa45" />

-- Current smoker % increases into the 40s stays around the same until the 60s and goes back down again

```
select 
_incomg1, 
_smoker3, 
concat(round((count(*)/(sum(count(*)) over(partition by _incomg1)))*100, 2), '%') as '%'
from cleaned_brfss2023
where _incomg1 != 'Unknown'
group by _incomg1, _smoker3
order by _incomg1,_smoker3;
```
<img width="320" height="333" alt="Screen Shot 2025-12-03 at 1 05 40 PM" src="https://github.com/user-attachments/assets/41c4bac0-cfb9-4ba6-899a-7023b9837c89" />

-- The % of current smokers decreases as income level increases

```
select 
_racegr3, 
_smoker3, 
concat(round((count(*)/(sum(count(*)) over(partition by _racegr3)))*100, 2), '%') as '%'
from cleaned_brfss2023
where _racegr3 != 'Unknown'
group by _racegr3, _smoker3
order by _racegr3,_smoker3;
```
<img width="335" height="332" alt="Screen Shot 2025-12-03 at 1 06 33 PM" src="https://github.com/user-attachments/assets/2acaa7b4-e481-4f89-9e53-4692b68844f6" />

-- Current smoking % is highest among Multiracial Non-Hispanics, and lowest among Hispanics

-- Calculate the % for each smoking status by income and education combined
```
select 
_educag,
_incomg1, 
_smoker3, 
concat(round((count(*)/(sum(count(*)) over(partition by _educag, _incomg1)))*100, 2), '%') as '%'
from cleaned_brfss2023
where _incomg1 != 'Unknown' and _educag != 'Unknown'
group by _educag, _incomg1, _smoker3
order by _educag, _incomg1, _smoker3;
```
<img width="501" height="333" alt="Screen Shot 2025-12-03 at 1 07 45 PM" src="https://github.com/user-attachments/assets/131f4467-67ac-4460-88ab-e1b3144705f1" />

-- The highest rates of current smoking are observed in the lowest education levels and income levels

-- Rank all demographic categories by combined current smoking to identify top 5 high-risk groups

-- Uses CTEs for each demographic variable, then UNION ALL to combine

-- Calculates % current smokers per category and overall ranking
```
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
```
<img width="462" height="109" alt="Screen Shot 2025-12-03 at 1 10 04 PM" src="https://github.com/user-attachments/assets/48b7937d-4740-416c-8b72-e3daad844df4" />

-- Calculate decrease in combined current smoking across ordered income levels
```
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
```
<img width="351" height="141" alt="Screen Shot 2025-12-03 at 1 11 17 PM" src="https://github.com/user-attachments/assets/9ec28825-cff6-4b81-8e07-118ec9ae5702" />

-- The biggest decrease in current smoking levels occurs from income level <$15,000 to $15,000 - <$25,000

-- There is a steady decrease in middle income levels

-- Calculate decrease in combined current smoking across ordered education levels
```
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
```
<img width="420" height="95" alt="Screen Shot 2025-12-03 at 1 12 03 PM" src="https://github.com/user-attachments/assets/c57b2c31-1a26-4b1b-bad4-885182555909" />

-- The biggest decrease in current smoking levels occurs from education level Attended College/Technical school to Graduated College/Technical school

-- The second biggest decrease in current smoking levels occurs from education level Did not graduate High school to Graduated High School

