"""
trim_columns.py
----------------
Reads the raw MutualFunds.csv and ETFs.csv (400+ / 240+ columns each) and
keeps only the columns actually needed for our 6-phase analysis, writing
much smaller, focused CSVs to data/trimmed/.

Run from the project root:
    python scripts/trim_columns.py

Requires:
    pip install pandas
"""

import os
import pandas as pd

SCRIPT_DIR = os.path.dirname(os.path.abspath(__file__))
PROJECT_ROOT = os.path.join(SCRIPT_DIR, "..")
RAW_DIR = os.path.join(PROJECT_ROOT, "data", "raw")
TRIMMED_DIR = os.path.join(PROJECT_ROOT, "data", "trimmed")
os.makedirs(TRIMMED_DIR, exist_ok=True)

# Columns present in BOTH MutualFunds.csv and ETFs.csv - our core comparison set
COMMON_COLUMNS = [
    "fund_symbol",
    "fund_long_name",
    "fund_category",
    "fund_family",
    "total_net_assets",
    "fund_annual_report_net_expense_ratio",
    "fund_return_ytd",
    "fund_return_1year",
    "fund_return_3years",
    "fund_return_5years",
    "fund_return_10years",
    "fund_alpha_3years",
    "fund_beta_3years",
    "fund_stdev_3years",
    "fund_sharpe_ratio_3years",
    "asset_stocks",
    "asset_bonds",
]

# Extra columns that ONLY exist in MutualFunds.csv (Morningstar ratings + ESG)
MUTUAL_FUND_ONLY_COLUMNS = [
    "morningstar_overall_rating",
    "morningstar_risk_rating",
    "esg_score",
    "sustainability_score",
]


def trim_file(filename, columns, output_name, fund_type_label):
    input_path = os.path.join(RAW_DIR, filename)
    if not os.path.exists(input_path):
        print(f"  SKIPPED {filename} - not found in data/raw/")
        return

    print(f"Reading {filename} (this may take a moment, file is large)...")
    df = pd.read_csv(input_path, usecols=columns, low_memory=False)

    # tag which table this row came from - useful once loaded into MySQL
    # for the Mutual Funds vs ETFs comparison (Phase 5)
    df["fund_type"] = fund_type_label

    output_path = os.path.join(TRIMMED_DIR, output_name)
    df.to_csv(output_path, index=False)
    print(f"  wrote {output_name}  ({len(df)} rows, {len(df.columns)} columns)")


def main():
    trim_file(
        "MutualFunds.csv",
        COMMON_COLUMNS + MUTUAL_FUND_ONLY_COLUMNS,
        "mutual_funds_trimmed.csv",
        "Mutual Fund",
    )
    trim_file(
        "ETFs.csv",
        COMMON_COLUMNS,
        "etfs_trimmed.csv",
        "ETF",
    )
    print("\nDone. Trimmed files written to:", os.path.abspath(TRIMMED_DIR))


if __name__ == "__main__":
    main()