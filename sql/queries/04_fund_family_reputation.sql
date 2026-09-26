-- ============================================================
-- 04_fund_family_reputation.sql
-- Phase 4: do trusted fund families actually earn the trust?
-- 3 queries, one per question. Run one at a time.
-- Note: "First Sentier" and "First Sentier Investors" are merged into one
-- name here, per the naming issue found in the data quality report.
-- ============================================================

USE mutual_funds_analysis;


-- Q8: Which fund families deliver the best risk-adjusted returns?
-- This groups every mutual fund by its family and averages the Sharpe
-- ratio across that family's whole lineup -- not just one lucky fund.
-- Families with fewer than 5 funds are excluded, since an average across
-- 1-2 funds isn't a real reflection of a "family" track record.
SELECT
    CASE WHEN fund_family IN ('First Sentier', 'First Sentier Investors') THEN 'First Sentier Investors' ELSE fund_family END AS fund_family,
    COUNT(*) AS n_funds,
    AVG(fund_sharpe_ratio_3years) AS avg_sharpe
FROM mutual_funds
WHERE fund_family IS NOT NULL
  AND fund_sharpe_ratio_3years IS NOT NULL
GROUP BY fund_family
HAVING COUNT(*) >= 5
ORDER BY avg_sharpe DESC
LIMIT 20;


-- Q9: Do bigger, better-known fund families charge more without performing better?
-- We don't have a "brand trust" score in the data, so fund count is used
-- as a stand-in for "well-known" -- a family with hundreds of funds is a
-- major, recognizable player. This shows their average fee next to their
-- average return, so we can see whether the big names charge a premium
-- and whether that premium is actually earning better performance.
SELECT
    CASE WHEN fund_family IN ('First Sentier', 'First Sentier Investors') THEN 'First Sentier Investors' ELSE fund_family END AS fund_family,
    COUNT(*) AS n_funds,
    AVG(fund_annual_report_net_expense_ratio) AS avg_fee,
    AVG(fund_return_5years) AS avg_5yr_return,
    AVG(fund_sharpe_ratio_3years) AS avg_sharpe
FROM mutual_funds
WHERE fund_family IS NOT NULL
  AND fund_annual_report_net_expense_ratio IS NOT NULL
GROUP BY fund_family
HAVING COUNT(*) >= 20
ORDER BY avg_fee DESC
LIMIT 20;


-- Q10: Which fund families are consistent vs. hit-or-miss?
-- This measures how much a family's own funds vary from each other, using
-- the standard deviation of their 5-year returns across the whole lineup.
-- A LOW number means every fund in that family performs about the same
-- (consistent). A HIGH number means the family has some big winners and
-- some big losers mixed together (hit-or-miss). Sorted most consistent
-- first -- flip to DESC to see the most hit-or-miss families instead.
SELECT
    CASE WHEN fund_family IN ('First Sentier', 'First Sentier Investors') THEN 'First Sentier Investors' ELSE fund_family END AS fund_family,
    COUNT(*) AS n_funds,
    AVG(fund_return_5years) AS avg_5yr_return,
    STDDEV(fund_return_5years) AS return_spread
FROM mutual_funds
WHERE fund_family IS NOT NULL
  AND fund_return_5years IS NOT NULL
GROUP BY fund_family
HAVING COUNT(*) >= 5
ORDER BY return_spread ASC
LIMIT 20;