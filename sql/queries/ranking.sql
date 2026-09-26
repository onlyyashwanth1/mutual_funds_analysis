-- ============================================================
-- 07_bonus_insights.sql
-- Two gaps worth closing: we never tested fee vs. genuine skill (alpha)
-- directly, and we never used a window function. Both add real value,
-- not just extra queries. Run one at a time.
-- ============================================================

USE mutual_funds_analysis;


-- Q18: Does paying more actually buy more genuine skill (alpha)?
-- We already checked fee vs. return, fee vs. Sharpe, and fee vs.
-- volatility -- but alpha is the purest "skill" measure in this data, and
-- we never tested it directly. Same fee-banding approach as before.
SELECT
    CASE
        WHEN fund_annual_report_net_expense_ratio < 0.005 THEN '1. Under 0.5%'
        WHEN fund_annual_report_net_expense_ratio < 0.010 THEN '2. 0.5%-1.0%'
        WHEN fund_annual_report_net_expense_ratio < 0.015 THEN '3. 1.0%-1.5%'
        WHEN fund_annual_report_net_expense_ratio < 0.020 THEN '4. 1.5%-2.0%'
        ELSE '5. Over 2.0%'
    END AS fee_band,
    COUNT(*) AS n_funds,
    AVG(fund_alpha_3years) AS avg_alpha
FROM mutual_funds
WHERE fund_annual_report_net_expense_ratio IS NOT NULL
  AND fund_alpha_3years IS NOT NULL
GROUP BY fee_band
ORDER BY fee_band;


-- Q19: What's the single best fund in every category, and is it cheap or pricey?
-- RANK() numbers every fund from 1 (best Sharpe ratio) within its own
-- category -- so instead of one big list, each category gets its own
-- ranking. The outer query then keeps only the #1 fund per category. This
-- gives an actual, practical answer: "if I wanted the best fund in each
-- category, which one is it, and does it happen to be expensive?"
-- Categories under 5 funds are excluded, same reliability rule as before.
SELECT fund_category, fund_symbol, fund_long_name, fund_sharpe_ratio_3years, fund_annual_report_net_expense_ratio
FROM (
    SELECT
        fund_category, fund_symbol, fund_long_name,
        fund_sharpe_ratio_3years, fund_annual_report_net_expense_ratio,
        COUNT(*) OVER (PARTITION BY fund_category) AS category_size,
        RANK() OVER (PARTITION BY fund_category ORDER BY fund_sharpe_ratio_3years DESC) AS rank_in_category
    FROM mutual_funds
    WHERE fund_category IS NOT NULL
      AND fund_sharpe_ratio_3years IS NOT NULL
      AND fund_annual_report_net_expense_ratio IS NOT NULL
) AS ranked
WHERE rank_in_category = 1
  AND category_size >= 5
ORDER BY fund_category;