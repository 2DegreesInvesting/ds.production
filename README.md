
<!-- README.md is generated from README.Rmd. Please edit that file -->

# production

<!-- badges: start -->
<!-- badges: end -->

The goal of production is to help you support the refactoring of an MVP
to clean swim data.

## Installation

You can install the development version of production like so:

``` r
# install.packages("devtools")
devtools::install_github("<some where on GitHub>/production")
```

## Example

``` r
library(production)

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
