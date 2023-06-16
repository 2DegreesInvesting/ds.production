test_that("`localized` hasn't changed", {
  path <- system.file("extdata", "mvp.Rmd", package = "production")
  e <- new.env()
  rmarkdown::render(path, envir = e, quiet = TRUE)
  expect_snapshot(e$localized)
})

test_that("`clean` hasn't changed", {
  path <- system.file("extdata", "mvp.Rmd", package = "production")
  e <- new.env()
  rmarkdown::render(path, envir = e, quiet = TRUE)
  expect_snapshot(e$clean)
})
