# Project Notes — Mutual Funds & ETFs Fee vs. Performance

Plain-English findings from each SQL phase. Source: `mutual_funds_analysis`
MySQL database.

---

## Phase 1: Data Cleaning
- Row counts confirmed correct after load (23,783 mutual funds, 2,310 ETFs)
- Missing data increases the further back you look (0.9% missing expense
  ratio, up to 47.7% missing 10-year returns) — expected, since younger
  funds don't have long history yet, not a data error
- Found and merged a naming duplicate: "First Sentier" / "First Sentier
  Investors" are the same company
- High-fee outliers (8%–11%+) are real, niche funds (e.g. cannabis-sector
  fund) — kept in the data, not errors
- 663 mutual funds have no category at all — excluded from category-based
  comparisons
- ESG score covers only 64.8% of mutual funds and 0% of ETFs — a real
  limitation on the ESG findings below

## Phase 2: Fees vs. Performance (core thesis)
- Higher fees do NOT buy better risk-adjusted returns — Sharpe ratio falls
  steadily as fees rise (0.86 at cheapest band down to 0.45 at most
  expensive)
- Worst fee-to-return categories are inverse/leveraged/energy trading
  funds — investors pay real fees for negative average returns
- Raw comparison of mutual funds vs. ETFs showed mutual funds ahead —
  later shown to be misleading (see Phase 5)
- There's a fee "tipping point" around 1.00%–1.25% — average return peaks
  there, then falls for every band beyond it

## Phase 3: Risk-Adjusted Performance
- Most top-return funds do carry higher risk (beta), but their Sharpe
  ratios are still solid — the risk was mostly rewarded, not wasted
- Several of the highest-alpha funds actually have LOW beta (e.g. beta
  0.62–0.86) — a strong signal of genuine skill, not just riding the
  market
- Higher-fee funds are MORE volatile on average, not less — the opposite
  of "you pay for stability" (10.7 volatility at cheapest band, up to 18.9
  at most expensive)

## Phase 4: Fund Family Reputation
- The best risk-adjusted fund families are mostly smaller, lesser-known
  names (e.g. RBC Global Asset Management, Day Hagan) — not the big
  brands
- The highest-fee large families do NOT include any of the true mega-
  brands (Vanguard, Fidelity, BlackRock) — the biggest, most trusted names
  actually tend to charge less, not more
- Family consistency varies a lot — some families (e.g. Blackstone) have
  nearly identical performance across their whole lineup; others are far
  more hit-or-miss

## Phase 5: Mutual Funds vs. ETFs (fair comparison)
- When compared fairly within the SAME category, ETFs beat mutual funds
  on both cost AND return in most categories (e.g. Large Growth: ETF
  22.7% return at 0.39% fee vs. Mutual Fund 17.6% at 1.10% fee) — this
  reverses the misleading raw comparison from Phase 2
  - Exceptions exist in a few bond/defensive categories where mutual
    funds do better
- Fund size has only a weak relationship with consistency — volatility
  drops slightly from 15.7 (under $100M funds) to 14.0 (over $10B funds),
  not a strong effect

## Phase 6: Allocation & ESG
- Stock allocation behaves exactly as expected — more stocks means both
  more volatility AND more return, rising steadily across every band
- ESG data has a real limitation: nearly all mutual funds with an ESG
  score cluster in the "low ESG" band; almost none score as "high" or
  "very high," so a genuine high-vs-low ESG performance comparison isn't
  possible with this data
  - Funds with any ESG score did show a higher average return than funds
    with no ESG score at all, but that's an "ESG-scored vs. not scored"
    comparison, not a high-vs-low one

## Bonus: Fee vs. Genuine Skill (alpha)
- The strongest single finding in the project: average alpha is NEGATIVE
  in every fee band, and gets WORSE as fees rise — from -0.43 at the
  cheapest band down to -3.03 at the most expensive band
- This is the clearest, most direct evidence for the core thesis: higher
  fees are associated with worse, not better, risk-adjusted skill
  - Caveat: alpha is typically calculated after fees are deducted, so part
    of this drop is fees mechanically eating into the number, not purely
    "worse managers" — still a real and meaningful result
- A best-fund-per-category ranking (using a window function) showed most
  top-Sharpe funds per category carry moderate-to-low fees, with a small
  number of outliers charging noticeably more (up to ~3%+) — a softer
  version of the same pattern, not a clean rule

---

## Overall answer to the core thesis
Across four independent measures — raw return, Sharpe ratio, volatility,
and alpha — higher fees consistently failed to buy better performance,
and in the case of alpha, were associated with measurably worse results.
Brand-name fund families don't charge more than smaller ones, and ETFs
generally outperform mutual funds once compared fairly within the same
category. The clearest exception and honest limitation is ESG: the data
doesn't have enough spread in ESG scores to test that part of the thesis
with real confidence.