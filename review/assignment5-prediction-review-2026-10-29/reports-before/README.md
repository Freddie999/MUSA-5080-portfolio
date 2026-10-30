# Assignment 5

All executable analysis is in `assignments/assignment5.qmd`, organized by assignment part. There are no external analysis, download or validation scripts and no fitted-results cache dependency.

From the portfolio root, run:

```sh
quarto render assignments/assignment5.qmd
```

Each render downloads the 2023 ACS income estimates and tract geometry directly with `get_acs(geometry = TRUE)`, then performs cleaning, feature construction, grouped cross-validation on all cleaned training rows, model selection, out-of-fold residual and LISA diagnostics, the final fit, checks and exports. The QMD does not read or write local RDS caches. Internet access and the existing local Census-key configuration are needed; credentials are never included in the QMD.

## Outputs

- `model_log.csv`: eight current formulas, with grouped 10-fold CV RMSE on all cleaned training rows and five-neighbor residual Moran's I. All use median filling within fitting folds. Raw predictions are scored without a zero bound.
- `cleaning_log.csv`: sequential training exclusions. No test records are removed.
- `training_folds.csv`: fold assignments for all cleaned training rows and the rounded-coordinate group proxy.
- `oof_predictions.csv`: out-of-fold predictions, errors, ratios and income groups for all cleaned training rows. These predictions are also used in model selection, so they are not an independent test.
- `lisa_counts.csv`: exploratory local Moran classifications for baseline and selected-model out-of-fold errors, using 499 permutations and alpha 0.01.
- `income_ratios.csv` and `price_band_ratios.csv`: out-of-fold valuation-ratio diagnostics.
- `team_XX_predictions.csv`: every test ID in original input order, with finite raw predictions. Replace `XX` with the actual team number. Nonpositive predictions require review before submission.
- `predictions_needing_review.csv`: nonpositive raw test predictions and key attributes. These records remain in the full export.

The QMD includes source links, modeling assumptions, evaluation limitations and independent numerical assertions. Team details, actual contributions and course AI-policy confirmation still require review. No submission, git commit, push or external publication has been performed.

The code was simplified on October 29. The custom grid, zero bound and extra development/audit split are no longer used. Tract categories follow the district-factor pattern; small categories are pooled and fold coverage is checked. Earlier formulas/results are recorded separately in the QMD. The version immediately before this revision and its reports are backed up under `review/assignment5-class-workflow-2026-10-29/`. They should not be pooled with the current comparison because rows, preprocessing and/or weights differ. The experimental grid-specific size-slope model from the separate review was not added.
