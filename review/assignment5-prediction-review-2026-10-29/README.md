# Assignment 5 prediction review

The previous QMD and reports are preserved in `assignment5-before.qmd` and `reports-before/`. All active modeling and diagnostics remain inside `assignments/assignment5.qmd`.

Three follow-up candidates were tested with the same 21,968 cleaned rows, grouped ten folds and fold-local median filling: removing squared size, using log size with tract categories, and adding building-area-by-tract interactions. The interaction is an application of the Week 6 numeric-by-category pattern, not a new model family. The shortlist was specified before comparing its scores.

The resulting eleven-model comparison selects `Tract_size_slopes` (`f10`). It retains dollar sale price as the outcome. It uses no custom grid, zero bound, extra audit subset or ACS income predictor. `get_acs()` still runs directly during rendering.

## Results

| Check | Earlier tract model | Selected model |
|---|---:|---:|
| Grouped CV RMSE | $203,501.61 | $198,467.57 |
| Residual Moran's I | 0.211 | 0.186 |
| Negative held-out predictions | 77 | 17 |
| Negative test predictions | 22 | 3 |
| Median ratio for training sales up to $100,000 | 2.201 | 2.231 |
| MAE for training sales up to $100,000 | $110,531 | $103,757 |

The selected model improves RMSE in nine of the same ten folds. These are checks within the selection CV, not independent test results. Low-price median proportional overvaluation and the share overpredicted worsen even though dollar MAE improves. No fairness improvement is claimed.

Remaining negative test IDs are 778, 1858 and 20687. Their tracts contain 20 and 21 cleaned training sales. Record 1858 extends beyond its tract's observed training-size range. Other combinations of predictors and unobserved house characteristics remain possible causes; source errors are not established. All test outputs remain raw and all IDs are retained.

## Verification

- Final `quarto render assignments/assignment5.qmd` succeeded with a live Census download.
- Independent arithmetic reproduced the selected CV RMSE from the exported out-of-fold residuals.
- Verified 21,968 out-of-fold rows, one fold per rounded-coordinate group, and all 5,789 test IDs in their original order with finite predictions.
- The repository's HTML checker passed: 18 pages, zero local link/image issues. Seven missing figure descriptions were repaired in QMD chunk options.
- Final LISA figure was visually inspected; the baseline and selected models use the same geometry and weights.
- `git diff --check` passed. No model rank-deficiency notice appeared in the rendered summary.

The plain-language guide is `reports/assignment5/team-review.md`. It explains class patterns, the formula, coefficient interpretation, validation and remaining weaknesses. Team metadata, AI-policy completion, publication and submission are deferred at the user's request. No commit, push or submission was made.
