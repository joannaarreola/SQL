-- SQL Analysis Summary:
-- Data loading checks
-- Overall metrics
-- Channel-level analysis
-- Type-level analysis
-- Type x Channel interaction analysis
-- Target Audience Overview Metrics
-- Campaign-level analysis


-- Create the marketing_campaigns database and import the cleaned dataset as a table
CREATE DATABASE marketing_campaigns;
USE marketing_campaigns;

-- Data loading checks

-- Row count validation
select count(*) from marketing_campaigns;
-- There are 1,000 rows of data. All rows of the csv were imported.

-- Check for nulls by column by taking a count of non-null values
SELECT
  COUNT(*) AS total_rows,
  COUNT(campaign_name) AS non_null_campaign_name,
  COUNT(start_date) AS non_null_col2,
  COUNT(end_date) AS non_null_start_date,
  COUNT(budget) AS non_null_budget,
  COUNT(roi) AS non_null_roi,
  COUNT(`type`) AS non_null_type,
  COUNT(target_audience) AS non_null_target_audience,
  COUNT(`channel`) AS non_null_channel,
  COUNT(conversion_rate) AS non_null_conversion_rate,
  COUNT(revenue) AS non_null_revenue
FROM marketing_campaigns;
-- No nulls were found in any column of the dataset

-- Check for formatting issues (i.e. same values coming up under a different name/format)
-- Pattern: select unique values from each column in the dataset

SELECT DISTINCT campaign_name FROM marketing_campaigns
order by campaign_name;

SELECT DISTINCT start_date FROM marketing_campaigns
order by start_date;

SELECT DISTINCT end_date FROM marketing_campaigns
order by end_date;

SELECT DISTINCT budget FROM marketing_campaigns
order by budget;

SELECT DISTINCT roi FROM marketing_campaigns
order by roi;
-- **roi is 0 for some campaigns, note for later

SELECT DISTINCT `type` FROM marketing_campaigns
order by `type`;

SELECT DISTINCT target_audience FROM marketing_campaigns
order by target_audience;

SELECT DISTINCT `channel` FROM marketing_campaigns
order by `channel`;

SELECT DISTINCT conversion_rate FROM marketing_campaigns
order by conversion_rate;
-- **conversion_rate is 0 for some campaigns, note for later

SELECT DISTINCT revenue FROM marketing_campaigns
order by revenue;
-- No formatting issues were found in any column of the dataset

-- Check for duplicates
-- To identify potential duplicate campaigns under different names, I grouped on campaign-defining attributes 
-- such as dates, budget, audience, and channel, and intentionally excluded outcome metrics like ROI and revenue 
-- since those can vary slightly in calculation. I also rounded budget down to account for any minor discrepancies
SELECT start_date, end_date, round(budget, -2), `type`, target_audience, `channel`, COUNT(*) AS cnt
FROM marketing_campaigns
GROUP BY start_date, end_date, round(budget, -2), `type`, target_audience, `channel`
having count(*) > 1;
-- No duplicate campaigns were found

-- Check to ensure date ranges make sense
SELECT *
FROM marketing_campaigns
WHERE end_date < start_date;
-- All end dates are greater than start dates

-- Validate roi column
select roi, round((revenue - budget)/budget, 2) as calculated_roi 
from marketing_campaigns;
-- Calculated ROI using revenue and budget columns does not match the provided ROI values
-- This suggests that the revenue column does not represent only campaign-attributed revenue

-- Overall metrics:

-- Calculate total budget
select round(sum(budget), 2) as total_spend from marketing_campaigns;
-- Total budget is 49,549,580.91

-- Calculate total revenue
select round(sum(revenue), 2) as total_revenue from marketing_campaigns;
-- Total revenue is 517,629,575.72

-- Calculate the budget-weighted average roi
-- I used budget-weighted average as opposed to a simple average to attribute more weight to higher spend campaigns
select round(sum(roi*budget)/sum(budget), 2) as budget_weighted_avg_roi from marketing_campaigns;
-- Overall budget-weighted average roi is 0.54

-- Calculate the average conversion rate
select round(avg(conversion_rate), 2) as avg_conversion_rate from marketing_campaigns; 
-- Overall average conversion rate is 0.54

-- Channel-level analysis:

-- Calculate the budget per channel
select channel, round(sum(budget), 2) as budget_per_channel from marketing_campaigns
group by channel
order by budget_per_channel desc;
-- The channel with the highest budget was promotion (13,495,668.71)
-- The channel with the lowest budget was paid (11,880,346.61)

-- Calculate the budget-weighted average roi per channel
select channel, round(sum(roi*budget)/sum(budget), 2) as budget_weighted_avg_roi_per_channel from marketing_campaigns
group by channel
order by budget_weighted_avg_roi_per_channel desc;
-- ROIs are tightly clustered across channels (0.01 differences), no clear outliers driving underperformance
-- There is no strong reallocation signal at the channel level
-- All channels have ROIs similar to the overall mean ROI of the dataset (0.54)

-- Calculate the average conversion rate per channel
select channel, round(avg(conversion_rate), 2) as avg_conversion_rate_per_channel from marketing_campaigns
group by channel
order by avg_conversion_rate_per_channel desc;
-- Conversion rates are tightly clustered across channels (0.01 differences), no clear outliers driving underperformance
-- All channels have conversion rates similar to the overall mean conversion rate of the dataset (0.54)

-- Display the budget-weighted average roi and conversion rate by channel together
select channel, round(sum(roi*budget)/sum(budget), 2) as budget_weighted_avg_roi_per_channel, round(avg(conversion_rate), 2) as avg_conversion_rate_per_channel from marketing_campaigns
group by channel;
-- ROI and conversion rates cluster around the overall mean
-- There is no clear evidence that reallocating budget across channels would materially improve performance

-- Type-level analysis:

-- Calculate the budget per type:
select type, round(sum(budget), 2) as budget_per_type from marketing_campaigns
group by type
order by budget_per_type desc;
-- The type with the highest budget was email (13,888,280.20)
-- The type with the lowest budget was social media (11,016,603.03)

-- Calculate the budget-weighted average roi per type
select type, round(sum(roi*budget)/sum(budget), 2) as budget_weighted_avg_roi_per_type from marketing_campaigns
group by type
order by budget_weighted_avg_roi_per_type desc;
-- ROIs are tightly clustered across channels (0.02 differences), no clear outliers driving underperformance
-- There is no strong reallocation signal at the channel level
-- All channels have ROIs similar to the overall mean ROI of the dataset (0.54)

-- Calculate the average conversion rate per type
select type, round(avg(conversion_rate), 2) as avg_conversion_rate_per_type from marketing_campaigns
group by type
order by avg_conversion_rate_per_type desc;
-- Conversion rates are tightly clustered across channels (0.01 differences), no clear outliers driving underperformance
-- All channels have conversion rates similar to the overall mean conversion rate of the dataset (0.54)

-- Display the budget-weighted average roi and conversion rate by type together
select type, round(sum(roi*budget)/sum(budget), 2) as budget_weighted_avg_roi_per_type, round(avg(conversion_rate), 2) as avg_conversion_rate_per_type from marketing_campaigns
group by type;
-- ROI and conversion rates cluster around the overall mean
-- There is no clear evidence that reallocating budget across channels would materially improve performance

-- Type x Channel Analysis:

-- Calculate the budget-weighted average roi per type x channel
-- CTE: 'type_channel_rois' calculates budget-weighted rois for each type x channel combination
-- Dense ranking within types is applied to the resulting rois 
with type_channel_rois as(
select type, channel, round(sum(roi*budget)/sum(budget), 2) as budget_weighted_avg_roi from marketing_campaigns
group by type, channel
order by type, channel
)
select type, channel, budget_weighted_avg_roi,
dense_rank() over(partition by type order by budget_weighted_avg_roi desc) as ranking from type_channel_rois
order by type, ranking;
-- In terms of roi:
-- Email campaigns perform slightly higher in organic channels and promotion channels and slighter lower in paid and referral channels, range is modest (0.56-0.5)
-- Podcast campaigns perform the best in promotion channels and the worst in paid channels, range is moderate (0.59-0.49)
-- Social media campaigns perform the best in referral and paid channels and the worst in organic channels, range is wider (0.6-0.5)
-- Webinar campaigns perform slightly higher in referral channels and slightly lower in promotion channels, range is modest (0.57-0.5)
-- ROI performance appears to be more channel-dependent for social media and podcast, which show the greatest variation across channels, while email and webinar exhibit more modest changes

-- Check budget allocation the type x channel level
-- CTE: 'type_budgets' calculates vudgets as well as budget-weighted rois for each type x channel combination
-- Budgets are partitioned by type to determine % allocation to each channel within type
with type_budgets as(
select type, channel, 
round(sum(budget), 2) as budget_per_type_channel,
round(sum(roi*budget)/sum(budget), 2) as budget_weighted_avg_roi from marketing_campaigns
group by type, channel
order by type, channel
)
select type, channel, 
budget_weighted_avg_roi,
concat(
round((budget_per_type_channel/
(sum(budget_per_type_channel) over(partition by type)))*100, 2)
, '%') as budget_allocation_per_type
from indiv_budgets
order by type, budget_weighted_avg_roi desc;
-- Within channels, budget allocation does not fully align with ROI at the type level, suggesting potential opportunities for incremental reallocation or further testing

-- Calculate the conversion rate for each type x channel
select type, channel, round(avg(conversion_rate), 2) as avg_conversion_rate from marketing_campaigns
group by type, channel
order by type, channel;
-- Email campaigns convert slightly higher in organic and promotion channels and slightly lower in paid channels (0.51-0.57)
-- Podcast campaigns convert slightly higher in paid and referral channels and slightly lower in organic channels (0.49-0.56)
-- Social media campaigns convert similarly across channels (0.53 - 0.55)
-- Webinar campaigns convert slightly higher in paid channels and slightly lower in referral channels (0.6-0.53)

-- Display roi and conversion rate for each type x channel
select type, channel, round(sum(roi*budget)/sum(budget), 2) as budget_weighted_avg_roi, 
round(avg(conversion_rate), 2) as avg_conversion_rate 
from marketing_campaigns
group by type, channel
order by type, channel;
-- Most type–channel combinations cluster near the mean, with only a few notable deviations that may warrant closer attention:
-- podcast, organic: roi near mean (+0.02), cr below mean(-0.05)
-- podcast, paid: roi below mean(-0.05), cr near mean (+0.02)
-- podcast, promotion: roi above mean(+0.05), cr slightly below mean(-0.03)
-- social media, referral: roi above mean(+0.06), cr at mean (+0.01)
-- webinar, paid: roi at mean (+0.01), cr above mean(+0.06)

-- Target Audience Overview Metrics

-- Show roi and conversion rate by target audience
select target_audience, round(sum(roi*budget)/sum(budget), 2) as budget_weighted_avg_roi, round(avg(conversion_rate), 2) as avg_conversion_rate from marketing_campaigns
group by target_audience;
-- B2B has slightly better roi and conversion rate than B2C (0.55(roi & cr) vs. 0.53(roi & cr))

-- Campaign-level Performance

-- Find the top and bottom campiagns by roi
select campaign_name, roi, 
dense_rank() over(order by roi desc) as ranking
from marketing_campaigns ;
-- Rois are tighly clustered, approach with percentiles instead

-- Assign performance as High or Low according to the top and bottom 10th percentiles
-- Subquery assigns a decile to each campaign according to roi
-- Outer query assigns each campaign a High or Low label if in the top or bottom decile
select
  campaign_name,
  conversion_rate,
  roi,
  case
    when roi_decile = 1 then 'Low (Bottom 10%)'
    when roi_decile = 10 then 'High (Top 10%)'
    else 'Mid'
  end as performance_band
from (
  select
    campaign_name, 
    conversion_rate,
    roi,
    ntile(10) over (order by roi) as roi_decile
  from marketing_campaigns
) t;
-- Campaign-level results reveal substantially wider variation in ROI than aggregated analysis