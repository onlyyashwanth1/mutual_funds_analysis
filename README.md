# Mutual Funds & ETFs — Fee vs Performance Analysis

## Core Story
Fund companies charge investors more for "active management" and reputation.
Does that extra fee actually buy better (risk-adjusted) performance, or would
an investor do just as well in a cheap fund?

## Dataset
"US Funds Dataset From Yahoo Finance" (Kaggle - stefanoleone992)
Files used: MutualFunds.csv, ETFs.csv (place in data/raw/)
Price history files are intentionally NOT used - fund-level summary stats
already contain everything needed (returns, Sharpe ratio, alpha, beta).

## Folder Guide
- data/raw/       -> original downloaded CSVs, untouched
- data/trimmed/   -> only the ~17 relevant columns we actually use
- docs/           -> data dictionary, data quality notes, phase-wise findings
- scripts/        -> trim_columns.py (cuts down to relevant columns),
                     load_to_mysql.py (loads into MySQL)
- sql/schema/     -> table definitions
- sql/queries/    -> phase-wise SQL, one file per story chapter:
    01_data_cleaning.sql
    02_fees_vs_performance.sql
    03_risk_adjusted_performance.sql
    04_fund_family_reputation.sql
    05_mutual_funds_vs_etfs.sql
    06_category_allocation_esg.sql
- dashboard/      -> Power BI file
