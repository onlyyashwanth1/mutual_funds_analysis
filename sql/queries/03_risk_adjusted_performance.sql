-- ============================================================
-- 03_risk_adjusted_performance.sql
-- Phase 3: is the return actually good, or just risky?
-- 3 queries, one per question. Run one at a time.
-- ============================================================

USE mutual_funds_analysis;


-- Q5: Which top-return funds are hiding high risk?
-- This pulls the 20 mutual funds with the highest 5-year return, and shows
-- their beta and Sharpe ratio right alongside. A fund near the top of this
-- list with a high beta (swings harder than the market) and a low Sharpe
-- ratio (poor return-per-unit-of-risk) is a fund whose "great return" was
-- mostly just extra risk-taking, not skill.
SELECT fund_symbol, fund_long_name, fund_return_5years, fund_beta_3years, fund_sharpe_ratio_3years
FROM mutual_funds
WHERE fund_return_5years IS NOT NULL
  AND fund_beta_3years IS NOT NULL
  AND fund_sharpe_ratio_3years IS NOT NULL
ORDER BY fund_return_5years DESC
LIMIT 20;


-- Q6: Genuine skill (alpha) vs. just riding the market (beta)?
-- This pulls the 20 mutual funds with the highest alpha -- alpha is the
-- part of a fund's return that ISN'T explained by simply tracking the
-- market, so a high alpha is the closest thing this data has to "manager
-- skill." Beta is shown alongside so we can tell the difference: high
-- alpha + normal beta (around 1.0) = genuine skill. High alpha + very
-- high beta = probably just an aggressive fund that got lucky.
SELECT fund_symbol, fund_long_name, fund_alpha_3years, fund_beta_3years, fund_return_5years
FROM mutual_funds
WHERE fund_alpha_3years IS NOT NULL
  AND fund_beta_3years IS NOT NULL
ORDER BY fund_alpha_3years DESC
LIMIT 20;


-- Q7: Do higher-fee funds actually manage risk better?
-- Same fee-banding approach as Phase 2, but this time looking at average
-- standard deviation (volatility) instead of return. If higher fees paid
-- for better risk management, we'd expect stdev to go DOWN as fees go up.
SELECT
    CASE
        WHEN fund_annual_report_net_expense_ratio < 0.005 THEN '1. Under 0.5%'
        WHEN fund_annual_report_net_expense_ratio < 0.010 THEN '2. 0.5%-1.0%'
        WHEN fund_annual_report_net_expense_ratio < 0.015 THEN '3. 1.0%-1.5%'
        WHEN fund_annual_report_net_expense_ratio < 0.020 THEN '4. 1.5%-2.0%'
        ELSE '5. Over 2.0%'
    END AS fee_band,
    COUNT(*) AS n_funds,
    AVG(fund_stdev_3years) AS avg_volatility
FROM mutual_funds
WHERE fund_annual_report_net_expense_ratio IS NOT NULL
  AND fund_stdev_3years IS NOT NULL
GROUP BY fee_band
ORDER BY fee_band;