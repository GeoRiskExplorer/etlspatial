# =========================================================
# Tests — DuckDB db_path convenience workflow
# =========================================================

test_that("write_sf_to_duckdb works with db_path instead of con", {

  skip_if_not_installed("sf")
  skip_if_not_installed("DBI")
  skip_if_not_installed("duckdb")

  demo_gpkg <- system.file(
    "extdata",
    "abs_sa4_vic_demo.gpkg",
    package = "etlspatial"
  )

  skip_if(demo_gpkg == "", "Demo GeoPackage not available")

  x <- sf::st_read(demo_gpkg, quiet = TRUE)

  tmp_db <- tempfile(fileext = ".duckdb")

  write_sf_to_duckdb(
    x = x,
    db_path = tmp_db,
    table_name = "db_path_test",
    schema = "spatial",
    overwrite = TRUE,
    quiet = TRUE
  )

  expect_true(file.exists(tmp_db))

  y <- read_sf_from_duckdb(
    db_path = tmp_db,
    table_name = "db_path_test",
    schema = "spatial",
    quiet = TRUE
  )

  expect_s3_class(y, "sf")
  expect_equal(nrow(y), nrow(x))
  expect_equal(sf::st_crs(y)$epsg, sf::st_crs(x)$epsg)
})


test_that("write_sf_to_duckdb accepts sf_obj alias", {

  skip_if_not_installed("sf")
  skip_if_not_installed("duckdb")

  demo_gpkg <- system.file(
    "extdata",
    "abs_sa4_vic_demo.gpkg",
    package = "etlspatial"
  )

  skip_if(demo_gpkg == "", "Demo GeoPackage not available")

  x <- sf::st_read(demo_gpkg, quiet = TRUE)

  tmp_db <- tempfile(fileext = ".duckdb")

  write_sf_to_duckdb(
    sf_obj = x,
    db_path = tmp_db,
    table_name = "sf_obj_alias_test",
    quiet = TRUE
  )

  y <- read_sf_from_duckdb(
    db_path = tmp_db,
    table_name = "sf_obj_alias_test",
    quiet = TRUE
  )

  expect_s3_class(y, "sf")
  expect_equal(nrow(y), nrow(x))
})


test_that("read_sf_from_duckdb errors when db_path does not exist", {

  skip_if_not_installed("duckdb")

  missing_db <- tempfile(fileext = ".duckdb")

  expect_false(file.exists(missing_db))

  expect_error(
    read_sf_from_duckdb(
      db_path = missing_db,
      table_name = "missing_table",
      quiet = TRUE
    ),
    "DuckDB file not found"
  )
})