# =========================================================
# Tests — DuckDB file creation and read behaviour
# =========================================================

test_that("write_sf_to_duckdb creates a DuckDB file when path is new", {

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

  con <- DBI::dbConnect(
    duckdb::duckdb(),
    dbdir = tmp_db
  )

  on.exit(
    DBI::dbDisconnect(con, shutdown = TRUE),
    add = TRUE
  )

  write_sf_to_duckdb(
    x = x,
    con = con,
    table_name = "file_create_test",
    schema = "spatial",
    overwrite = TRUE,
    quiet = TRUE
  )

  expect_true(
    file.exists(tmp_db)
  )

  expect_true(
    DBI::dbExistsTable(
      con,
      DBI::Id(
        schema = "spatial",
        table = "file_create_test"
      )
    )
  )
})


test_that("read_sf_from_duckdb errors when table does not exist", {

  skip_if_not_installed("DBI")
  skip_if_not_installed("duckdb")

  con <- DBI::dbConnect(
    duckdb::duckdb(),
    dbdir = ":memory:"
  )

  on.exit(
    DBI::dbDisconnect(con, shutdown = TRUE),
    add = TRUE
  )

  expect_error(
    read_sf_from_duckdb(
      con = con,
      table_name = "missing_table",
      schema = "spatial"
    )
  )
})