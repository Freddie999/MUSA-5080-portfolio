# Assignment 5 TODO follow-up

The statistical TODOs were reviewed using the existing class methods and shared grouped CV folds. The QMD before this follow-up and the previous scores, predictions, out-of-fold results and folds are preserved here.

One follow-up was specified after inspecting the remaining held-out failures: allow the age slope to vary across distance rings. This uses the class's numeric-by-category interaction syntax. It does not transform the outcome, change cleaning rules, introduce a grid, restore the audit split or clip predictions.

`Age_by_ring` (`f11`) is now the lowest-CV-RMSE specification among twelve logged models. CV RMSE is $198,334.53, versus $198,467.57 for the preceding local-size model. Its gain is about $133, less than 0.1%, and it improves only five of ten folds relative to that model. It improves nine of ten relative to the earlier tract-intercept model. No substantial improvement is claimed.

Negative out-of-fold predictions decrease from 17 to 16. The same three test IDs remain negative: 778 (-$3,059), 1858 (-$67,977), and 20687 (-$124,198). Their training-tract context was rechecked. These are documented model failures, not corrected values or evidence of invalid source records.

For the 2,513 training sales up to $100,000, median valuation ratio is 2.229 and MAE is about $103,268. Proportional overvaluation remains substantial. The assignment asks for error analysis; completing the review does not imply that these weaknesses have disappeared.

Verification:

- Full Quarto render succeeded using the live `get_acs()` call.
- Verified twelve model-log rows, 21,968 out-of-fold rows, one fold per rounded-coordinate group, and all 5,789 test IDs in original order with finite outputs.
- Independent arithmetic reproduces the winning CV RMSE from exported residuals.
- Active QMD has no `View()`, `stopifnot()`, `interactive()` wrappers, fitted-result cache calls or custom-grid code.
- `git diff --check` passed.
- The site checker found no Assignment 5 issues. Its full-site scan reports one unrelated missing image description in the newly present Week 8 page; that page was not changed in this task.

The QMD submission checklist now marks the analytical work as complete and leaves team review, real team metadata, the agreed AI policy, filename, publication and submission open. No details were invented, and nothing was committed, pushed or submitted.
