library(methods)
library(devtools)
library(testthat)

if (interactive()) {
  load_all(".")
} else {
  library(salesperson)
}

test_dir("tests/testthat")
