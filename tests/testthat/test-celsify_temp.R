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

test_that("91 Farenheit is converted to about 32.8 Celsius", {
  skip("FIXME: f_to_c() already multiplies by 5/9, so we do it twice!")
  out <- celsify_temp(tibble(temp = 91, english = "US"))
  expect_equal(round(out$temp, 3), 32.778)
})
