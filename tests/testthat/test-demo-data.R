# =========================================================
# Tests — demo data availability
# =========================================================

test_that("demo GeoPackage is available and readable", {

  skip_if_not_installed("sf")

  demo_gpkg <- system.file(
    "extdata",
    "abs_sa4_vic_demo.gpkg",
    package = "etlspatial"
  )

  expect_true(file.exists(demo_gpkg))
  expect_true(nzchar(demo_gpkg))

  x <- sf::st_read(demo_gpkg, quiet = TRUE)

  expect_s3_class(x, "sf")
  expect_gt(nrow(x), 0)
  expect_true(inherits(sf::st_geometry(x), "sfc"))
  expect_false(is.na(sf::st_crs(x)))
  expect_true(all(sf::st_is_valid(x)))
})