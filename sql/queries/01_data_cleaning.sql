-- ============================================================
-- 01_data_cleaning.sql
-- Phase 1: audit real data quality issues in mutual_funds_analysis
-- Just 5 checks. Run one at a time, no rush.
-- ============================================================

USE mutual_funds_analysis;


-- CHECK 1: Did the load work correctly?
-- Simplest possible sanity check -- just confirms the row counts in MySQL
-- still match what we loaded in Step 7 (23,783 mutual funds, 2,310 ETFs).
-- If these numbers don't match, something broke during the load and we'd
-- need to go back and re-run load_to_mysql.py before doing anything else.
SELECT 'mutual_funds' AS table_name, COUNT(*) AS row_count FROM mutual_funds
UNION ALL
SELECT 'etfs', COUNT(*) FROM etfs;


-- CHECK 2: How much data is actually missing, and is that normal?
-- This counts NULLs in the columns we care about most. We already expect
-- fund_return_10years to have a lot of NULLs (young funds don't have 10
-- years of history yet) -- this check tells us exactly how many, and lets
-- us see if any OTHER column is unexpectedly full of NULLs too (which
-- would be a red flag, not an expected pattern).
SELECT
    COUNT(*) AS total_rows,
    SUM(fund_return_1year IS NULL) AS null_1yr,
    SUM(fund_return_5years IS NULL) AS null_5yr,
    SUM(fund_return_10years IS NULL) AS null_10yr,
    SUM(fund_sharpe_ratio_3years IS NULL) AS null_sharpe,
    SUM(fund_annual_report_net_expense_ratio IS NULL) AS null_expense
FROM mutual_funds;


-- CHECK 3: Is the fund_family column spelled consistently?
-- This just lists every distinct fund family name and how many funds are
-- under it. We're eyeballing this list for near-duplicates -- e.g. is
-- "Vanguard" ever listed separately from "Vanguard Group"? Inconsistent
-- naming here would silently split one company's funds into two groups
-- later, when we compare fund families in Phase 4.
SELECT fund_family, COUNT(*) AS n
FROM mutual_funds
GROUP BY fund_family
ORDER BY fund_family;


-- CHECK 4: Are there any impossible or extreme numbers?
-- Expense ratios should never be negative, and shouldn't realistically be
-- above 5%. Returns of over +200% or under -90% in a single year are
-- extreme too. This query just pulls out anything that crosses those
-- lines so we can look at them individually and decide: real outlier
-- (some leveraged/exotic funds really do look like this) or scrape error.
SELECT fund_symbol, fund_long_name, fund_annual_report_net_expense_ratio, fund_return_1year
FROM mutual_funds
WHERE fund_annual_report_net_expense_ratio < 0
   OR fund_annual_report_net_expense_ratio > 0.05
   OR fund_return_1year > 2.0
   OR fund_return_1year < -0.9;


-- CHECK 5: How usable is the ESG data, really?
-- The handoff already established that ETFs have zero ESG data. This
-- checks the mutual_funds side specifically: out of 23,783 mutual funds,
-- how many actually HAVE an ESG score and a Morningstar rating filled in?
-- If it's a small fraction, that's a second honest limitation to write
-- into the data quality report, on top of "ETFs have none at all."
SELECT
    COUNT(*) AS total_mutual_funds,
    SUM(esg_score IS NOT NULL) AS has_esg_score,
    SUM(morningstar_overall_rating IS NOT NULL) AS has_morningstar_rating
FROM mutual_funds;


-- CHECK 6: Any duplicate fund symbols?
-- fund_symbol is supposed to be the unique ID for each fund (it's our
-- PRIMARY KEY). MySQL should already block true duplicates, but this
-- double-checks that nothing snuck in twice under a slightly different
-- symbol or got loaded before the key constraint was active.
SELECT fund_symbol, COUNT(*) AS n
FROM mutual_funds
GROUP BY fund_symbol
HAVING COUNT(*) > 1;


-- CHECK 7: Are any fund categories too small to trust?
-- Later phases compare funds within the same fund_category (e.g. average
-- return for "Large Blend" funds). If a category only has 2-3 funds in
-- it, any average we compute from it will be shaky and worth flagging
-- rather than treating as a solid finding.
SELECT fund_category, COUNT(*) AS n
FROM mutual_funds
GROUP BY fund_category
ORDER BY n ASC;