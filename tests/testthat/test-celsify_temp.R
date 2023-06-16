test_that("converts Frarenheit to Celsius", {
  out <- celsify_temp(tibble(temp = 32, english = "US"))
  expect_equal(out$temp, 0)
})

test_that("leaves Celsius as is", {
  out <- celsify_temp(tibble(temp = 32, english = "UK"))
  expect_equal(out$temp, 32)
})

test_that("without crucial columns errors gracefully", {
  expect_error(celsify_temp(tibble(bad = 32, english = "UK")), "temp.*not TRUE")
  expect_error(celsify_temp(tibble(temp = 32, bad = "UK")), "english.*not TRUE")
})

test_that("snapshot", {
  data <- tibble::tribble(
    ~name,     ~where, ~temp, ~english,
    "Adam",    "beach",    95,     "US",
    "Bess",    "coast",    91,     "US",
    "Cora", "seashore",    28,     "UK",
    "Dale",    "beach",    85,     "US",
    "Evan",  "seaside",    31,     "UK"
  )
  expect_snapshot(celsify_temp(data))
})
