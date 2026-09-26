-- ============================================================
-- 02_fees_vs_performance.sql
-- Phase 2: the core thesis -- does paying more actually buy more?
-- 4 queries, one per question from the plan. Run one at a time.
-- ============================================================

USE mutual_funds_analysis;


-- Q1: Does a higher expense ratio come with a higher return?
-- We can't use a correlation formula (that's off-limits for this project),
-- so instead we group funds into fee bands -- cheap, medium, expensive,
-- very expensive -- and just look at the average 5-year return and average
-- Sharpe ratio in each band. If higher fees genuinely bought better
-- performance, the averages should climb as the bands get more expensive.
-- Only funds with both a fee and a 5yr return are included.
SELECT
    CASE
        WHEN fund_annual_report_net_expense_ratio < 0.005 THEN '1. Under 0.5%'
        WHEN fund_annual_report_net_expense_ratio < 0.010 THEN '2. 0.5%-1.0%'
        WHEN fund_annual_report_net_expense_ratio < 0.015 THEN '3. 1.0%-1.5%'
        WHEN fund_annual_report_net_expense_ratio < 0.020 THEN '4. 1.5%-2.0%'
        ELSE '5. Over 2.0%'
    END AS fee_band,
    COUNT(*) AS n_funds,
    AVG(fund_return_5years) AS avg_5yr_return,
    AVG(fund_sharpe_ratio_3years) AS avg_sharpe
FROM mutual_funds
WHERE fund_annual_report_net_expense_ratio IS NOT NULL
  AND fund_return_5years IS NOT NULL
GROUP BY fee_band
ORDER BY fee_band;


-- Q2: Which fund categories have the worst fee-to-return payoff?
-- Per category, we compare the average fee against the average 5yr return,
-- and calculate a simple "return per unit of fee paid" ratio. A low ratio
-- means investors in that category are paying a lot for not much return --
-- those are the categories where "you're paying for the name" shows up
-- most. Categories with fewer than 5 funds are excluded (per the data
-- quality report -- their averages aren't reliable), and so are the 663
-- funds with no category at all.
SELECT
    fund_category,
    COUNT(*) AS n_funds,
    AVG(fund_annual_report_net_expense_ratio) AS avg_fee,
    AVG(fund_return_5years) AS avg_5yr_return,
    AVG(fund_return_5years) / AVG(fund_annual_report_net_expense_ratio) AS return_per_fee_unit
FROM mutual_funds
WHERE fund_category IS NOT NULL
  AND fund_annual_report_net_expense_ratio IS NOT NULL
  AND fund_return_5years IS NOT NULL
GROUP BY fund_category
HAVING COUNT(*) >= 5
ORDER BY return_per_fee_unit ASC
LIMIT 20;


-- Q3: Do ETFs beat mutual funds once fees are accounted for?
-- This stacks both tables together using the fund_type column we added
-- ourselves, then compares the two groups head-to-head on average fee,
-- average 5yr return, and average Sharpe ratio (risk-adjusted return).
-- This is the most direct test of "cheap and passive vs. pricier and
-- actively managed."
SELECT
    fund_type,
    COUNT(*) AS n_funds,
    AVG(fund_annual_report_net_expense_ratio) AS avg_fee,
    AVG(fund_return_5years) AS avg_5yr_return,
    AVG(fund_sharpe_ratio_3years) AS avg_sharpe
FROM (
    SELECT fund_type, fund_annual_report_net_expense_ratio, fund_return_5years, fund_sharpe_ratio_3years FROM mutual_funds
    UNION ALL
    SELECT fund_type, fund_annual_report_net_expense_ratio, fund_return_5years, fund_sharpe_ratio_3years FROM etfs
) AS combined
WHERE fund_annual_report_net_expense_ratio IS NOT NULL
  AND fund_return_5years IS NOT NULL
GROUP BY fund_type;


-- Q4: Is there a fee "tipping point" where paying more stops helping?
-- Same fee-band idea as Q1, but with finer bands so we can actually see
-- where the average return peaks and starts flattening or dropping --
-- that turning point is the "tipping point."
SELECT
    CASE
        WHEN fund_annual_report_net_expense_ratio < 0.0025 THEN '1. Under 0.25%'
        WHEN fund_annual_report_net_expense_ratio < 0.0050 THEN '2. 0.25%-0.50%'
        WHEN fund_annual_report_net_expense_ratio < 0.0075 THEN '3. 0.50%-0.75%'
        WHEN fund_annual_report_net_expense_ratio < 0.0100 THEN '4. 0.75%-1.00%'
        WHEN fund_annual_report_net_expense_ratio < 0.0125 THEN '5. 1.00%-1.25%'
        WHEN fund_annual_report_net_expense_ratio < 0.0150 THEN '6. 1.25%-1.50%'
        WHEN fund_annual_report_net_expense_ratio < 0.0200 THEN '7. 1.50%-2.00%'
        ELSE '8. Over 2.00%'
    END AS fee_band,
    COUNT(*) AS n_funds,
    AVG(fund_return_5years) AS avg_5yr_return
FROM mutual_funds
WHERE fund_annual_report_net_expense_ratio IS NOT NULL
  AND fund_return_5years IS NOT NULL
GROUP BY fee_band
ORDER BY fee_band;