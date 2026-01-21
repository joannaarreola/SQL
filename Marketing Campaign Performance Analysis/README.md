# Marketing Campaign Performance **Analysis**

## Project Overview

This SQL project evaluates marketing campaign performance across channels and campaign types using a synthetic dataset designed to simulate real-world marketing data. ROI is used as the primary business metric, with conversion rate included to provide funnel efficiency context. The analysis progresses from aggregate trends to type x channel comparisons and concludes with campaign-level performance, emphasizing business-aligned decision making.

## Dataset Overview

The analysis Sling Academy’s **Marketing Campaigns Sample Data dataset:** sample data of marketing campaigns in an imaginary online business for the purposes of learning, practicing, or testing software

**Source:** Marketing Campaigns Sample Data (SlingAcademy) - https://www.slingacademy.com/article/marketing-campaigns-sample-data-csv-json-xlsx-xml/#marketing-campaigns.csv

**Size:** 1000 rows 

### Columns:

- `campaign_name`: name of the marketing campaign
- `start_date`: start date of the marketing campaign
- `end_date`: end date of the marketing campaign
- `budget`: budget for the marketing campaign. Float between 1000 and 100000 with two decimal places.
- `roi`: return on investment (ROI) of the marketing campaign. It is a float between -1 and 1 with two decimal places
- `type`: type of marketing campaign: `email`, `social media`, `webinar`, or `podcast`
- `target_audience` : target audience of the marketing campaign: B2C and B2B
- `channel` : channel of the marketing campaign
- `conversion rate`: conversion rate of the marketing campaign
- `revenue`: revenue of the marketing campaign

## Objective

To evaluate marketing campaign performance across channels, campaign types, and audiences using a synthetic dataset, with the goal of understanding how ROI, conversion rate, and budget allocation interact at different levels of aggregation.

## Core Metrics

### Return on Investment (ROI)

**Definition:**

ROI measures the financial efficiency of a marketing campaign by comparing the value generated relative to the budget spent. 

**Business Context:**

ROI accounts for both performance and cost, making it the most relevant indicator for evaluating campaign effectiveness and guiding budget allocation decisions. In this project, ROI is treated as the primary performance metric, while conversion rate is used selectively to contextualize performance rather than to define success on its own.

### Conversion Rate

**Definition:**

Conversion rate represents the proportion of users who complete a desired action out of all users exposed to a campaign.

**Business Context:**

Conversion rate captures **funnel efficiency** independent of spend. Conversion rate helps explain whether performance is driven by user engagement and messaging effectiveness or by factors such as spend level, pricing, or audience value. In this analysis, conversion rate is used as a complementary metric to provide behavioral context alongside ROI.

## Data Cleaning

### Environment Setup

- Created a `marketing_campaigns` database
- Imported a cleaned synthetic dataset as table: `marketing_campaigns`

### Data Validation & Quality Checks

Ensured the dataset was suitable for analysis before calculations

### Row Count & Completeness

- Verified full data import (1,000 rows)
- Confirmed no missing values across all columns

### Formatting Consistency

- Checked unique values across all categorical and numerical fields
- Confirmed no inconsistent labels or formatting issues
- Noted zero values in ROI and conversion rate for later interpretation

### Duplicate Detection

- Searched for duplicate campaigns using campaign-defining attributes (dates, budget, type, channel, audience)
- Excluded outcome metric columns and used a rounded budget to avoid false positives
- Found no duplicate campaigns

### Date Validation

- Confirmed all campaign end dates occur after start dates

### ROI Field Validation

- Compared provided ROI values to calculated ROI using revenue and budget
- Identified mismatch, indicating either revenue is not strictly campaign-attributed and/or additional campaign costs were not included in the dataset
- Proceeded using provided ROI for performance evaluation

## Overall Performance metrics

Established baseline performance across all campaigns in the dataset for later comparisons

- **Total budget**: $49,549,580.91
    - to show scale of investment
- **Total revenue**: $517,629,575.72
- **Budget-weighted average ROI**: 0.54
    - to attribute more weight to higher spend campaigns
- **Average conversion rate**: 0.54

## Channel-Level Analysis

Evaluated performance differences at the channel level.

- Budget allocation by channel
    - range: $11,880,346.61 - $13,495,668.71
- Budget-weighted ROI by channel
    - tightly clustered across channels (0.01 differences) and overall mean
- Average conversion rate by channel
    - tightly clustered across channels and overall mean
- Joint view of ROI and conversion rate

**Key takeaway:**

Performance metrics are tightly clustered around the overall mean across channels, with no clear outliers or strong signals for channel-level budget reallocation.

## Type-Level Analysis

Evaluated performance differences at the type level.

- Budget allocation by campaign type
    - range: $11,016,603.03 - $13,888,280.20
- Budget-weighted ROI by type
    - ROIs are tightly clustered across channels (0.02 differences) and overall mean
- Average conversion rate by type
    - Conversion rates are tightly clustered across channels (0.01 differences) and overall mean
- Joint ROI and conversion rate view

**Key takeaway:**

Performance metrics are tightly clustered around the overall mean across channels, suggesting limited standalone impact from campaign type.

## Type × Channel Interaction Analysis

Explored interaction effects between campaign type and channel.

### ROI by Type × Channel

- Calculated budget-weighted ROI for each combination
    - range: 0.49 - 0.6
- Ranked channels within each campaign type by ROI
    - Email campaigns perform slightly higher in organic channels and promotion channels and slighter lower in paid and referral channels, range is modest (0.56-0.5)
    - Podcast campaigns perform the best in promotion channels and the worst in paid channels, range is moderate (0.59-0.49)
    - Social media campaigns perform the best in referral and paid channels and the worst in organic channels, range is wider (0.6-0.5)
    - Webinar campaigns perform slightly higher in referral channels and slightly lower in promotion channels, range is modest (0.57-0.5)

**Key takeaway:**

Some campaign types (notably social media and podcast) show greater sensitivity to channel choice, while others exhibit more stable performance.

### Budget Allocation Alignment

- Examined how budget is distributed across channels within each type
- Compared allocation patterns against ROI outcomes

**Key takeaway:**

Budget allocation does not fully align with ROI at the type–channel level, suggesting potential opportunities for incremental reallocation.

### Conversion Rate by Type × Channel

- Analyzed funnel efficiency patterns independently of spend
    - range: 0.49 - 0.6
- Compared conversion rates across combinations
    - Email campaigns convert slightly higher in organic and promotion channels and slightly lower in paid channels (0.51-0.57)
    - Podcast campaigns convert slightly higher in paid and referral channels and slightly lower in organic channels (0.49-0.56)
    - Social media campaigns convert similarly across channels (0.53 - 0.55)
    - Webinar campaigns convert slightly higher in paid channels and slightly lower in referral channels (0.6-0.53)

**Key takeaway:**

No significant variation in channel-level conversion rates across campaign types, only slight differences.

### Combined ROI & Conversion Rate View

- Evaluated which combinations deviate meaningfully from overall averages
- Identified a small number of combinations warranting closer attention for further evaluation or incremental optimization
    - Deviations below mean:
    - podcast, organic: ROI near mean (+0.02), conversion rate below mean(-0.05)
    - podcast, paid: ROI below mean(-0.05), conversion rate near mean (+0.02)
    - Deviations above mean:
    - podcast, promotion: ROI above mean(+0.05), conversion rate slightly below mean(-0.03)
    - social media, referral: ROI above mean(+0.06), conversion rate at mean (+0.01)
    - webinar, paid: ROI at mean (+0.01), conversion rate above mean(+0.06)

## Target Audience Overview

Compared performance across audience segments.

- Budget-weighted ROI by target audience
    - B2B: 0.55
    - B2C: 0.53
- Average conversion rate by target audience
    - B2B: 0.55
    - B2C: 0.53

**Key takeaway:**

B2B campaigns show slightly higher ROI and conversion rates than B2C, though differences are very modest.

## Campaign-Level Performance Analysis

Shifted from aggregated trends to individual campaign outcomes.

### ROI Distribution

- Observed tight clustering of ROI values
- Chose percentile-based segmentation over simple ranking

### Performance Banding

- Assigned campaigns to performance bands using ROI deciles:
    - Top 10% (High)
    - Bottom 10% (Low)
    - Middle 80% (Mid)
- Included conversion rate for contextual interpretation

**Key takeaway:**

Campaign-level ROI (and conversion rate) variation is substantially wider than aggregated trends, reinforcing the importance of evaluating individual campaigns alongside summaries.

## Key Insights

- Channel- and type-level analyses show limited standalone differentiation, with budget-weighted ROI and conversion rates clustering tightly around the mean, suggesting that neither channel nor campaign type alone is a strong driver of performance in this dataset.
- Interaction effects between campaign type and channel reveal more meaningful variation, particularly for social media and podcast campaigns, which appear more sensitive to channel choice than email and webinar campaigns.
- Budget allocation does not fully align with ROI at the type–channel level, indicating potential opportunities for incremental optimization or controlled testing rather than large-scale reallocation.
- A small number of type–channel combinations deviate modestly from overall performance baselines, warranting closer evaluation to understand whether differences are driven by funnel efficiency, audience response, or other factors.
- Campaign-level analysis shows substantially greater variation in ROI than aggregated views, reinforcing the importance of examining individual campaigns alongside summary metrics.

## Next Steps

- Conduct targeted experimentation on select type–channel combinations that deviate from baseline performance to assess whether observed differences are persistent or statistically significant
- Incorporate additional performance drivers such as audience segmentation, and campaign duration to better explain why certain campaigns outperform others.
- Evaluate performance trends over time, which could reveal seasonality or learning effects not visible in static aggregate analysis.
- Refine attribution assumptions, particularly around revenue, to improve the interpretability of ROI at the campaign level
