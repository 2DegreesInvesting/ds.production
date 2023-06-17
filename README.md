
<!-- README.md is generated from README.Rmd. Please edit that file -->

# From MVP to production

If you wanted to build a skyscraper, you’ll intuitively know that you
can’t do it yourself. You’ll need help to know what to do, how to do it,
and how long it will take. Even if you wanted, civil-engineering
regulations would stop you. But software engineering is relatively new,
few people intuitively know how complex it can be, and no regulation
would stop you for trying yourself.

The goal of this article is to help a data science team to better
understand how software evolves from a Minimum Viable Product (MVP) to
production – from a script that “works for me” to an R package that
works for anyone anywhere.

> Refactoring is a disciplined technique for restructuring an existing
> body of code, altering its internal structure without changing its
> external behavior.

> Its heart is a series of small behavior preserving transformations.
> Each transformation (called a “refactoring”) does little, but a
> sequence of these transformations can produce a significant
> restructuring. Since each refactoring is small, it’s less likely to go
> wrong. The system is kept fully working after each refactoring,
> reducing the chances that a system can get seriously broken during the
> restructuring.

– <https://refactoring.com/>

The book [R packages (2e)](https://r-pkgs.org) shows how to refactor R
code to extract the hidden [package
within](https://r-pkgs.org/package-within.html) an analysis script.

Based on that example, this article expands the focus beyond the focal
code. It includes the infrastructure and tests that support the process
before, during, and after refactoring the focal code.

Contents:

1.  Reproduce: Making the focal code reproducible from a single
    executable script.

2.  Snapshot: Capturing key outputs to characterize current behaviour.

3.  Refactor: Restructuring the code and testing the external behaviour
    doesn’t change.

4.  Improve: Changing the external behaviour of the code, e.g. to fix
    bugs.

## 1. Reproduce

*Making the focal code reproducible from a single executable script*

Ensure the original code is reproducible.

../../Downloads/mvp/README.md

<!-- README.md is generated from README.Rmd. Please edit that file -->

``` r
# Packages ----

library(dplyr, warn.conflicts = FALSE)
library(readr, warn.conflicts = FALSE)
library(here)
#> here() starts at /home/rstudio/Downloads/mvp

# Data ----

input_name <- "swim.csv"
input_path <- here("input", input_name)
input_path
#> [1] "/home/rstudio/Downloads/mvp/input/swim.csv"

raw <- read_csv(input_path, show_col_types = FALSE)
raw
#> # A tibble: 5 × 3
#>   name  where     temp
#>   <chr> <chr>    <dbl>
#> 1 Adam  beach       95
#> 2 Bess  coast       91
#> 3 Cora  seashore    28
#> 4 Dale  beach       85
#> 5 Evan  seaside     31

# Clean ----

# Localize beach
lookup_table <- tribble(
      ~where, ~english,
     "beach",     "US",
     "coast",     "US",
  "seashore",     "UK",
   "seaside",     "UK"
)
localized <- raw |> 
  left_join(lookup_table)
#> Joining with `by = join_by(where)`

# Celsify temp
f_to_c <- function(x) (x - 32) * 5/9
clean <- localized |> 
  mutate(temp = if_else(english == "US", f_to_c(temp) * 5/9, temp))

clean
#> # A tibble: 5 × 4
#>   name  where     temp english
#>   <chr> <chr>    <dbl> <chr>  
#> 1 Adam  beach     19.4 US     
#> 2 Bess  coast     18.2 US     
#> 3 Cora  seashore  28   UK     
#> 4 Dale  beach     16.4 US     
#> 5 Evan  seaside   31   UK

# Save ----

output_path <- here("output", paste0("clean_", input_name))
output_path
#> [1] "/home/rstudio/Downloads/mvp/output/clean_swim.csv"

write_csv(clean, output_path)
```

Note the data is inside the project:

- It might be too large to use version control with Git.
- It might be private, while everything else might be public.

<!-- -->

    ~/Downloads/mvp/
    ├── README.Rmd
    ├── README.md
    ├── input
    │   └── swim.csv
    ├── mvp.Rproj
    └── output
        └── clean_swim.csv

Build infrastructure to support automated workflows (see [R packages
(2e)](https://r-pkgs.org/)), e.g.:

- `usethis::create_package()`
- `devtools::check()` (then address errors, warnings, and notes).
- `usethis::use_directory("inst/extdata")`

Copy the code, excluding data.

- You can now use Git to track code versions, regardless the size of the
  data.
- You can share public code regardless the privacy of the data.

<!-- -->

    error: Your local changes to the following files would be overwritten by checkout:
        README.Rmd
    Please commit your changes or stash them before you switch branches.
    Aborting
    .
    ├── DESCRIPTION
    ├── LICENSE
    ├── LICENSE.md
    ├── NAMESPACE
    ├── NEWS.md
    ├── R
    │   ├── celsify_temp.R
    │   ├── localize_beach.R
    │   ├── production-package.R
    │   ├── utils-tidy-eval.R
    │   └── utils.R
    ├── README.Rmd
    ├── README.md
    ├── _pkgdown.yml
    ├── man
    │   ├── celsify_temp.Rd
    │   ├── localize_beach.Rd
    │   ├── production-package.Rd
    │   └── tidyeval.Rd
    ├── production.Rproj
    ├── tests
    │   ├── testthat
    │   │   ├── test-celsify_temp.R
    │   │   └── test-localize_beach.R
    │   └── testthat.R
    └── vignettes
        └── articles
            └── cleaning-swimming-data.Rmd

- HACK: Redirect paths to the data with minimal changes.

<!-- -->

    # Packages ----

    library(dplyr, warn.conflicts = FALSE)
    library(readr, warn.conflicts = FALSE)
    here <- function(...) fs::path_home("Downloads", "mvp", ...)

    # Data ----

    input_name <- "swim.csv"
    input_path <- here("input", input_name)

## 2. Snapshot

*Capturing key outputs to characterize current behaviour*

- `usethis::use_test("capture-outputs")`

<!-- -->

    test_that("`localized` hasn't changed", {
      e <- rmd_environment()
      expect_snapshot(e$localized)
    })

    test_that("`clean` hasn't changed", {
      e <- rmd_environment()
      expect_snapshot(e$clean)
    })

    rmd_environment <- function(path = system.file("extdata", "mvp.Rmd", package = "production")) {
      e <- new.env()
      rmarkdown::render(path, envir = e, quiet = TRUE)
      e
    }

Snapshots

    # `localized` hasn't changed

        Code
          e$localized
        Output
          # A tibble: 5 x 4
            name  where     temp english
            <chr> <chr>    <dbl> <chr>  
          1 Adam  beach       95 US     
          2 Bess  coast       91 US     
          3 Cora  seashore    28 UK     
          4 Dale  beach       85 US     
          5 Evan  seaside     31 UK     

    # `clean` hasn't changed

        Code
          e$clean
        Output
          # A tibble: 5 x 4
            name  where     temp english
            <chr> <chr>    <dbl> <chr>  
          1 Adam  beach     19.4 US     
          2 Bess  coast     18.2 US     
          3 Cora  seashore  28   UK     
          4 Dale  beach     16.4 US     
          5 Evan  seaside   31   UK     

New files

    error: Your local changes to the following files would be overwritten by checkout:
        README.Rmd
    Please commit your changes or stash them before you switch branches.
    Aborting
    tests
    ├── testthat
    │   ├── test-celsify_temp.R
    │   └── test-localize_beach.R
    └── testthat.R

WARNING: Don’t share snapshots of private data! You may use a dedicated
tests/testthat/private/ directory, add it to .gitignore and test it with
`test_dir(test_path("private"))`.

## 3. Refactor

*Restructuring the code and testing the external behaviour doesn’t
change*

inst/extdata/mvp.Rmd

    library(readr, warn.conflicts = FALSE)
    library(production)

    mvp_path <- function(...) fs::path_home("Downloads", "mvp", ...)

    input_name <- "swim.csv"
    input_path <- mvp_path("input", input_name)
    raw <- read_csv(input_path, show_col_types = FALSE)

    localized <- localize_beach(raw)
    clean <- celsify_temp(localized)

    output_path <- mvp_path("output", paste0("clean_", input_name))
    write_csv(clean, output_path)

R/

    #' Convert the `temp` column from Farenheit to Celsius
    #'
    #' @param data A data frame.
    #'
    #' @return A data frame.
    #' @export
    #'
    #' @examples
    #' library(tibble)
    #'
    #' data <- tibble(temp = c(32, 0), english = c("US", "UK"))
    #' celsify_temp(data)
    celsify_temp <- function(data) {
      stopifnot(hasName(data, "temp"))
      stopifnot(hasName(data, "english"))

      mutate(
        data,
        temp = if_else(.data$english == "US", f_to_c(.data$temp) * 5 / 9, .data$temp)
      )
    }

    f_to_c <- function(x) (x - 32) * 5 / 9

`?celsify_temp()`

<img src=https://github.com/2DegreesInvesting/ds.production/assets/5856545/20069a3e-3fb9-4d72-af8a-fd5ca48bada1 width=900>

tests/

    test_that("leaves Celsius as is", {
      out <- celsify_temp(tibble(temp = 32, english = "UK"))
      expect_equal(out$temp, 32)
    })

    test_that("without crucial columns errors gracefully", {
      expect_error(celsify_temp(tibble(bad = 32, english = "UK")), "temp.*not TRUE")
      expect_error(celsify_temp(tibble(temp = 32, bad = "UK")), "english.*not TRUE")
    })

    test_that("91 Farenheit is converted to about 32.8 Celsius", {
      skip("FIXME: f_to_c() already multiplies by 5/9, so we do it twice!")
      out <- celsify_temp(tibble(temp = 91, english = "US"))
      expect_equal(round(out$temp, 3), 32.778)
    })

## 4. Improve

*Changing the external behaviour of the code, e.g. to fix bugs*

- Discuss the current behaviour.
- Fix bugs.
- Remove duplication.
- Implement new behaviour.

<!-- -->

    celsify_temp <- function(data) {
      stopifnot(hasName(data, "temp"))
      stopifnot(hasName(data, "english"))

      mutate(
        data,
        temp = if_else(.data$english == "US", f_to_c(.data$temp), .data$temp)
      )
    }

    f_to_c <- function(x) (x - 32) * 5 / 9

tests/

    test_that("91 Farenheit is converted to about 32.8 Celsius", {
      out <- celsify_temp(tibble(temp = 91, english = "US"))
      expect_equal(round(out$temp, 3), 32.778)
    })

## Enjoy

Packages

``` r
library(production)
```

Data

``` r
# styler: off
raw <- tibble::tribble(
   ~name,     ~where, ~temp,
  "Adam",    "beach",    95,
  "Bess",    "coast",    91,
  "Cora", "seashore",    28,
  "Dale",    "beach",    85,
  "Evan",  "seaside",    31
)
# styler: on
```

Clean

``` r
raw |> 
  localize_beach() |> 
  celsify_temp()
#> # A tibble: 5 × 4
#>   name  where     temp english
#>   <chr> <chr>    <dbl> <chr>  
#> 1 Adam  beach     35   US     
#> 2 Bess  coast     32.8 US     
#> 3 Cora  seashore  28   UK     
#> 4 Dale  beach     29.4 US     
#> 5 Evan  seaside   31   UK
```
