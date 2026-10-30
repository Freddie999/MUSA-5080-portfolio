# Separate Assignment 5 diagnostics

Assessment: the requested checks are complete. The current model has material limitations; a new candidate is promising but has a fairness trade-off. No change has been made to the assignment, its existing prediction CSV, its model log, or website configuration. Checksums are recorded in `protected_files.csv`.

## The candidate worth considering

Allow the building-size slope to differ by 2-mile grid cell, rather than only by distance ring. The additional predictor is `building_000sf:grid_fe`; all other predictors, the dollar outcome, cleaning rules and imputation approach are unchanged. This is an exploratory extension of the course's interaction approach, not a new model family.

| Measure | Current grid model | Grid-specific size slopes |
|---|---:|---:|
| Development grouped CV RMSE, original folds | $195,489 | $182,718 |
| Audit RMSE, 4,401 sales | $204,104 | $186,489 |
| Audit MAE | $118,681 | $111,046 |
| Test predictions at zero after bounding | 19 | 2 |
| Lowest-price audit quartile median predicted/observed ratio | 1.550 | about 1.61 |

The candidate improves dollar prediction metrics and eliminates 17 of the 19 nonpositive outputs, but increases proportional overvaluation in the lowest-price quartile. The remaining nonpositive test IDs are 2109 and 9767. No observed test prices are available, so it is not possible to establish which test predictions are closer to the instructor's answers.

Across seeds 5080, 5081 and 5082, the new candidate's development CV RMSE is $182,718–$182,782. The current model is $194,280–$195,489 on those same fold assignments. These seeds reuse the same development population and a fixed audit sample; they are not three independent datasets. See `local_size_cv.csv` for residual Moran's I and exact values.

The audit has already been inspected during earlier work and these exploratory checks. Its improvement is supportive evidence, not a pristine final test. A final decision must not be made by repeatedly optimizing this audit score alone. The new candidate's full-cleaned-training CV score has not been computed, and it has not been adopted or submitted.

## 1. Zero-valued predictions

All 19 current zeros reproduce from the current QMD's formula and raw inputs. They are caused by negative raw linear predictions ranging from approximately -$277 to -$64,258, subsequently bounded at zero. These are predominantly small, older houses: approximately 642–1,080 square feet and ages 50–135. Seventeen are unflagged transactions; two are flagged multisales.

Their grid cells contain 187–627 cleaned training sales. Thirteen of the 19 lie in one grid cell containing 406 training sales. The ten-nearest-training-sale median prices are positive, although proximity does not make houses directly comparable. This weakens a simple explanation that the model has no local training data.

Centered term contributions show that geographic intercepts and the global size/age relationships combine to push these fitted values negative. These contributions explain the calculation, not causal effects. `zero_prediction_records.csv` contains every affected row and local context; `zero_prediction_terms.csv` contains the centered term summary. A reconciliation check confirms that the term contributions plus the model constant reproduce the raw predictions.

Two simpler alternatives were also tested. Removing squared size worsened development CV RMSE to $201,991 and produced 58 nonpositive test outputs. Fixed size hinges at 1,000, 2,000 and 3,000 square feet produced CV RMSE $196,414 and 14 nonpositive outputs. Their better audit RMSEs do not make them clear winners; the full results are retained in `exploratory_candidates.csv`.

## 2. Worst held-out errors and influential sales

On the fixed audit sample, the 45 largest absolute errors (about 1%) account for 46.8% of squared error. The most expensive 45 audit sales account for 35.9%. The highest-price quartile accounts for about 77.1% of squared error, while the lowest-price quartile has median valuation ratio 1.550. Dollar RMSE and proportional error therefore emphasize different failures.

The $14.25 million training sale, ID 19188, has the highest development-fit Cook's distance (about 1.40). Omitting it in a scratch sensitivity fit lowers audit RMSE from $204,104 to $198,850. Omitting the top five Cook's-distance records gives $199,695. This establishes sensitivity, not invalidity. Do not remove these observations just because their removal improves an already-inspected audit score. Full results are in `influential_training_sales.csv`, `influence_sensitivity.csv`, `error_concentration.csv` and `worst_audit_errors.csv`.

Grouping by observed price can expose regression-to-the-mean patterns. The low-price ratios are descriptive diagnostics and do not, by themselves, prove discrimination, owner-level unfairness or actual tax burdens.

## 3. Fold sensitivity

For the current model, original fold RMSE ranges from $162,920 to $221,849. It remains the winner among all 24 original recipes whenever any one fold's existing errors are omitted from the pooled score. This is a reranking of stored predictions, not ten new training runs.

For the top three original contenders, two additional grouped fold assignments were refitted using the same 17,567 development sales. The current grid model beats the tract alternatives under all three seeds. Its original win is therefore not explained by a single favorable fold, within these checks. This does not test spatial-block transfer, forecasting a later year, or every possible split. See `original_fold_scores.csv`, `leave_one_fold_out_rankings.csv` and `repeated_fold_comparisons.csv`.

## 4. Multisale population mismatch

The existing development fit was evaluated on the 1,232 known-price flagged transactions excluded from fitting. RMSE is $832,827, median predicted/recorded-price ratio 0.877, compared with $204,104 RMSE on unflagged audit sales. Restricting to 1,205 flagged transactions with no development coordinate-group overlap gives RMSE $839,959 and median ratio 0.878.

These populations and targets differ: a bundled recorded price may cover several parcels, whereas the model is trained on individually priced records. The comparison cannot establish each parcel's true value or directly estimate the hidden-test error. It does reveal a material scope limitation, since the hidden test includes 280 flagged transactions. A useful question for the instructor is whether and how bundled prices are allocated when scoring. No arbitrary parcel-count multiplier was applied. See `multisale_diagnostics.csv`.

## Additional issue: a rare missingness indicator

The development fit has one aliased coefficient, `lotsize_acre_missing`, because there are no missing lot sizes in development. One audit record (24523) does have missing lot size, and R flags its prediction as non-estimable under that indicator specification. The median-filled lot size itself is available, but the missingness effect cannot be learned from fitting rows where it never occurs.

The full cleaned-training fit is full rank, and none of its 5,789 test predictions are flagged as non-estimable. This issue therefore does not explain the 19 zero test predictions. The proposed safeguard is to explicitly handle predictors with no fitting-sample variation and report non-estimable cases, rather than hiding prediction warnings. It should be fitted within each fold and verified before being added. See `rank_deficiency.csv` and `audit_nonestimable_cases.csv`.

## Proposed additions, pending approval

1. Add the grid-specific size-slope candidate to the model log, alongside the other exploratory trials, with its zero-count and proportional-error trade-off. Do not silently replace the final model.
2. Add a short influence/split-sensitivity discussion and multisale limitation to the assignment.
3. Add a fold-local constant-predictor/non-estimability safeguard, then rerun all comparisons consistently.

## Evidence and coverage

This is a targeted model diagnostic, not a full grading, source-authority or rendered-website audit. No external data was fetched. Current QMD chunks were read and selected preprocessing/function chunks evaluated in a separate process, with interactive `View()`/`glimpse()` calls skipped. The whole QMD was not sourced or rendered, preventing its export code from running. A historical RDS was reused only after raw CSV hashes, current formula terms, row identities, split assignments and independently refitted predictions were reconciled with the current exports.

All four requested diagnostic questions were covered. Additional coverage includes one rank-deficiency investigation and three exploratory formula changes. Hidden test accuracy, verified parcel identity and the instructor's treatment of multisales remain unavailable. No genuine future-year or spatial-block holdout was performed. All metrics use the stated populations; no unsupported probability that the candidate will win on the hidden test is assigned.

Reproduce from the portfolio root:

```sh
Rscript review/assignment5-diagnostics-2026-10-29/checks.R
Rscript review/assignment5-diagnostics-2026-10-29/rank-check.R
Rscript review/assignment5-diagnostics-2026-10-29/local-size-check.R
```

All generated files stay in this review folder. Files named `EXPLORATORY_*.csv` are diagnostic outputs, not replacement submission files. The original assignment, original predictions, model log, audit export, cleaning log and project configuration are protected by checksum checks.
