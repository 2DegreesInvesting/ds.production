rmd_environment <- function(path = system.file("extdata", "mvp.Rmd", package = "production")) {
  e <- new.env()
  rmarkdown::render(path, envir = e, quiet = TRUE)
  e
}
