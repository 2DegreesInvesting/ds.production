test_that("knows if a place is in US or UK", {
  out <- localize_beach(tibble(where = "beach"))
  expect_equal(out$english, "US")

  out <- localize_beach(tibble(where = "seashore"))
  expect_equal(out$english, "UK")
})

test_that("knows if a place is in US or UK", {
  expect_no_condition(localize_beach(tibble(where = "beach")))
})

test_that("if the column `where` is missing errors gracefully", {
  localize_beach(tibble(bad = "bad"))
})
