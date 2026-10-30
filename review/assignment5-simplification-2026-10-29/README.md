# Assignment 5 simplification, October 29

The user requested simpler code following the weekly notes, rather than the experimental model proposed during the separate review.

## Changes implemented in the QMD

- Eight explicit formula stages: house attributes, curves/timing, log size, distance, squared distance, rings, size-by-ring interaction and grid fixed effects.
- Removed cubic/polynomial coordinate-surface models and the separate tract-effect candidates from the current run. Their prior scores remain recorded as history, not comparable current results.
- Replaced the generic predictor loop and missingness flags with six explicit `mutate()`/`replace_na()` median fills. Medians still come only from the fitting rows.
- Kept the Week 7 grouped-fold `match()` pattern and prediction loop. The only added preparation is fold-local median filling; the existing zero bound is a direct vector replacement.
- Used the notes' five-neighbor `knearneigh()`/`knn2nb()`/`nb2listw()` sequence, without coordinate jitter or symmetrization.
- Removed the extra helper functions and long export reconciliation loops. Basic finite-value, row-count and test-ID checks remain.
- Kept the user's `View()` inspection calls for interactive R use; they no longer open a viewer during document rendering.
- Kept all active computation in the QMD. Prior model results are a static historical table, not an external fitted-results dependency.

## Verified results

The current winner is `Grid_effects`. Development CV RMSE is approximately $193,716, full-cleaned-training grouped CV RMSE $196,768, and the previously inspected audit RMSE $204,331. There are 18 zero-valued test predictions. All 5,789 test IDs remain unique, finite and in original order.

These figures differ from the earlier comparison because preprocessing, fold assignment and weights changed. A lower development score should not be interpreted as a controlled improvement over the older setup. The audit had already been inspected and is not a fresh independent holdout. Low-price overvaluation and zero predictions remain limitations.

The earlier source QMD and exports are preserved here as `assignment5-before.qmd`, `original-model-log.csv`, `original-predictions.csv` and `original-audit-predictions.csv`. The original author/team placeholders and required AI-use disclosure remain for team review. No commit, push or submission was performed.
