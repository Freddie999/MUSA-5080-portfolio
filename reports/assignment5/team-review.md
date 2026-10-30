# Assignment 5: review together

This guide explains the current analysis. It does not record that anyone has already reviewed it. Team details, the agreed AI policy and submission will be completed later.

## What problem are we solving?

We predict Chicago single-family sale prices in dollars. The Assessor needs estimates for houses that did not sell too. Good overall prediction matters, but systematic overvaluation of inexpensive homes is also a concern.

## What happened to the data?

We began with 23,200 priced training records. We excluded 1,232 flagged multi-parcel sales because a bundled price may cover more than one parcel. That leaves 21,968 training rows. We did not delete low prices, expensive houses or any of the 5,789 test rows. Missing predictors are filled with fitting-sample medians. We never fill the missing test outcomes.

## What is the selected model?

`Age_by_ring` (`f11`) is an ordinary `lm()` model. It combines house characteristics, squared size and age, log lot area, year and quarter, distance rings, tract categories, and interactions that let size associations differ across places and the age slope differ across rings. The outcome is still `sale_price`, not `log(sale_price)`.

The size-by-tract interaction is an application of the numeric-predictor-by-category pattern in the class notes. The professor's example uses a different predictor and category; we are applying the same syntax, not claiming that this exact Chicago formula was supplied in class. Tract-specific slopes add many coefficients and can be unstable for small groups.

The relevant patterns are the log/square, factor, interaction and fixed-effect examples in `weekly-notes/week-06.qmd`, the grouped-CV and residual-weight examples in `weekly-notes/week-07.qmd`, and the median-filling and LISA examples in the Week 8 slides. No new model family has been introduced.

## How did we choose it?

We compared twelve formulas using the same grouped ten-fold CV. Each held-out house was predicted without fitting to its sale price. Medians were calculated inside the fitting fold. Rounded coordinates group likely repeated properties together, but they are not verified parcel IDs.

The selected model's CV RMSE is about **$198,335**. The preceding local-size model scored about **$198,468**, the earlier tract-intercept model about **$203,502**, and the structure-only baseline about **$282,173**. The final $133 gain is less than 0.1%, so it is a small refinement. RMSE summarizes squared prediction errors; it does not mean every prediction is within that many dollars.

We chose the model using these CV scores, so the winning score can be optimistic. The hidden instructor test is still separate and unknown. More features or a better training fit alone would not justify choosing a model.

The selected model had lower RMSE in 9 of the same 10 folds compared with the earlier tract-intercept model. Compared with the immediately preceding local-size model, it improved only 5 of 10 folds. These comparisons are within the existing CV run, not independent tests. We do not describe the age interaction as a substantial or consistently better result.

## Why are some predictions negative?

Ordinary linear regression adds an intercept and predictor contributions without restricting the result to be positive. Logging a predictor does not change that. Logging the outcome would allow positive back-transformed predictions, but this assignment says to keep the outcome in dollars.

The selected model reduced negative held-out predictions from **77 to 16** and negative test predictions from **22 to 3**. The preceding local-size model had 17 negative held-out predictions. We did not replace negative predictions with zero. See `predictions_needing_review.csv` for the three remaining test failures and `negative_oof_predictions.csv` for the held-out training failures. These records have been reviewed and remain in the export. A reduction is useful; it is not a guarantee of valid values for every house.

The three remaining test records are 778, 1858 and 20687. Their two tracts have only 20 and 21 cleaned training sales. Record 1858 has 1,704 reported square feet, just above its tract's largest training house at 1,605 square feet, so its local size slope is being extended beyond that observed range. The other two houses fall within their tract's individual size and age ranges; that alone does not guarantee that their full combination of characteristics is well represented. These observations justify caution, not deleting the records or declaring them source-data errors.

## Did fairness improve?

There is a tradeoff. For the same 2,513 training sales up to $100,000, the selected model reduces mean absolute dollar error, but its median predicted-to-sale-price ratio is about **2.23**, versus **2.20** for the earlier tract model. Its share of overpredicted low-price houses also increases. We retained it for the assignment's dollar-RMSE objective, not because it solved overvaluation.

A ratio of 1 means the prediction equals the sale price; 2 means double the price. The age-by-ring follow-up changes the median ratio from 2.231 to 2.229 and MAE from about $103,757 to $103,268 compared with the preceding local-size model. This does not resolve the overvaluation concern. Grouping by actual price can produce regression-to-the-mean patterns, so this descriptive result alone does not prove discrimination. Tract income is neighborhood context, not an owner's income, and predicted values are not actual tax bills.

## How do we read a coefficient?

For `central_air`, read its estimate in `summary(m_final)`. Holding the other model inputs fixed, changing that indicator from 0 to 1 changes the predicted dollar price by that coefficient. It is an association, not the causal return from installing air conditioning.

`building_000sf` is interpreted as thousands of square feet. Its main coefficient alone is not the full size relationship: squared size and the ring/tract interactions also contribute. We must identify the place category and size when interpreting that relationship.

## What do the maps tell us?

The residual is actual minus predicted price. Positive means underprediction; negative means overprediction. The maps use out-of-fold residuals. Global Moran's I summarizes spatial dependence. Week 8's LISA map locates exploratory clusters and outliers relative to the mean residual. A cluster can suggest a missing neighborhood feature, but does not identify a cause. Lower RMSE does not guarantee that local patterns disappear.

## What should each teammate be able to explain?

1. Why do we exclude bundled training transactions but retain all test rows?
2. Why are medians calculated from the fitting fold only?
3. What changes when we add `building_000sf:tract_fe`?
4. Why can this model still predict a negative price?
5. Why can RMSE improve while low-price overvaluation remains serious?
6. Why is the selected CV score not the instructor's test score?
7. Why would we require further checks before using this model for assessments?

The QMD contains all executable analysis and the complete model log. No custom grid, zero-bound rule, extra audit split or locally cached ACS-result loading is used in the active analysis.
