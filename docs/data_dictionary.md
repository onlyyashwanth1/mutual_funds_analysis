# Data Dictionary — Mutual Funds & ETFs Fee vs. Performance Project

This document explains every column kept in the trimmed dataset, in plain
English, so each one can be defended in an interview without hand-waving.

Source: Kaggle `stefanoleone992/mutual-funds-and-etfs` (Yahoo Finance scrape).
Tables: `mutual_funds` (22 columns, 23,783 rows) and `etfs` (18 columns,
2,310 rows). Columns marked **(MF only)** exist only in `mutual_funds`.

---

## Identity / descriptive columns

### `fund_symbol`
The fund's ticker symbol (e.g. `VFIAX`, `SPY`). Unique per fund — this is
the **primary key** in both tables.

### `fund_long_name`
The fund's full official name (e.g. "Vanguard 500 Index Fund Admiral
Shares"). Human-readable label, not used in calculations.

### `fund_category`
Morningstar-style category describing what the fund invests in (e.g.
"Large Blend", "Foreign Large Growth", "Intermediate Core Bond"). This is
how we group funds to compare like-for-like — comparing a bond fund's
return to a small-cap stock fund's return would be meaningless.

### `fund_family`
The company that manages the fund (e.g. Vanguard, Fidelity, BlackRock).
Used for the "does a trusted brand actually perform better, or just charge
more" question in Phase 4.

### `fund_type`
**Not in the original data — we added this column ourselves** while
trimming, tagging every row as `'Mutual Fund'` or `'ETF'`. This is what
lets us `UNION` both tables together and compare the two fund structures
directly in Phase 5.

---

## Size

### `total_net_assets`
Total dollar value of everything the fund holds (its size), in USD. A
$500 billion fund and a $10 million fund behave very differently — bigger
funds are usually more stable/liquid, and this column lets us test whether
size relates to performance consistency (Phase 5, question 12).

---

## Cost

### `fund_annual_report_net_expense_ratio`
The fund's yearly fee, expressed as a decimal fraction of your investment
(e.g. `0.0122` = 1.22% per year). This is the single most important column
in the whole project — it's the "cost" side of every fee-vs-performance
question. A lower number is cheaper for the investor.

---

## Returns (how much money you made)

All return columns are decimals representing percentage gain over the
stated period (e.g. `0.09078` = 9.08%). These are **raw returns** — they
don't account for risk taken to get there, which is why we also need the
risk-adjusted columns below.

### `fund_return_ytd`
Return so far in the current calendar year ("year to date").

### `fund_return_1year`
Return over the trailing 1 year.

### `fund_return_3years`
Annualized return over the trailing 3 years.

### `fund_return_5years`
Annualized return over the trailing 5 years.

### `fund_return_10years`
Annualized return over the trailing 10 years. **Expect a lot of NULLs
here** — many funds are younger than 10 years old and simply don't have
this history yet. That's a genuine, explainable data pattern, not a data
quality bug (already confirmed in Step 5).

---

## Risk & risk-adjusted performance (the "was it worth it" columns)

These four columns are pre-calculated statistics — we query them, we never
recompute them from scratch, since deriving Sharpe/alpha/beta manually is
out of scope for this project.

### `fund_alpha_3years`
Measures **manager skill**. Alpha is the extra return a fund produced
beyond what you'd expect just from its exposure to the market (its beta).
A positive alpha means the manager added value; a negative alpha means the
fund underperformed what its risk level would predict — i.e. you'd have
done just as well or better in a passive index fund with the same risk.
This is central to the "does active management actually work" thesis.

### `fund_beta_3years`
Measures **market sensitivity**. Beta of `1.0` means the fund moves in
line with the overall market. Beta above `1.0` means it swings harder than
the market (more upside in a rally, more downside in a crash); below `1.0`
means it's more muted than the market. Beta tells us how much of a fund's
return is just "riding the market" rather than skill.

### `fund_stdev_3years`
**Standard deviation** — how much the fund's returns bounce around over
time. Higher stdev = more volatile / bumpier ride, even if the average
return looks good. Used to check whether higher-fee funds actually manage
risk better (Phase 3, question 7).

### `fund_sharpe_ratio_3years`
**Risk-adjusted return** — return earned per unit of risk taken (return
divided by volatility, roughly). This is the fairest single number for
comparing two funds with different risk levels: a fund with a high raw
return but a low Sharpe ratio was "juicing" its numbers by taking on extra
risk, not by being genuinely better.

---

## Portfolio composition

### `asset_stocks`
Percentage of the fund's holdings that are in stocks (equities), as a
decimal (e.g. `0.95` = 95% stocks).

### `asset_bonds`
Percentage of the fund's holdings that are in bonds. Used with
`asset_stocks` in Phase 6 to test whether a fund's stock/bond mix explains
its volatility and return — e.g. a fund that's 90% stocks should be more
volatile than one that's 60% stocks / 40% bonds.

---

## MF-only columns (no equivalent exists in the ETFs.csv data)

### `morningstar_overall_rating` (MF only)
Morningstar's star rating (1–5) summarizing the fund's historical
risk-adjusted performance versus category peers. A well-known,
independently calculated reputation signal — used to test whether
"reputation" (high star rating) correlates with genuinely better numbers,
or is partly just a brand/marketing effect.

### `morningstar_risk_rating` (MF only)
Morningstar's separate rating (1–5) specifically for how risky the fund
has been relative to its category, independent of the overall star rating.

### `esg_score` (MF only)
A sustainability/ESG (Environmental, Social, Governance) score reflecting
how the fund's holdings score on non-financial responsible-investing
criteria. Used in Phase 6 to test whether ESG-focused funds sacrifice
performance.

### `sustainability_score` (MF only)
A related sustainability metric, used alongside `esg_score` for the same
ESG-vs-performance and ESG-fee-premium questions.

**Important, genuine data limitation:** none of these four columns exist in
the ETFs.csv source file at all — not just missing values, but the columns
themselves aren't present. This means the ESG insight (Phase 6, questions
15–16) can only be answered for mutual funds, not ETFs. This is documented
honestly as a real characteristic of the source data, not a gap to
paper over.

---

## Column summary table

| Column | In mutual_funds | In etfs | Type |
|---|---|---|---|
| fund_symbol (PK) | ✅ | ✅ | identity |
| fund_long_name | ✅ | ✅ | identity |
| fund_category | ✅ | ✅ | identity |
| fund_family | ✅ | ✅ | identity |
| fund_type (added) | ✅ | ✅ | identity |
| total_net_assets | ✅ | ✅ | size |
| fund_annual_report_net_expense_ratio | ✅ | ✅ | cost |
| fund_return_ytd | ✅ | ✅ | return |
| fund_return_1year | ✅ | ✅ | return |
| fund_return_3years | ✅ | ✅ | return |
| fund_return_5years | ✅ | ✅ | return |
| fund_return_10years | ✅ | ✅ | return |
| fund_alpha_3years | ✅ | ✅ | risk-adjusted |
| fund_beta_3years | ✅ | ✅ | risk-adjusted |
| fund_stdev_3years | ✅ | ✅ | risk-adjusted |
| fund_sharpe_ratio_3years | ✅ | ✅ | risk-adjusted |
| asset_stocks | ✅ | ✅ | allocation |
| asset_bonds | ✅ | ✅ | allocation |
| morningstar_overall_rating | ✅ | ❌ | reputation |
| morningstar_risk_rating | ✅ | ❌ | reputation |
| esg_score | ✅ | ❌ | ESG |
| sustainability_score | ✅ | ❌ | ESG |

**Total: 22 columns in `mutual_funds`, 18 columns in `etfs`.**