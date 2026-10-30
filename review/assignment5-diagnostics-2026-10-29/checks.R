# Approval-first diagnostics. Never sources the whole QMD or writes its outputs.
# Run from the portfolio root: Rscript review/assignment5-diagnostics-2026-10-29/checks.R
suppressPackageStartupMessages({library(tidyverse); library(sf); library(spdep)})
out <- "review/assignment5-diagnostics-2026-10-29"
dir.create(out, recursive = TRUE, showWarnings = FALSE)
protected <- c("assignments/assignment5.qmd", "reports/assignment5/team_XX_predictions.csv",
  "reports/assignment5/model_log.csv", "reports/assignment5/audit_predictions.csv",
  "reports/assignment5/cleaning_log.csv", "_quarto.yml")
before <- tools::md5sum(protected)
write_csv(tibble(file = names(before), md5_before = unname(before)), file.path(out,"protected_files.csv"))
lines <- readLines("assignments/assignment5.qmd")
chunk <- function(label) {
  a <- match(paste0("#| label: ", label), lines)
  b <- which(seq_along(lines) > a & lines == "```")[1]
  code <- lines[(a + 1):(b - 1)]
  code[!grepl("^\\s*(View|glimpse)\\(", code)]
}
stopifnot(file.exists("data/assignment5/acs_income_2023.rds"),
          file.exists("data/assignment5/cook_tracts_2023.rds"))
for (label in c("load", "clean-training", "download-sources", "spatial-features",
                "validation-split", "prepare-folds", "candidate-formulas", "validation-functions")) {
  invisible(capture.output(eval(parse(text = chunk(label)))))
}
# Historical fitted state is used only after independently verifying it against current inputs.
old <- readRDS("data/assignment5/results.rds")
stopifnot(identical(train$id, old$train$id), identical(development$id, old$development$id),
          identical(audit$id, old$audit$id), identical(folds, old$folds),
          identical(test$id, old$test$id))
for (nm in names(models)) stopifnot(identical(attr(terms(models[[nm]]), "term.labels"),
                                            attr(terms(old$models[[nm]]), "term.labels")))
f <- models$M11_grid_effects
fit_all <- lm(f, data = prepare(train, train), na.action = na.fail)
test_prepared <- prepare(test, train)
raw_pred <- as.numeric(predict(fit_all, newdata = test_prepared))
existing <- read_csv("reports/assignment5/team_XX_predictions.csv", show_col_types = FALSE)
stopifnot(identical(test$id, existing$id), max(abs(pmax(0, raw_pred) - existing$pred)) < .00001)
fitting <- prepare(development, development)
heldout <- prepare(audit, development)
fit_dev <- lm(f, data = fitting, na.action = na.fail)
audit_pred <- pmax(0, as.numeric(predict(fit_dev, newdata = heldout)))
old_audit <- read_csv("reports/assignment5/audit_predictions.csv", show_col_types = FALSE)
stopifnot(identical(audit$id, old_audit$id), max(abs(audit_pred - old_audit$pred)) < .00001)
score <- function(y, p) tibble(n = length(y), rmse = sqrt(mean((y-p)^2)),
  mae = mean(abs(y-p)), median_ratio = median(p/y), mean_error = mean(p-y))
cat("Current model, inputs, folds and exports independently reproduced.\n"); flush.console()

# 1. Why do some test predictions become zero?
test_terms <- predict(fit_all, newdata = test_prepared, type = "terms")
negative <- which(raw_pred <= 0)
nearest <- lapply(negative, function(i) {
  distances <- sqrt((train$x_mi - test$x_mi[i])^2 + (train$y_mi - test$y_mi[i])^2)
  keep <- order(distances)[1:10]
  tibble(id = test$id[i], nearest_training_miles = min(distances),
    nearest_10_median_price = median(train$sale_price[keep]),
    grid_training_sales = sum(train$grid_fe == test$grid_fe[i]),
    grid_median_price = median(train$sale_price[train$grid_fe == test$grid_fe[i]]))
}) %>% bind_rows()
zero_records <- test_prepared %>% mutate(raw_prediction = raw_pred) %>% filter(raw_prediction <= 0) %>%
  select(id, raw_prediction, building_000sf, building_age, lotsize_acre, num_bedrooms,
         num_full_baths, is_multisale, ring, grid_fe, ends_with("_missing")) %>%
  left_join(nearest, by = "id")
write_csv(zero_records, file.path(out, "zero_prediction_records.csv"))
zero_terms <- as_tibble(test_terms[negative,,drop=FALSE]) %>% mutate(id = test$id[negative]) %>%
  pivot_longer(-id, names_to = "term", values_to = "dollar_contribution") %>%
  group_by(term) %>% summarise(mean_contribution = mean(dollar_contribution), .groups = "drop") %>%
  arrange(mean_contribution)
write_csv(zero_terms, file.path(out, "zero_prediction_terms.csv"))
# type='terms' columns are centered contributions, not standalone causal effects.
stopifnot(max(abs(rowSums(test_terms) + attr(test_terms,"constant") - raw_pred)) < .001)

# 2. Held-out errors and sensitivity to expensive observations.
audit_review <- st_drop_geometry(audit) %>% mutate(pred = audit_pred, residual = sale_price-pred,
  absolute_error = abs(residual), squared_error = residual^2, ratio = pred/sale_price,
  price_quartile = ntile(sale_price,4))
price_summary <- audit_review %>% group_by(price_quartile) %>% summarise(n=n(),
  median_price=median(sale_price), rmse=sqrt(mean(squared_error)), mae=mean(absolute_error),
  median_ratio=median(ratio), sse_share=sum(squared_error)/sum(audit_review$squared_error),.groups="drop")
write_csv(price_summary,file.path(out,"audit_by_price_quartile.csv"))
top_n <- max(1, ceiling(nrow(audit_review)*.01))
concentration <- tibble(
  measure=c("Largest 1% of absolute errors", "Most expensive 1% of audit sales"),
  n=top_n,
  share_squared_error=c(sum(head(sort(audit_review$squared_error,decreasing=TRUE),top_n)),
    sum(audit_review$squared_error[order(audit_review$sale_price,decreasing=TRUE)[1:top_n]])) /
    sum(audit_review$squared_error))
write_csv(concentration,file.path(out,"error_concentration.csv"))
write_csv(audit_review %>% arrange(desc(absolute_error)) %>% slice_head(n=20),
          file.path(out,"worst_audit_errors.csv"))
influence <- tibble(id=development$id, sale_price=development$sale_price,
  cooks_distance=cooks.distance(fit_dev), leverage=hatvalues(fit_dev)) %>% arrange(desc(cooks_distance))
write_csv(head(influence,20),file.path(out,"influential_training_sales.csv"))
influence_scores <- score(heldout$sale_price,audit_pred) %>% mutate(experiment="Original fitting sample")
for (n_remove in c(1,5)) {
  reduced <- development %>% filter(!id %in% influence$id[1:n_remove])
  fit_reduced <- lm(f,data=prepare(reduced,reduced),na.action=na.fail)
  p <- pmax(0,as.numeric(predict(fit_reduced,newdata=prepare(audit,reduced))))
  influence_scores <- bind_rows(influence_scores,score(heldout$sale_price,p) %>%
    mutate(experiment=paste("Omit top",n_remove,"Cook's-distance records (sensitivity only)")))
}
write_csv(influence_scores,file.path(out,"influence_sensitivity.csv"))

# 3. Fold sensitivity: original predictions for all models, then new seeds for top contenders.
fold_scores <- imap_dfr(old$cv_results,function(result,nm) {
  tibble(fold=folds,actual=development$sale_price,pred=result$pred) %>% group_by(fold) %>%
    summarise(n=n(),rmse=sqrt(mean((actual-pred)^2)),.groups="drop") %>% mutate(model=nm)
})
write_csv(fold_scores,file.path(out,"original_fold_scores.csv"))
leave_fold_out <- map_dfr(1:10,function(k) {
  scores <- imap_dfr(old$cv_results,function(result,nm) {
    keep <- folds!=k
    tibble(model=nm,rmse=sqrt(mean((development$sale_price[keep]-result$pred[keep])^2)))
  }) %>% arrange(rmse)
  tibble(omitted_fold=k,winner=scores$model[1],rmse=scores$rmse[1])
})
write_csv(leave_fold_out,file.path(out,"leave_one_fold_out_rankings.csv"))
seeded_folds <- function(data,seed) {
  set.seed(seed); groups <- sample(unique(data$property_group))
  rep(1:10,length.out=length(groups))[match(data$property_group,groups)]
}
contenders <- c("M9_tract_size_ring","M10_tract_surface","M11_grid_effects")
repeat_scores <- tibble()
for (seed in c(5080,5081,5082)) {
  these_folds <- seeded_folds(development,seed)
  for (nm in contenders) {
    cat("Fold sensitivity:",seed,nm,"\n");flush.console()
    p <- if(seed==5080) old$cv_results[[nm]]$pred else cv_predictions(models[[nm]],development,these_folds)
    repeat_scores <- bind_rows(repeat_scores,score(development$sale_price,pmax(0,p)) %>%
      mutate(seed=seed,model=nm))
  }
}
write_csv(repeat_scores,file.path(out,"repeated_fold_comparisons.csv"))

# 4. Flagged known-price transactions were excluded from all fitting, not from this diagnostic.
flagged <- all_sales %>% filter(split=="train",is_multisale==1,is.finite(sale_price),sale_price>0)
flagged_p <- pmax(0,as.numeric(predict(fit_dev,newdata=prepare(flagged,development))))
no_shared_group <- !flagged$property_group %in% development$property_group
multisale_scores <- bind_rows(
  score(audit$sale_price,audit_pred) %>% mutate(population="Unflagged audit sales"),
  score(flagged$sale_price,flagged_p) %>% mutate(population="All flagged training-file transactions"),
  score(flagged$sale_price[no_shared_group],flagged_p[no_shared_group]) %>%
    mutate(population="Flagged transactions without a development coordinate-group match"))
write_csv(multisale_scores,file.path(out,"multisale_diagnostics.csv"))
write_csv(st_drop_geometry(flagged) %>% mutate(pred=flagged_p,
  shares_development_group=!no_shared_group),file.path(out,"flagged_predictions_diagnostic_only.csv"))

# Exploratory proposals: same outcome and fitting rules, no changes to the assignment.
# Fixed size hinges are linear-regression predictors; their thresholds do not use prices.
experiments <- list(
  Existing_grid = f,
  Linear_size_grid = update(f,. ~ . - I(building_000sf^2)),
  Piecewise_size_grid = update(f,. ~ . - I(building_000sf^2) +
    I(pmax(building_000sf-1,0)) + I(pmax(building_000sf-2,0)) + I(pmax(building_000sf-3,0)))
)
experiment_scores <- tibble(); candidate_predictions <- list()
for(nm in names(experiments)) {
  cat("Exploratory proposal:",nm,"\n");flush.console()
  form <- experiments[[nm]]
  p_cv <- if(nm=="Existing_grid") old$cv_results$M11_grid_effects$pred else cv_predictions(form,development,folds)
  fit <- lm(form,data=fitting,na.action=na.fail)
  p_audit <- pmax(0,as.numeric(predict(fit,newdata=heldout)))
  fit_full <- lm(form,data=prepare(train,train),na.action=na.fail)
  p_test <- as.numeric(predict(fit_full,newdata=test_prepared))
  experiment_scores <- bind_rows(experiment_scores,tibble(model=nm,
    development_cv_rmse=sqrt(mean((development$sale_price-pmax(0,p_cv))^2)),
    audit_rmse=sqrt(mean((audit$sale_price-p_audit)^2)),
    audit_mae=mean(abs(audit$sale_price-p_audit)),
    lowest_audit_quartile_ratio=median(p_audit[audit_review$price_quartile==1]/audit$sale_price[audit_review$price_quartile==1]),
    raw_nonpositive_test=sum(p_test<=0),min_raw_test=min(p_test)))
  candidate_predictions[[nm]] <- tibble(id=test$id,raw_pred=p_test,pred=pmax(0,p_test))
  # Separate diagnostic predictions only; not a replacement submission file.
  write_csv(candidate_predictions[[nm]],file.path(out,paste0("EXPLORATORY_",nm,".csv")))
}
write_csv(experiment_scores,file.path(out,"exploratory_candidates.csv"))
after <- tools::md5sum(protected)
stopifnot(identical(before,after))
write_csv(tibble(file=names(before),md5_before=unname(before),md5_after=unname(after),
  unchanged=unname(before)==unname(after)),file.path(out,"protected_files.csv"))
writeLines(capture.output(sessionInfo()),file.path(out,"session-info.txt"))
print(zero_records %>% select(id,raw_prediction,building_000sf,grid_fe,is_multisale,grid_training_sales))
print(price_summary); print(concentration); print(influence_scores)
print(repeat_scores); print(multisale_scores); print(experiment_scores)
cat("PASS: assignment, original exports and configuration unchanged.\n")
