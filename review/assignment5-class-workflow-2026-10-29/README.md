# Assignment 5: class-workflow revision

The previous QMD is preserved as `assignment5-before.qmd`, with its output files in `reports-before/`. These are historical results, not the current submission files.

The active QMD now uses Census-tract categories instead of an invented two-mile grid, all 21,968 cleaned training rows in shared grouped ten-fold CV, and raw linear-model outputs without clipping. No extra development/audit split remains. Median filling stays inside each fitting fold. ACS income is used for retrospective diagnostics only. Week 8's permutation LISA helper, maps and counts are included. Price diagnostics use Week 7's fixed price bands instead of `ntile()`.

Verified on October 29, 2026:

- `quarto render assignments/assignment5.qmd` completed successfully with a live `get_acs()` download.
- Tract-effects CV RMSE: $203,501.61; structure-only CV RMSE: $282,173.32.
- Residual Moran's I: 0.211 for the selected model, versus 0.376 for the baseline.
- LISA High–High houses: 420 to 227; Low–Low: 413 to 258. These are exploratory classifications, not counts of independent clusters.
- All 5,789 original test IDs remain in their original order with finite predictions.
- All 21,968 cleaned training rows have out-of-fold predictions; independent calculation reproduces the winning CV RMSE.
- Each rounded-coordinate property group appears in exactly one fold.
- There are 22 negative test predictions and 77 negative out-of-fold predictions. These are visible failures of the linear model. No prediction has been silently replaced with zero.
- The price band up to $100,000 has a median out-of-fold valuation ratio of 2.201, a substantial remaining weakness.
- Generated residual and LISA maps were visually inspected.

The winning CV score is also used for model selection; it is not an independent test score. Removing the grid changes the model and evaluation setup, so comparisons with old development-only scores are not controlled comparisons. The hidden instructor score remains unavailable.

All active analysis stays in `assignments/assignment5.qmd`. Team metadata and AI-policy confirmation still need the team's review. Nonpositive predictions need attention before submission. Nothing was submitted, committed or pushed.
