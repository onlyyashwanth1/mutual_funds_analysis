-- ============================================================
-- 05_mutual_funds_vs_etfs.sql
-- Phase 5: a fairer ETF vs mutual fund comparison, and does size matter?
-- 2 queries, one per question. Run one at a time.
-- ============================================================

USE mutual_funds_analysis;


-- Q11: Do ETFs actually beat mutual funds, category by category?
-- Phase 2 compared ETFs vs mutual funds overall and found mutual funds
-- ahead -- but that mixed very different kinds of funds together (e.g.
-- bond ETFs dragging the ETF average down). This is the fairer version:
-- comparing the two fund types WITHIN the same category, so a stock fund
-- is only compared to another stock fund. Only categories that have a
-- reasonable number of BOTH fund types are shown, since a category with
-- only 1-2 ETFs isn't a fair fight.
SELECT
    fund_category,
    fund_type,
    COUNT(*) AS n_funds,
    AVG(fund_annual_report_net_expense_ratio) AS avg_fee,
    AVG(fund_return_5years) AS avg_5yr_return,
    AVG(fund_sharpe_ratio_3years) AS avg_sharpe
FROM (
    SELECT fund_type, fund_category, fund_annual_report_net_expense_ratio, fund_return_5years, fund_sharpe_ratio_3years FROM mutual_funds
    UNION ALL
    SELECT fund_type, fund_category, fund_annual_report_net_expense_ratio, fund_return_5years, fund_sharpe_ratio_3years FROM etfs
) AS combined
WHERE fund_category IS NOT NULL
  AND fund_return_5years IS NOT NULL
GROUP BY fund_category, fund_type
HAVING COUNT(*) >= 5
   AND fund_category IN (
       -- only keep categories where BOTH fund types have at least 5 funds
       SELECT fund_category FROM (
           SELECT fund_type, fund_category, COUNT(*) AS n FROM (
               SELECT fund_type, fund_category FROM mutual_funds
               UNION ALL
               SELECT fund_type, fund_category FROM etfs
           ) AS all_funds
           GROUP BY fund_type, fund_category
           HAVING n >= 5
       ) AS qualifying
       GROUP BY fund_category
       HAVING COUNT(DISTINCT fund_type) = 2
   )
ORDER BY fund_category, fund_type;


-- Q12: Does a bigger fund mean more consistent (less volatile) performance?
-- Funds are grouped into size bands based on total_net_assets, then we
-- look at the average volatility (standard deviation) in each band. If
-- size helps consistency, volatility should get lower as fund size goes
-- up.
SELECT
    CASE
        WHEN total_net_assets < 100000000 THEN '1. Under $100M'
        WHEN total_net_assets < 1000000000 THEN '2. $100M-$1B'
        WHEN total_net_assets < 10000000000 THEN '3. $1B-$10B'
        ELSE '4. Over $10B'
    END AS size_band,
    COUNT(*) AS n_funds,
    AVG(fund_stdev_3years) AS avg_volatility
FROM mutual_funds
WHERE total_net_assets IS NOT NULL
  AND fund_stdev_3years IS NOT NULL
GROUP BY size_band
ORDER BY size_band;