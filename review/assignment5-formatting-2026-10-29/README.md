# Assignment 5 formatting and requirement review

Status: **Share with caveats** for the analytical document. The submission still requires the actual team number/filename, team review and portfolio/Canvas delivery. This review covers the instructions included in the QMD; it does not certify a hidden test score or unprovided course policies.

## Presentation repairs

- Replaced split/truncated console tibbles with HTML tables using `df-print: kable` and explicit `knitr::kable()` calls.
- Kept detailed inspection code available but hid its long console output. Selected input records and price summaries are shown as tables instead.
- Added readable column headings, dollar formatting, appropriate precision and explicit numeric alignment. Display formatting does not change exported values.
- Added a small page-local style block to keep numbers on one line and contain horizontal scrolling. No new external stylesheet dependency remains.
- Collapsed the long full regression summary; a concise coefficient table and the full formula remain accessible.
- Separated the LISA count table and map into distinct chunks so the figure caption is attached to the map.
- Restored the 24-model and eight-model historical tables in collapsed appendix sections, as requested. Their different evaluation setups are disclosed.
- Preserved the supplied team names/contributions and policy. Clarified actual AI assistance with comparisons and drafted explanations.

## Requirements checked

| Requirement | Evidence/result |
|---|---|
| Clean training once; retain all test rows | 23,200 original training rows; 1,232 multi-parcel exclusions; 21,968 retained. All 5,789 test IDs remain in original order. |
| Explain cleaning rules and removal counts | Cleaning log, missingness table and market-sale reasoning are present. Positive price tails are retained. |
| At least four exploration plots, including price map | Histogram, size-price, age-price and price map are present and load in the browser. |
| Appropriate time window | Both supplied splits have 2023–2025 dates. Census vintage is 2023; five-year income estimates are explicitly retrospective diagnostics, not predictors. |
| No price-derived features; dollar outcome | Candidate formulas retain `sale_price` as the response; no neighboring-price or income predictor is used. |
| Consistent validation and missingness handling | Same grouped folds for current candidates; medians are calculated inside fitting folds. Rounded coordinates are disclosed as a property-ID proxy. |
| Model log and reasons for each trial | Twelve current models include reasons, CV RMSE and Moran's I. Restored historical tables cover previous assignment workflows. |
| Feature engineering, including spatial features | Logs, squares, timing factors, distance/rings, tract effects and interactions are present and explained. |
| Final model and baseline/final residual maps | Selected formula, accessible coefficients/full summary and out-of-fold comparison maps are present. |
| Error analysis: where and direction | Worst individual errors, tract MAE, signed residual interpretation and plausible limitations are discussed. |
| Valuation ratios by neighborhood income | Group counts, median and aggregate ratios, overprediction shares and MAE reconcile independently. Cleaning and Tax Divide discussion are included. |
| Predict all test houses; export CSV | Every test ID has a finite raw prediction in `team_XX_predictions.csv`. The actual team number is still needed. |
| Reflection about 300 words, both questions answered | Approximately 305 words; interprets central-air beta/prediction effect and explains operational limitations. |
| Team contributions and AI statement | All four supplied names and contributions are present; the policy and actual-use statement are filled in. Actual team review cannot be performed on their behalf. |

## Verification

The final Quarto render succeeded with the live Census call. Predictions are identical to `predictions-before.csv`; all numerical CV RMSE and Moran's I values match `model-log-before.csv`. Independently computed CV RMSE is $198,334.53 and Moran's I is 0.1805985. Income-group counts and valuation ratios reconcile. All restored historical rows match their archived CSV results at displayed precision.

Browser checks used the existing localhost preview: 37 table structures have consistent column counts, there are no remaining raw tibble console blocks, and all seven figures load. The current-model, coefficient and historical tables were checked, including at a 600-pixel viewport. Numeric cells stay on one line, and the page has no horizontal overflow. The viewport and collapsed sections were restored. `model-table-after.jpg` records the final desktop view.

`git diff --check` passed. The full-site checker reports no Assignment 5 issues; its one remaining finding is an unrelated missing image description on the user's Week 8 page, which was not changed here.

The three negative test predictions and substantial low-price proportional overvaluation remain explicit model limitations. Nothing was committed, pushed or submitted.
