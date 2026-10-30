# Additional diagnostic for warnings observed during the separate review.
suppressPackageStartupMessages({library(tidyverse);library(sf)})
out <- "review/assignment5-diagnostics-2026-10-29"
z <- readRDS("data/assignment5/results.rds")
development <- z$development
x <- readLines("assignments/assignment5.qmd")
a <- match("#| label: prepare-folds",x)
b <- which(seq_along(x)>a & x=="```")[1]
invisible(capture.output(eval(parse(text=x[(a+1):(b-1)]))))
dev <- prepare(z$development,z$development)
hold <- prepare(z$audit,z$development)
test <- prepare(z$test,z$train)
m <- lm(z$f_final,data=dev,na.action=na.fail)
audit_p <- predict(m,newdata=hold,rankdeficient="non-estim")
test_p <- predict(z$m_final,newdata=test,rankdeficient="non-estim")
audit_bad <- attr(audit_p,"non-estim"); test_bad <- attr(test_p,"non-estim")
summary <- tibble(fit=c("Development fit / audit predictions","Final fit / test predictions"),
  columns=c(ncol(model.matrix(m)),ncol(model.matrix(z$m_final))),
  rank=c(m$rank,z$m_final$rank),
  nonestimable_predictions=c(length(audit_bad),length(test_bad)),
  aliased_terms=c(paste(names(coef(m))[is.na(coef(m))],collapse="; "),
                  paste(names(coef(z$m_final))[is.na(coef(z$m_final))],collapse="; ")))
write_csv(summary,file.path(out,"rank_deficiency.csv"))
write_csv(hold[audit_bad,] %>% mutate(pred=as.numeric(audit_p[audit_bad])),
          file.path(out,"audit_nonestimable_cases.csv"))
if(length(test_bad)) write_csv(test[test_bad,],file.path(out,"test_nonestimable_cases.csv"))
print(summary,width=Inf)
if(length(audit_bad)) print(hold[audit_bad,] %>% select(id,ends_with("_missing")),width=Inf)
