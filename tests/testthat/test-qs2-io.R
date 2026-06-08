# =========================================================
# Tests — qs2 IO
# =========================================================

get_demo_sf <- function() {
  demo_gpkg <- system.file(
    "extdata",
    "abs_sa4_vic_demo.gpkg",
    package = "etlspatial"
  )

  testthat::skip_if(demo_gpkg == "", "Demo GeoPackage not available")

  sf::st_read(
    demo_gpkg,
    quiet = TRUE
  )
}


test_that("qs2 round-trips sf object", {

  skip_if_not_installed("qs2")

  x <- get_demo_sf()

  tmp_qs2 <- tempfile(fileext = ".qs2")

  write_sf_to_qs2(
    x = x,
    path = tmp_qs2,
    quiet = TRUE
  )

  y <- read_sf_from_qs2(
    path = tmp_qs2,
    quiet = TRUE
  )

  expect_true(file.exists(tmp_qs2))
  expect_s3_class(y, "sf")
  expect_equal(nrow(y), nrow(x))
  expect_equal(sf::st_crs(y)$epsg, sf::st_crs(x)$epsg)
  expect_true(inherits(sf::st_geometry(y), "sfc"))
})


test_that("qs2 supports sf_obj alias", {

  skip_if_not_installed("qs2")

  x <- get_demo_sf()

  tmp_qs2 <- tempfile(fileext = ".qs2")

  write_sf_to_qs2(
    sf_obj = x,
    path = tmp_qs2,
    quiet = TRUE
  )

  y <- read_sf_from_qs2(
    path = tmp_qs2,
    quiet = TRUE
  )

  expect_s3_class(y, "sf")
  expect_equal(nrow(y), nrow(x))
})


test_that("qs2 overwrite protection works", {

  skip_if_not_installed("qs2")

  x <- get_demo_sf()

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

  skip_if_not_installed("qs2")

  missing_qs2 <- tempfile(fileext = ".qs2")

  expect_false(file.exists(missing_qs2))

  expect_error(
    read_sf_from_qs2(
      path = missing_qs2,
      quiet = TRUE
    ),
    "qs2 file not found"
  )
})