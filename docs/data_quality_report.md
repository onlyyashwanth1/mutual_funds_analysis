# Data Quality Report — Mutual Funds & ETFs Project

Findings from running `sql/queries/01_data_cleaning.sql` against the loaded
MySQL tables. No rows were deleted or changed — this documents what the
real data looks like so later phases handle it correctly.

---

## 1. Row counts — clean
`mutual_funds` = 23,783 rows, `etfs` = 2,310 rows. Matches the original
load exactly. No data lost.

## 2. Missing values — expected, explainable pattern
Missing data increases the further back the time period goes:

| Column | Missing | % |
|---|---|---|
| Expense ratio | 210 | 0.9% |
| 1-year return | 896 | 3.8% |
| Sharpe ratio (3yr) | 1,701 | 7.2% |
| 5-year return | 6,760 | 28.4% |
| 10-year return | 11,346 | 47.7% |

This matches the expected cause: younger funds simply don't have long-term
history yet. Not a data error.

**Decision for later phases:** the ~210 funds missing an expense ratio
naturally drop out of any fee-vs-return query (can't compare a fee that
doesn't exist). The ~1,701 missing a Sharpe ratio will be excluded
specifically from Phase 3 (risk-adjusted performance). Nearly half of
funds can't be used for 10-year comparisons — any 10-year finding applies
only to the older subset of funds, not the whole dataset, and will be
labeled that way.

## 3. fund_family naming — one real duplicate found
**"First Sentier" and "First Sentier Investors"** are almost certainly the
same company split into two names (1 fund each). These will be merged
under one name before Phase 4 (fund family comparison), so the company
isn't undercounted.

"BNY Mellon" (784 funds) vs "BNY Mellon Funds" (24 funds) is a borderline
case — may be a genuine sub-brand rather than a naming error. Left as-is
for now; flagged for a second look if BNY Mellon results look odd in
Phase 4.

## 4. Outliers — high fees on niche funds, not broken data
Every flagged row was a high expense ratio (8%–11%+), all belonging to
small, niche funds (e.g. a cannabis-sector fund, a bear-market fund).
No extreme return values or negative expense ratios were found. This is
treated as a real, explainable characteristic of niche funds — not
removed from the data.

## 5. Duplicate fund symbols — clean
Zero duplicates. The `fund_symbol` primary key is solid.

## 6. Category sizes — one real gap found
**663 mutual funds have no `fund_category` value at all.** This is a
genuine gap in the source data. These 663 funds will be excluded from any
category-based comparison (or labeled "Uncategorized") rather than folded
into an existing category.

Several legitimate categories also have very few funds (some with just 1),
e.g. `Market Neutral`, `Long-Short Credit`. Any average computed from a
category under ~5 funds will be flagged as low-confidence rather than
treated as a solid finding.

## 7. ESG / Morningstar coverage — decent, not universal
Out of 23,783 mutual funds:

| Field | Has a value | % |
|---|---|---|
| ESG score | 15,407 | 64.8% |
| Morningstar overall rating | 21,976 | 92.4% |

Morningstar ratings are well covered — usable for almost all mutual funds.
ESG scores are less complete — about 1 in 3 mutual funds has no ESG score
at all, on top of ETFs having none whatsoever. This is a second, real
limitation on the ESG insight (Phase 6): it will be based on roughly
two-thirds of mutual funds, and won't cover ETFs at all. Both limits are
stated plainly in that phase's write-up rather than glossed over.

---



## 8. Row counts represent fund records, not distinct fund companies
The 23,783 mutual fund rows are **not** 23,783 distinct fund products. US
regulatory data (ICI, 2024) puts the actual number of mutual funds
domiciled in the US at roughly 7,000. The gap is explained by **share
classes**: many fund companies sell the same underlying portfolio under
several share classes (e.g. Investor, Admiral/Institutional, or Class
A/B/C for load structure), each with its own fee, minimum investment, and
ticker — and each gets its own row in this dataset.

This is not a data error and no rows were removed for it. Different share
classes of the same fund genuinely do carry different expense ratios, so
keeping them as separate records is correct for the fee-vs-performance
analysis. It does mean "23,783 mutual funds" should be read as "23,783
fund/share-class records," not as 23,783 unrelated companies.

**Decision for later phases:** no change to existing queries — this is a
documentation note, not a cleaning step. Worth stating plainly if asked in
review, since the raw row count alone overstates how many distinct fund
products actually exist.

---

## Summary of decisions carried into later phases
- Merge "First Sentier" / "First Sentier Investors" into one fund family
- Exclude the 663 uncategorized funds from category comparisons
- Flag category averages built from fewer than ~5 funds as low-confidence
- Exclude funds missing an expense ratio from fee-vs-return queries
- Exclude funds missing a Sharpe ratio from Phase 3 specifically
- Treat 10-year findings as applying to the older-fund subset only, not
  the full dataset
- High-fee niche funds kept as-is — real data, not errors
- Phase 6 ESG insight is scoped to the ~65% of mutual funds with an ESG
  score, and explicitly excludes ETFs (no ESG data exists for them)