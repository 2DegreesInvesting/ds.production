test_that("`localized` hasn't changed", {
  e <- rmd_environment()
  expect_snapshot(e$localized)
})

test_that("`clean` hasn't changed", {
  e <- rmd_environment()
  expect_snapshot(e$clean)
})
