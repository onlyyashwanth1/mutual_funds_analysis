-- ============================================================
-- create_tables.sql
-- Schema for Mutual Funds & ETFs — Fee vs Performance Analysis
-- Matches the columns produced by scripts/trim_columns.py
-- ============================================================

CREATE DATABASE IF NOT EXISTS mutual_funds_analysis;
USE mutual_funds_analysis;

DROP TABLE IF EXISTS mutual_funds;
DROP TABLE IF EXISTS etfs;


-- ------------------------------------------------------------
-- MUTUAL FUNDS  (22 columns: 17 shared + fund_type + 4 mutual-fund-only)
-- ------------------------------------------------------------
CREATE TABLE mutual_funds (
    fund_symbol                            VARCHAR(20)     PRIMARY KEY,
    fund_long_name                         VARCHAR(255),
    fund_category                          VARCHAR(100),
    fund_family                            VARCHAR(150),
    total_net_assets                       DECIMAL(20,2),
    fund_annual_report_net_expense_ratio   DECIMAL(8,5),   -- e.g. 0.0122 = 1.22%
    fund_return_ytd                        DECIMAL(10,5),
    fund_return_1year                      DECIMAL(10,5),
    fund_return_3years                     DECIMAL(10,5),
    fund_return_5years                     DECIMAL(10,5),
    fund_return_10years                    DECIMAL(10,5),
    fund_alpha_3years                      DECIMAL(10,5),
    fund_beta_3years                       DECIMAL(10,5),
    fund_stdev_3years                      DECIMAL(10,5),
    fund_sharpe_ratio_3years               DECIMAL(10,5),
    asset_stocks                           DECIMAL(10,5),
    asset_bonds                            DECIMAL(10,5),
    fund_type                              VARCHAR(20),    -- always 'Mutual Fund' here
    morningstar_overall_rating             DECIMAL(4,2)    NULL,
    morningstar_risk_rating                DECIMAL(4,2)    NULL,
    esg_score                              DECIMAL(10,5)   NULL,
    sustainability_score                   DECIMAL(10,5)   NULL
);


-- ------------------------------------------------------------
-- ETFS  (18 columns: 17 shared + fund_type)
-- Note: ETFs.csv has no Morningstar rating or ESG columns at all —
-- this is a real data limitation, not something we're hiding.
-- ------------------------------------------------------------
CREATE TABLE etfs (
    fund_symbol                            VARCHAR(20)     PRIMARY KEY,
    fund_long_name                         VARCHAR(255),
    fund_category                          VARCHAR(100),
    fund_family                            VARCHAR(150),
    total_net_assets                       DECIMAL(20,2),
    fund_annual_report_net_expense_ratio   DECIMAL(8,5),
    fund_return_ytd                        DECIMAL(10,5),
    fund_return_1year                      DECIMAL(10,5),
    fund_return_3years                     DECIMAL(10,5),
    fund_return_5years                     DECIMAL(10,5),
    fund_return_10years                    DECIMAL(10,5),
    fund_alpha_3years                      DECIMAL(10,5),
    fund_beta_3years                       DECIMAL(10,5),
    fund_stdev_3years                      DECIMAL(10,5),
    fund_sharpe_ratio_3years               DECIMAL(10,5),
    asset_stocks                           DECIMAL(10,5),
    asset_bonds                            DECIMAL(10,5),
    fund_type                              VARCHAR(20)     -- always 'ETF' here
);