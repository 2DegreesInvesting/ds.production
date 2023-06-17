
<!-- README.md is generated from README.Rmd. Please edit that file -->

# production

The goal of production is to show how to refactor the package within
your analysis code.

Adapted from <https://r-pkgs.org/package-within.html>.

## 1. Reproduce

Make the process reproducible from an executable script.

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

Build infrastructure to support refactoring ([R packages
(2e)](https://r-pkgs.org/)).

Copy the code, excluding data.

- You can now use Git to track code versions, regardless the size of the
  data.
- You can share public code regardless the privacy of the data.

<!-- -->

    Switched to branch '1-reproduce'
    .
    ├── DESCRIPTION
    ├── LICENSE
    ├── LICENSE.md
    ├── NAMESPACE
    ├── README.Rmd
    ├── inst
    │   └── extdata
    │       ├── mvp.Rmd
    │       └── mvp.md
    └── production.Rproj
    Switched to branch 'main'
    Your branch is up to date with 'origin/main'.

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

Capture key outputs to characterize the current behaviour.

    test_that("`localized` hasn't changed", {
      e <- rmd_environment()
      expect_snapshot(e$localized)
    })

    test_that("`clean` hasn't changed", {
      e <- rmd_environment()
      expect_snapshot(e$clean)
    })

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

    Switched to branch '2-snapshot'
    tests
    ├── testthat
    │   ├── _snaps
    │   │   └── capture-outputs.md
    │   └── test-capture-outputs.R
    └── testthat.R
    Switched to branch 'main'
    Your branch is up to date with 'origin/main'.

WARNING: Don’t share snapshots of private data! You may use a dedicated
tests/testthat/private/ directory, add it to .gitignore and test it with
`test_dir(test_path("private"))`.

### 3. Refactor

> Refactoring is a disciplined technique for restructuring an existing
> body of code, altering its internal structure without changing its
> external behavior – <https://refactoring.com/>

Extract smaller units of meaningful behavior (functions) and test them.

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

### 4. Improve

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

### Enjoy

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
