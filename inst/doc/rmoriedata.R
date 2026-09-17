## ----setup, include = FALSE---------------------------------------------------
knitr::opts_chunk$set(collapse = TRUE, comment = "#>")
library(rmoriedata)

## ----catalog------------------------------------------------------------------
cat <- morie_data_catalog()
table(cat$kind)
head(cat[cat$kind == "table", c("slug", "n_rows", "n_cols")])

## ----load---------------------------------------------------------------------
iucr <- morie_data_load("chicago_iucr_codes")
head(iucr)

## ----load-bad, error = TRUE---------------------------------------------------
try({
morie_data_load("no_such_dataset")
})

## ----dict---------------------------------------------------------------------
dict_slugs <- cat$slug[cat$kind == "dictionary"]
head(dict_slugs)

## ----chicago------------------------------------------------------------------
comp <- load_chicago_data("complaints")
dim(comp)
head(sort(table(comp$primary_type), decreasing = TRUE), 5)

arr <- load_chicago_data("arrests")
sort(table(arr$charge_type), decreasing = TRUE)

## ----siu----------------------------------------------------------------------
en <- load_siu_reports(lang = "en")
nrow(en)
head(sort(table(en$police_service), decreasing = TRUE), 5)

## ----cihi---------------------------------------------------------------------
tables <- load_cihi_data_tables()
nrow(tables)
head(tables$title, 3)

## ----integrity----------------------------------------------------------------
ck <- morie_data_checksums()
head(ck[order(-ck$bytes), c("file", "bytes")], 3)

# The same compiled SHA256 kernel the whole ecosystem uses:
morie_core_sha256("abc")

## ----dp-----------------------------------------------------------------------
set.seed(1)

# A private count of records matching a predicate.
morie_dp_laplace_count(true_count = 42, epsilon = 1.0)

# The mechanism is unbiased -- averaging many releases recovers the truth.
mean(replicate(2000, morie_dp_laplace_count(42, epsilon = 1.0)))

# A private mean of bounded data.
x <- runif(1000, 0, 1)
morie_dp_gaussian_mean(x, lower = 0, upper = 1, epsilon = 1.0)

# A private histogram straight from tabulated data.
counts <- as.integer(table(comp$year))
round(pmax(0, morie_dp_laplace_histogram(counts, epsilon = 1.0)))

## ----kanon--------------------------------------------------------------------
df <- data.frame(
  age = c(25, 25, 25, 32, 32, 40),
  sex = c("F", "F", "F", "M", "M", "M")
)

# k-anonymity: every quasi-identifier combo must appear >= k times.
morie_k_anonymity_verify(df, c("age", "sex"), k = 2)$summary

# l-diversity: each class must hold >= l distinct sensitive values.
df2 <- data.frame(
  age = c(25, 25, 25, 25, 32, 32, 32),
  sex = c("F", "F", "F", "F", "M", "M", "M"),
  dx  = c("A", "B", "C", "A", "X", "Y", "Z")
)
morie_l_diversity_verify(df2, c("age", "sex"), "dx", l = 3)$summary

## ----suppress-----------------------------------------------------------------
tbl <- matrix(c(120, 3, 47, 88, 2, 99, 14, 51, 60), nrow = 3,
              dimnames = list(c("A", "B", "C"), c("X", "Y", "Z")))
res <- morie_cell_suppress(tbl, threshold = 5)
res$suppressed

