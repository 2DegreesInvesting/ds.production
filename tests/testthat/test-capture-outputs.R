test_that("`localized` hasn't changed", {
  path <- system.file("extdata", "mvp.Rmd", package = "production")
  e <- new.env()
  rmarkdown::render(path, envir = e)
  expect_snapshot(e$localized)
})
