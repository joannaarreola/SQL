# BRFSS Smoking Analysis SQL Output #
The following are selected SQL outputs from the full script that validate and highlight key findings in the analysis workflow

## SQL Scripts & Output ##
**-- Data loading checks**

-- Validate roi column
```
select roi, round((revenue - budget)/budget, 2) as calculated_roi 
from marketing_campaigns;
```

<img width="143" height="138" alt="Screen Shot 2026-01-21 at 3 29 39 PM" src="https://github.com/user-attachments/assets/84948461-637d-469e-9973-52bd696e1931" />

-- Calculated ROI using revenue and budget columns does not match the provided ROI values

-- This suggests that the revenue column does not represent only campaign-attributed revenue


**-- Channel-level analysis:**

-- Calculate the budget per channel
```
select channel, round(sum(budget), 2) as budget_per_channel from marketing_campaigns
group by channel
order by budget_per_channel desc;
```

<img width="174" height="94" alt="Screen Shot 2026-01-21 at 3 30 20 PM" src="https://github.com/user-attachments/assets/f80f8d54-1150-4580-ae42-ace13b1e054b" />

-- The channel with the highest budget was promotion (13,495,668.71)

-- The channel with the lowest budget was paid (11,880,346.61)


-- Calculate the budget-weighted average roi per channel
```
select channel, round(sum(roi*budget)/sum(budget), 2) as budget_weighted_avg_roi_per_channel from marketing_campaigns
group by channel
order by budget_weighted_avg_roi_per_channel desc;
```

<img width="264" height="93" alt="Screen Shot 2026-01-21 at 3 30 47 PM" src="https://github.com/user-attachments/assets/308788cf-87c6-4160-8c43-3ccf058f933f" />

-- ROIs are tightly clustered across channels (0.01 differences), no clear outliers driving underperformance

-- There is no strong reallocation signal at the channel level

-- All channels have ROIs similar to the overall mean ROI of the dataset (0.54)


-- Calculate the average conversion rate per channel
```
select channel, round(avg(conversion_rate), 2) as avg_conversion_rate_per_channel from marketing_campaigns
group by channel
order by avg_conversion_rate_per_channel desc;
```

<img width="236" height="92" alt="Screen Shot 2026-01-21 at 3 31 24 PM" src="https://github.com/user-attachments/assets/4d471fad-e949-4145-88d0-9cb7bcf2f778" />

-- Conversion rates are tightly clustered across channels (0.01 differences), no clear outliers driving underperformance

-- All channels have conversion rates similar to the overall mean conversion rate of the dataset (0.54)


-- Display the budget-weighted average roi and conversion rate by channel together
```
select channel, round(sum(roi*budget)/sum(budget), 2) as budget_weighted_avg_roi_per_channel, round(avg(conversion_rate), 2) as avg_conversion_rate_per_channel from marketing_campaigns
group by channel;
```

<img width="439" height="92" alt="Screen Shot 2026-01-21 at 3 31 48 PM" src="https://github.com/user-attachments/assets/25ec359c-0db8-45e5-8005-fcae1d6ecb0c" />

-- ROI and conversion rates cluster around the overall mean

-- There is no clear evidence that reallocating budget across channels would materially improve performance


**-- Type-level analysis:**

-- Calculate the budget per type:
```
select type, round(sum(budget), 2) as budget_per_type from marketing_campaigns
group by type
order by budget_per_type desc;
```

<img width="185" height="91" alt="Screen Shot 2026-01-21 at 3 32 12 PM" src="https://github.com/user-attachments/assets/9e2a6f94-b708-47ef-998e-3d4d2e30c8c6" />

-- The type with the highest budget was email (13,888,280.20)

-- The type with the lowest budget was social media (11,016,603.03)


-- Calculate the budget-weighted average roi per type
```
select type, round(sum(roi*budget)/sum(budget), 2) as budget_weighted_avg_roi_per_type from marketing_campaigns
group by type
order by budget_weighted_avg_roi_per_type desc;
```

<img width="260" height="93" alt="Screen Shot 2026-01-21 at 3 32 35 PM" src="https://github.com/user-attachments/assets/c16b7103-8481-4fb9-a2af-cd698d617c09" />

-- ROIs are tightly clustered across channels (0.02 differences), no clear outliers driving underperformance

-- There is no strong reallocation signal at the channel level

-- All channels have ROIs similar to the overall mean ROI of the dataset (0.54)


-- Calculate the average conversion rate per type
```
select type, round(avg(conversion_rate), 2) as avg_conversion_rate_per_type from marketing_campaigns
group by type
order by avg_conversion_rate_per_type desc;
```

<img width="232" height="94" alt="Screen Shot 2026-01-21 at 3 32 54 PM" src="https://github.com/user-attachments/assets/7267214a-7dc7-496d-9909-6fe12e14cca4" />

-- Conversion rates are tightly clustered across channels (0.01 differences), no clear outliers driving underperformance

-- All channels have conversion rates similar to the overall mean conversion rate of the dataset (0.54)


-- Display the budget-weighted average roi and conversion rate by type together
```
select type, round(sum(roi*budget)/sum(budget), 2) as budget_weighted_avg_roi_per_type, round(avg(conversion_rate), 2) as avg_conversion_rate_per_type from marketing_campaigns
group by type;
```

<img width="416" height="95" alt="Screen Shot 2026-01-21 at 3 33 15 PM" src="https://github.com/user-attachments/assets/f5f3c4eb-1111-4622-bf8f-6909fdc4d954" />

-- ROI and conversion rates cluster around the overall mean

-- There is no clear evidence that reallocating budget across channels would materially improve performance


**-- Type x Channel Analysis:**

-- Calculate the budget-weighted average roi per type x channel

-- CTE: 'type_channel_rois' calculates budget-weighted rois for each type x channel combination

-- Dense ranking within types is applied to the resulting rois 
```
with type_channel_rois as(
select type, channel, round(sum(roi*budget)/sum(budget), 2) as budget_weighted_avg_roi from marketing_campaigns
group by type, channel
order by type, channel
)
select type, channel, budget_weighted_avg_roi,
dense_rank() over(partition by type order by budget_weighted_avg_roi desc) as ranking from type_channel_rois
order by type, ranking;
```

<img width="308" height="271" alt="Screen Shot 2026-01-21 at 3 33 46 PM" src="https://github.com/user-attachments/assets/c47f23bc-361c-40b5-9e5e-fe51c0337e5b" />

-- In terms of roi:

-- Email campaigns perform slightly higher in organic channels and promotion channels and slighter lower in paid and referral channels, range is modest (0.56-0.5)

-- Podcast campaigns perform the best in promotion channels and the worst in paid channels, range is moderate (0.59-0.49)

-- Social media campaigns perform the best in referral and paid channels and the worst in organic channels, range is wider (0.6-0.5)

-- Webinar campaigns perform slightly higher in referral channels and slightly lower in promotion channels, range is modest (0.57-0.5)

-- ROI performance appears to be more channel-dependent for social media and podcast, which show the greatest variation across channels, while email and webinar exhibit more modest changes


-- Check budget allocation the type x channel level

-- CTE: 'type_budgets' calculates vudgets as well as budget-weighted rois for each type x channel combination

-- Budgets are partitioned by type to determine % allocation to each channel within type
```
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
```

<img width="409" height="272" alt="Screen Shot 2026-01-21 at 3 34 43 PM" src="https://github.com/user-attachments/assets/ef2c96d6-fdaf-4483-b7b5-5b73a2e555a9" />

-- Within channels, budget allocation does not fully align with ROI at the type level, suggesting potential opportunities for incremental reallocation or further testing


-- Calculate the conversion rate for each type x channel
```
select type, channel, round(avg(conversion_rate), 2) as avg_conversion_rate from marketing_campaigns
group by type, channel
order by type, channel;
```

<img width="238" height="274" alt="Screen Shot 2026-01-21 at 3 35 26 PM" src="https://github.com/user-attachments/assets/f25025ec-8fe6-43c0-b817-dd09b4007d1a" />

-- Email campaigns convert slightly higher in organic and promotion channels and slightly lower in paid channels (0.51-0.57)

-- Podcast campaigns convert slightly higher in paid and referral channels and slightly lower in organic channels (0.49-0.56)

-- Social media campaigns convert similarly across channels (0.53 - 0.55)

-- Webinar campaigns convert slightly higher in paid channels and slightly lower in referral channels (0.6-0.53)


-- Display roi and conversion rate for each type x channel
```
select type, channel, round(sum(roi*budget)/sum(budget), 2) as budget_weighted_avg_roi, 
round(avg(conversion_rate), 2) as avg_conversion_rate 
from marketing_campaigns
group by type, channel
order by type, channel;
```

<img width="373" height="276" alt="Screen Shot 2026-01-21 at 3 35 54 PM" src="https://github.com/user-attachments/assets/4c45c48e-4b1f-45a2-a646-cde24f6daed3" />

-- Most type–channel combinations cluster near the mean, with only a few notable deviations that may warrant closer attention:

-- podcast, organic: roi near mean (+0.02), cr below mean(-0.05)

-- podcast, paid: roi below mean(-0.05), cr near mean (+0.02)

-- podcast, promotion: roi above mean(+0.05), cr slightly below mean(-0.03)

-- social media, referral: roi above mean(+0.06), cr at mean (+0.01)

-- webinar, paid: roi at mean (+0.01), cr above mean(+0.06)


**-- Target Audience Overview Metrics**

-- Show roi and conversion rate by target audience
```
select target_audience, round(sum(roi*budget)/sum(budget), 2) as budget_weighted_avg_roi, round(avg(conversion_rate), 2) as avg_conversion_rate from marketing_campaigns
group by target_audience;
```

<img width="369" height="64" alt="Screen Shot 2026-01-21 at 3 36 38 PM" src="https://github.com/user-attachments/assets/84be7959-bb24-4d3e-bbe3-aeeb8ddad6b6" />

-- B2B has slightly better roi and conversion rate than B2C (0.55(roi & cr) vs. 0.53(roi & cr))


**-- Campaign-level Performance**

-- Find the top and bottom campiagns by roi
```
select campaign_name, roi, 
dense_rank() over(order by roi desc) as ranking
from marketing_campaigns;
```

<img width="314" height="181" alt="Screen Shot 2026-01-21 at 3 37 02 PM" src="https://github.com/user-attachments/assets/1ffb9460-8a75-49eb-95e9-c43dafff1fc0" />

-- Rois are tighly clustered, approach with percentiles instead


-- Assign performance as High or Low according to the top and bottom 10th percentiles

-- Subquery assigns a decile to each campaign according to roi

-- Outer query assigns each campaign a High or Low label if in the top or bottom decile
```
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
```

<img width="480" height="522" alt="Screen Shot 2026-01-21 at 3 37 56 PM" src="https://github.com/user-attachments/assets/7dc61592-e711-4a91-b11a-c8535551c0f6" />


<img width="476" height="479" alt="Screen Shot 2026-01-21 at 3 38 24 PM" src="https://github.com/user-attachments/assets/409ecbe1-1ddb-4ad3-89a4-55dfb633651d" />


<img width="480" height="476" alt="Screen Shot 2026-01-21 at 3 38 47 PM" src="https://github.com/user-attachments/assets/5a0168c2-3b02-4aed-af3d-9c69bf26edcf" />


<img width="480" height="60" alt="Screen Shot 2026-01-21 at 3 39 03 PM" src="https://github.com/user-attachments/assets/ff30f4f0-028c-4a72-b25c-467c9a6705b4" />


<img width="483" height="492" alt="Screen Shot 2026-01-21 at 3 39 38 PM" src="https://github.com/user-attachments/assets/252a3588-5006-472e-965a-5cec763136a9" />


<img width="481" height="491" alt="Screen Shot 2026-01-21 at 3 40 00 PM" src="https://github.com/user-attachments/assets/ef6a50a2-f5f0-4c6c-943c-15bc8f3bba7d" />


<img width="477" height="477" alt="Screen Shot 2026-01-21 at 3 40 18 PM" src="https://github.com/user-attachments/assets/4d282c63-76d5-4739-8ca9-b9adfe2cf709" />


<img width="482" height="32" alt="Screen Shot 2026-01-21 at 3 40 32 PM" src="https://github.com/user-attachments/assets/c041efe3-8a99-4005-9fa4-18a651fb68f0" />

-- Campaign-level results reveal substantially wider variation in ROI than aggregated analysis

