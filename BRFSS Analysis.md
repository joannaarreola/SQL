# BRFSS Analysis

## Objective
The objective of this project is to indentify demographic and socioeconomic factors associated with smoking status in the U.S.

## Dataset Overview
**Dataset Source:** Kaggle (https://www.kaggle.com/datasets/isuruprabath/brfss-2023-csv-dataset?resource=download). Also included in this project folder

The Behavioral Risk Factor Surveillance System (BRFSS) is a comprehensive health survey in the United Statesconducted annually by the CDC since 1984. It collects data on behavioral risk factors, chronic health conditions, and the use of preventive services among adults aged 18 and older. With over 400,000 interviews completed each year across all 50 states, the District of Columbia, Puerto Rico, Guam, and the U.S. Virgin Islands, the BRFSS is the largest continuously conducted health survey system in the world.

This dataset consists of a single table with 433,323 rows × 350 columns 

Key columns for analysis:

- `_state`: Numerical identifier for the respondent’s state.
- `sexvar`: Numerical identifier for sex (male/female).
- `_age80`: Categorical age variable, with ages above 80 collapsed into a single category.
- `_bmi5cat`: Categorical Body Mass Index (BMI) classification.
- `_smoker3`: Four-level smoking status: everyday smoker, someday smoker, former smoker, non-smoker.
- `exerany2`: Categorical indicator of whether the respondent engages in any physical exercise.

## Data Loading and Inspection

The dataset was loaded into a Pandas DataFrame for exploration. Initial inspection using head(), info(), and column enumeration provided an overview of the dataset’s structure.

The full list of column names was reviewed, and the BRFSS 2023 Codebook was used to select a subset of meaningful columns. A new DataFrame containing only these key columns was created for focused analysis.

Inspection of the selected columns revealed that most are numeric or categorical as expected. `_bmi5cat` and `exerany2` contain some missing values, which will be addressed during the cleaning stage. All other columns are complete and ready for analysis.

## Data Cleaning

The dataset was thoroughly cleaned and standardized before analysis. Missing values were addressed first: the categorical `exerany2` column had 2 missing values, which were imputed with the mode. Additionally, special codes representing "Not sure/Don't know" (7.0) and "Refused to answer" (9.0), totaling 1,249 responses (~0.3% of the dataset), were also treated as missing and imputed with the mode. The `bmi5cat` column had 40,535 missing values (~9.4% of the dataset), which were imputed using the median BMI within each gender-age category group to preserve realistic variation. Throughout the cleaning process, `value_counts()` was used to verify that all categorical columns contained only expected values, with no formatting inconsistencies, unexpected codes, or duplicated representations (e.g., 1 vs 1.0). All columns were consistent with predefined categories, indicating the data is clean, standardized, and ready for analysis.


## Exploratory Data Analysis

  
## Conclusion


## Next steps

