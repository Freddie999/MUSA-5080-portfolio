# Assignment 5

All executable analysis is in `assignments/assignment5.qmd`, organized by assignment part. There are no external analysis, download or validation scripts and no fitted-results cache dependency.

From the portfolio root, run:

```sh
quarto render assignments/assignment5.qmd
```

Each render downloads the 2023 ACS income estimates and tract geometry directly with `get_acs(geometry = TRUE)`, then performs the cleaning, feature construction, grouped cross-validation, model selection, audit evaluation, final fit, checks and exports. The QMD does not read or write local RDS caches. Internet access and the existing local Census-key configuration are needed; credentials are never included in the QMD.

## Outputs

- `model_log.csv`: the eight current course-style formulas, with grouped development CV RMSE and five-neighbor residual Moran's I. All use median filling within fitting folds and the same nonnegative output rule.
- `cleaning_log.csv`: sequential training exclusions. No test records are removed.
- `development_folds.csv`: exact fold assignments and rounded-coordinate group proxy.
- `audit_predictions.csv`: separate audit predictions, errors, ratios and income groups; not the instructor's hidden test.
- `team_XX_predictions.csv`: every test ID in original input order, with finite nonnegative predictions. Replace `XX` with the actual team number.
- `predictions_needing_review.csv`: zero-valued test predictions and key attributes. These records remain in the full export.

The QMD includes source links, modeling assumptions, evaluation limitations and independent numerical assertions. Team details, actual contributions and course AI-policy confirmation still require review. No submission, git commit, push or external publication has been performed.

The code was simplified on October 29. Earlier formulas/results are recorded separately in the QMD and backed up under `review/assignment5-simplification-2026-10-29/`. They should not be pooled with the current comparison because preprocessing, fold assignment and weights differ. The experimental grid-specific size-slope model from the separate review was not added.
