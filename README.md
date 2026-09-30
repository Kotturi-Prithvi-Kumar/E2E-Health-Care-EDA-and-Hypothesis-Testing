# 🏥 Healthcare EDA & Hypothesis Testing (End-to-End)

> End-to-end analysis of patient length of stay and mortality — SQL data extraction, Python EDA, and formal statistical hypothesis testing, translated into resource-planning insights.

## The Problem
What drives how long patients stay in hospital, and what factors associate with mortality? This project goes from raw data to tested conclusions a hospital operations team could act on.

## The Data
Healthcare dataset (MIMIC-III style; see `Raw-data/`): admissions, patient demographics, length of stay, mortality outcomes.

## Approach
1. **Data cleaning** (`00-data-cleaning.ipynb`) — missing values, types, deduplication; logged in `05_data_quality_log.xlsx`.
2. **SQL extraction** (`01-SQL-schema.sql`, `02-analysis.sql`) — schema definition and cohort/aggregation queries.
3. **EDA** (`03_eda_hospital.ipynb`) — length-of-stay distributions, mortality rates by segment, correlations.
4. **Hypothesis testing** (`04_hypothesis_testing.ipynb`) — formal tests (t-tests / chi-square / ANOVA as appropriate) on the key questions, with significance levels reported.

## Key Results
- **Hypothesis 1:** [question → test → p-value → conclusion — fill in]
- **Hypothesis 2:** [question → test → p-value → conclusion — fill in]
- **Operational takeaway:** [e.g. which patient segment drives bed-days — fill in]

## Tech Stack
Python · Pandas · NumPy · SciPy (stats) · Matplotlib · Seaborn · SQL · Jupyter · Excel

## Project Structure
```
├── 00-data-cleaning.ipynb          # Cleaning + validation
├── 01-SQL-schema.sql               # Schema
├── 02-analysis.sql                 # Cohort & aggregation queries
├── 03_eda_hospital.ipynb           # Exploratory analysis
├── 04_hypothesis_testing.ipynb     # Formal hypothesis tests
├── 05_data_quality_log.xlsx        # Data quality log
└── Raw-data/                       # Source data
```

## How to Run
```bash
pip install pandas numpy scipy matplotlib seaborn jupyter
jupyter notebook 00-data-cleaning.ipynb   # then run 03 and 04 in order
```
Run the SQL files against your database to reproduce the extracted cohorts.
