-- ============================================================
-- 06_category_allocation_esg.sql
-- Phase 6: does allocation mix explain risk, and do ESG funds sacrifice
-- performance or charge a premium?
-- 2 queries -- keeping this phase tight since 12 insights are already
-- covered across Phases 2-5. Run one at a time.
-- ============================================================

USE mutual_funds_analysis;


-- Q14: Does a fund's stock/bond mix explain its volatility and return?
-- Funds are grouped by how much of their portfolio is in stocks. The
-- expectation going in: more stocks = more volatility, but usually more
-- return too. This checks whether the real data actually follows that
-- textbook pattern.
SELECT
    CASE
        WHEN asset_stocks < 0.25 THEN '1. Under 25% stocks'
        WHEN asset_stocks < 0.50 THEN '2. 25%-50% stocks'
        WHEN asset_stocks < 0.75 THEN '3. 50%-75% stocks'
        WHEN asset_stocks < 0.95 THEN '4. 75%-95% stocks'
        ELSE '5. 95%+ stocks'
    END AS stock_allocation_band,
    COUNT(*) AS n_funds,
    AVG(fund_stdev_3years) AS avg_volatility,
    AVG(fund_return_5years) AS avg_5yr_return
FROM mutual_funds
WHERE asset_stocks IS NOT NULL
  AND fund_stdev_3years IS NOT NULL
GROUP BY stock_allocation_band
ORDER BY stock_allocation_band;


-- Q15 + Q16: Do ESG-focused funds sacrifice performance, and do they cost more?
-- Mutual funds only -- ETFs have no ESG data at all (documented in the
-- data quality report). Funds are grouped into ESG score bands, then we
-- compare average fee, average return, and average Sharpe ratio across
-- bands. If ESG funds charge a "sustainability premium," fees should
-- climb with the ESG band. If ESG funds sacrifice performance, return and
-- Sharpe should drop as the ESG band goes up.
SELECT
    CASE
        WHEN esg_score IS NULL THEN '0. No ESG score'
        WHEN esg_score < 40 THEN '1. Low ESG (under 40)'
        WHEN esg_score < 60 THEN '2. Medium ESG (40-60)'
        WHEN esg_score < 80 THEN '3. High ESG (60-80)'
        ELSE '4. Very high ESG (80+)'
    END AS esg_band,
    COUNT(*) AS n_funds,
    AVG(fund_annual_report_net_expense_ratio) AS avg_fee,
    AVG(fund_return_5years) AS avg_5yr_return,
    AVG(fund_sharpe_ratio_3years) AS avg_sharpe
FROM mutual_funds
GROUP BY esg_band
ORDER BY esg_band;