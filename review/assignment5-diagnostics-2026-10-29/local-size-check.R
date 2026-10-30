# Follow-up hypothesis: grid-specific size slopes may better represent small homes.
# Uses the same current assignment inputs and fixed development/audit split.
suppressPackageStartupMessages({library(tidyverse);library(sf);library(spdep)})
out <- "review/assignment5-diagnostics-2026-10-29"
protected <- c("assignments/assignment5.qmd","reports/assignment5/team_XX_predictions.csv")
before <- tools::md5sum(protected)
x <- readLines(protected[1])
chunk <- function(label) {
  a<-match(paste0("#| label: ",label),x); b<-which(seq_along(x)>a & x=="```")[1]
  code<-x[(a+1):(b-1)]; code[!grepl("^\\s*(View|glimpse)\\(",code)]
}
for(label in c("load","clean-training","download-sources","spatial-features","validation-split",
               "prepare-folds","candidate-formulas","validation-functions"))
  invisible(capture.output(eval(parse(text=chunk(label)))))
f_local <- update(f11,. ~ . + building_000sf:grid_fe)
rows <- tibble()
weights <- make_weights(development)
for(seed in c(5080,5081,5082)) {
  set.seed(seed); g<-sample(unique(development$property_group))
  fold_id<-rep(1:10,length.out=length(g))[match(development$property_group,g)]
  p<-pmax(0,cv_predictions(f_local,development,fold_id))
  rows<-bind_rows(rows,tibble(seed=seed,model="Grid_specific_size_slopes",
    development_cv_rmse=sqrt(mean((development$sale_price-p)^2)),
    residual_moran_i=moran_i(development$sale_price-p,weights)))
  cat("Local-size model seed",seed,"RMSE",tail(rows$development_cv_rmse,1),"\n");flush.console()
}
fit_dev<-lm(f_local,data=prepare(development,development),na.action=na.fail)
audit_pred<-pmax(0,as.numeric(predict(fit_dev,newdata=prepare(audit,development))))
fit_all<-lm(f_local,data=prepare(train,train),na.action=na.fail)
test_pred<-as.numeric(predict(fit_all,newdata=prepare(test,train)))
audit_raw<-predict(fit_dev,newdata=prepare(audit,development),rankdeficient="non-estim")
test_raw<-predict(fit_all,newdata=prepare(test,train),rankdeficient="non-estim")
quartile<-ntile(audit$sale_price,4)
summary<-tibble(model="Grid_specific_size_slopes",audit_rmse=sqrt(mean((audit$sale_price-audit_pred)^2)),
  audit_mae=mean(abs(audit$sale_price-audit_pred)),
  lowest_quartile_ratio=median(audit_pred[quartile==1]/audit$sale_price[quartile==1]),
  raw_nonpositive_test=sum(test_pred<=0),min_raw_test=min(test_pred),
  audit_nonestimable=length(attr(audit_raw,"non-estim")),
  test_nonestimable=length(attr(test_raw,"non-estim")))
write_csv(rows,file.path(out,"local_size_cv.csv"))
write_csv(summary,file.path(out,"local_size_summary.csv"))
write_csv(tibble(id=test$id,raw_pred=test_pred,pred=pmax(0,test_pred)),
          file.path(out,"EXPLORATORY_grid_specific_size_slopes.csv"))
writeLines(paste(deparse(f_local),collapse="\n"),file.path(out,"local_size_formula.txt"))
stopifnot(identical(before,tools::md5sum(protected)))
print(rows);print(summary,width=Inf)
