# =========================================================
# Tests — DuckDB registry integrity
# =========================================================

test_that("write_sf_to_duckdb creates and updates table registry", {

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

  con <- DBI::dbConnect(
    duckdb::duckdb(),
    dbdir = ":memory:"
  )

  on.exit(
    DBI::dbDisconnect(con, shutdown = TRUE),
    add = TRUE
  )

  write_sf_to_duckdb(
    x = x,
    con = con,
    table_name = "registry_test",
    schema = "spatial",
    overwrite = TRUE,
    quiet = TRUE
  )

  expect_true(
    DBI::dbExistsTable(
      con,
      DBI::Id(schema = "spatial", table = "table_registry")
    )
  )

  registry <- DBI::dbReadTable(
    con,
    DBI::Id(schema = "spatial", table = "table_registry")
  )

  registry_row <- registry[registry$table_name == "registry_test", ]

  expect_equal(nrow(registry_row), 1)
  expect_equal(registry_row$row_count, nrow(x))
  expect_equal(registry_row$source_type, "sf")
  expect_equal(registry_row$crs, sf::st_crs(x)$epsg)
  expect_true(!is.na(registry_row$created_at))
})


test_that("overwrite replaces registry entry rather than duplicating it", {

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

  con <- DBI::dbConnect(
    duckdb::duckdb(),
    dbdir = ":memory:"
  )

  on.exit(
    DBI::dbDisconnect(con, shutdown = TRUE),
    add = TRUE
  )

  write_sf_to_duckdb(
    x = x,
    con = con,
    table_name = "registry_overwrite_test",
    schema = "spatial",
    overwrite = TRUE,
    quiet = TRUE
  )

  write_sf_to_duckdb(
    x = x[1:5, ],
    con = con,
    table_name = "registry_overwrite_test",
    schema = "spatial",
    overwrite = TRUE,
    quiet = TRUE
  )

  registry <- DBI::dbReadTable(
    con,
    DBI::Id(schema = "spatial", table = "table_registry")
  )

  registry_row <- registry[registry$table_name == "registry_overwrite_test", ]

  expect_equal(nrow(registry_row), 1)
  expect_equal(registry_row$row_count, 5)
})