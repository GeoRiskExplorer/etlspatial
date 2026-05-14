# =========================================================
# Testing — qs2 IO
# =========================================================

library(testthat)
library(sf)

demo_gpkg <- system.file(
  "extdata",
  "abs_sa4_vic_demo.gpkg",
  package = "etlspatial"
)

x <- sf::st_read(demo_gpkg, quiet = TRUE)

test_that("qs2 round-trips sf object", {

  skip_if_not_installed("qs2")

  tmp_qs2 <- tempfile(fileext = ".qs2")

  write_sf_to_qs2 (
    x = x,
    path = tmp_qs2,
    quiet = TRUE
  )

  y <- read_sf_from_qs2 (
    path = tmp_qs2,
    quiet = TRUE
  )

  expect_true(file.exists(tmp_qs2))
  expect_s3_class(y, "sf")
  expect_equal(nrow(y), nrow(x))
  expect_equal(sf::st_crs(y)$epsg, sf::st_crs(x)$epsg)
  expect_true(inherits(sf::st_geometry(y), "sfc"))
})

test_that("qs2 overwrite protection works", {

  skip_if_not_installed("qs2")

  tmp_qs2 <- tempfile(fileext = ".qs2")

  write_sf_to_qs2(
    x = x,
    path = tmp_qs2,
    overwrite = TRUE,
    quiet = TRUE
  )

  expect_error(
    write_sf_to_qs2(
      x = x,
      path = tmp_qs2,
      overwrite = FALSE,
      quiet = TRUE
    )
  )
})

test_that("invalid qs2 path errors cleanly", {

  expect_error(
    read_sf_from_qs2(
      path = "missing_file.qs2",
      quiet = TRUE
    )
  )
})