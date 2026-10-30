# Assignment 5

All executable analysis is in `assignments/assignment5.qmd`, organized by assignment part. There are no external analysis, download or validation scripts and no fitted-results cache dependency.

From the portfolio root, run:

```sh
quarto render assignments/assignment5.qmd
```

Each render downloads the 2023 ACS income estimates and tract geometry directly with `get_acs(geometry = TRUE)`, then performs cleaning, feature construction, grouped cross-validation on all cleaned training rows, model selection, out-of-fold residual and LISA diagnostics, the final fit, checks and exports. The QMD does not read or write local RDS caches. Internet access and the existing local Census-key configuration are needed; credentials are never included in the QMD.

## Outputs

- `model_log.csv`: twelve current formulas, with grouped 10-fold CV RMSE on all cleaned training rows and five-neighbor residual Moran's I. All use median filling within fitting folds. Raw predictions are scored without a zero bound. `Age_by_ring` has the lowest CV RMSE, about $198,335; its improvement over `Tract_size_slopes` is small.
- `size_alternatives.csv` and `low_price_comparison.csv`: the original tract model, three class-based size alternatives, and the age-by-ring follow-up, including negative held-out predictions and low-price valuation ratios.
- `fold_comparison.csv`: the earlier tract model versus the selected local-size model within the same ten folds; the selected model improves nine of them.
- `cleaning_log.csv`: sequential training exclusions. No test records are removed.
- `training_folds.csv`: fold assignments for all cleaned training rows and the rounded-coordinate group proxy.
- `oof_predictions.csv`: out-of-fold predictions, errors, ratios and income groups for all cleaned training rows. These predictions are also used in model selection, so they are not an independent test.
- `lisa_counts.csv`: exploratory local Moran classifications for baseline and selected-model out-of-fold errors, using 499 permutations and alpha 0.01.
- `income_ratios.csv` and `price_band_ratios.csv`: out-of-fold valuation-ratio diagnostics.
- `team_XX_predictions.csv`: every test ID in original input order, with finite raw predictions. Replace `XX` with the actual team number. Remaining nonpositive outputs have been investigated and retained as documented model failures.
- `predictions_needing_review.csv`: nonpositive raw test predictions and key attributes. The legacy filename is retained; the tract-context review is documented in the QMD. These records remain in the full export.
- `negative_oof_predictions.csv`: remaining negative held-out training predictions and their property characteristics.
- `nonpositive_tract_context.csv`: training counts and size/age ranges for the tracts containing nonpositive test predictions.
- `team-review.md`: a plain-language guide to the model, class patterns, validation and limitations. It does not claim team review has already happened.

The QMD includes source links, modeling assumptions, evaluation limitations and displayed summaries of row counts, missing values and predictions. It does not use `stopifnot()` or `if (interactive()) View(...)` wrappers. Team details, actual contributions and course AI-policy confirmation still require review. No submission, git commit, push or external publication has been performed.

The code was simplified on October 29. The custom grid, zero bound and extra development/audit split are no longer used. Tract categories follow the district-factor pattern; small categories are pooled and fold coverage is checked. Earlier formulas/results are recorded separately in the QMD. The version immediately before this revision and its reports are backed up under `review/assignment5-class-workflow-2026-10-29/`. They should not be pooled with the current comparison because rows, preprocessing and/or weights differ. The experimental grid-specific size-slope model from the separate review was not added.

The subsequent prediction review applies the Week 6 numeric-by-category interaction to building area and Census tracts. Its held-out RMSE and negative-prediction count improve, but low-price proportional overvaluation remains serious. Details before that review are preserved in `review/assignment5-prediction-review-2026-10-29/`. Team metadata, publication and submission are deferred at the user's request.

The TODO follow-up adds the same numeric-by-category interaction pattern for age and distance ring. Its CV gain is about $133 (less than 0.1%), so it is described as a small refinement. The pre-follow-up QMD and results are preserved in `review/assignment5-todo-2026-10-29/`. The QMD now distinguishes completed analytical checks from remaining weaknesses and incomplete team/submission steps.
