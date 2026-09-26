"""
load_to_mysql.py
-----------------
Creates the schema (from sql/schema/create_tables.sql) and loads the two
trimmed CSVs (mutual_funds_trimmed.csv, etfs_trimmed.csv) into MySQL.

Run from the project root, AFTER trim_columns.py has produced the trimmed CSVs:
    python scripts/load_to_mysql.py

Requires:
    pip install pandas sqlalchemy pymysql
"""

import os
import pandas as pd
from sqlalchemy import create_engine, text

# ---------------------------------------------------------------------------
# EDIT THESE to match your local MySQL setup
# ---------------------------------------------------------------------------
DB_CONFIG = {
    "host": "localhost",
    "port": 3306,
    "user": "root",
    "password": "iamyashwanth",   # <-- change this
    "database": "mutual_funds_analysis",
}

SCRIPT_DIR = os.path.dirname(os.path.abspath(__file__))
PROJECT_ROOT = os.path.join(SCRIPT_DIR, "..")
TRIMMED_DIR = os.path.join(PROJECT_ROOT, "data", "trimmed")
SCHEMA_FILE = os.path.join(PROJECT_ROOT, "sql", "schema", "create_tables.sql")

LOAD_ORDER = [
    ("mutual_funds_trimmed.csv", "mutual_funds"),
    ("etfs_trimmed.csv", "etfs"),
]


def run_schema_script(root_conn):
    """Execute create_tables.sql statement-by-statement."""
    with open(SCHEMA_FILE, "r", encoding="utf-8") as f:
        sql_script = f.read()

    statements = [s.strip() for s in sql_script.split(";") if s.strip()]
    for stmt in statements:
        root_conn.execute(text(stmt))
    root_conn.commit()
    print(f"Schema created ({len(statements)} statements executed).")


def main():
    # Step 1: connect WITHOUT selecting a database yet, so CREATE DATABASE works
    root_url = (
        f"mysql+pymysql://{DB_CONFIG['user']}:{DB_CONFIG['password']}"
        f"@{DB_CONFIG['host']}:{DB_CONFIG['port']}/"
    )
    root_engine = create_engine(root_url)
    with root_engine.connect() as conn:
        run_schema_script(conn)

    # Step 2: connect to the actual database for loading data
    db_url = (
        f"mysql+pymysql://{DB_CONFIG['user']}:{DB_CONFIG['password']}"
        f"@{DB_CONFIG['host']}:{DB_CONFIG['port']}/{DB_CONFIG['database']}"
    )
    engine = create_engine(db_url)

    # Step 3: load each trimmed CSV
    for filename, table_name in LOAD_ORDER:
        csv_path = os.path.join(TRIMMED_DIR, filename)
        if not os.path.exists(csv_path):
            print(f"  SKIPPED {filename} - file not found. Run trim_columns.py first.")
            continue

        df = pd.read_csv(csv_path)
        df = df.where(pd.notnull(df), None)  # NaN -> proper SQL NULL

        df.to_sql(table_name, engine, if_exists="append", index=False)
        print(f"  loaded {filename} -> {table_name}  ({len(df)} rows)")

    print("\nDone. All tables loaded into MySQL database:", DB_CONFIG["database"])


if __name__ == "__main__":
    main()