# =========================================================
# Tests — Parquet IO
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


test_that("Parquet round-trips sf object", {

  skip_if_not_installed("arrow")

  x <- get_demo_sf()

  tmp_parquet <- tempfile(fileext = ".parquet")

  write_sf_to_parquet(
    x = x,
    path = tmp_parquet,
    quiet = TRUE
  )

  y <- read_sf_from_parquet(
    path = tmp_parquet,
    quiet = TRUE
  )

  expect_true(file.exists(tmp_parquet))
  expect_s3_class(y, "sf")
  expect_equal(nrow(y), nrow(x))
  expect_equal(sf::st_crs(y)$epsg, sf::st_crs(x)$epsg)
  expect_true(inherits(sf::st_geometry(y), "sfc"))
})


test_that("Parquet supports sf_obj alias", {

  skip_if_not_installed("arrow")

  x <- get_demo_sf()

  tmp_parquet <- tempfile(fileext = ".parquet")

  write_sf_to_parquet(
    sf_obj = x,
    path = tmp_parquet,
    quiet = TRUE
  )

  y <- read_sf_from_parquet(
    path = tmp_parquet,
    quiet = TRUE
  )

  expect_s3_class(y, "sf")
  expect_equal(nrow(y), nrow(x))
})


test_that("Parquet overwrite protection works", {

  skip_if_not_installed("arrow")

  x <- get_demo_sf()

  tmp_parquet <- tempfile(fileext = ".parquet")

  write_sf_to_parquet(
    x = x,
    path = tmp_parquet,
    overwrite = TRUE,
    quiet = TRUE
  )

  expect_error(
    write_sf_to_parquet(
      x = x,
      path = tmp_parquet,
      overwrite = FALSE,
      quiet = TRUE
    )
  )
})


test_that("invalid Parquet path errors cleanly", {

  skip_if_not_installed("arrow")

  missing_parquet <- tempfile(fileext = ".parquet")

  expect_false(file.exists(missing_parquet))

  expect_error(
    read_sf_from_parquet(
      path = missing_parquet,
      quiet = TRUE
    ),
    "Parquet file not found"
  )
})


test_that("Parquet output can be queried by DuckDB", {

  skip_if_not_installed("arrow")
  skip_if_not_installed("DBI")
  skip_if_not_installed("duckdb")

  x <- get_demo_sf()

  tmp_parquet <- tempfile(fileext = ".parquet")

  write_sf_to_parquet(
    x = x,
    path = tmp_parquet,
    quiet = TRUE
  )

  con <- DBI::dbConnect(
    duckdb::duckdb(),
    dbdir = ":memory:"
  )

  on.exit(
    DBI::dbDisconnect(con, shutdown = TRUE),
    add = TRUE
  )

  parquet_path <- normalizePath(
    tmp_parquet,
    winslash = "/",
    mustWork = TRUE
  )

  result <- DBI::dbGetQuery(
    con,
    paste0(
      "SELECT COUNT(*) AS n FROM read_parquet('",
      parquet_path,
      "')"
    )
  )

  expect_equal(result$n, nrow(x))
})