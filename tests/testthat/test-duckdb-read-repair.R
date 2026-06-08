# =========================================================
# Tests — DuckDB read geometry repair options
# =========================================================

test_that("read_sf_from_duckdb supports make_valid argument", {

  skip_if_not_installed("sf")
  skip_if_not_installed("DBI")
  skip_if_not_installed("duckdb")

wkt_invalid <- "POLYGON((0 0, 1 0, 1 1, 0 1, 0 0, 0 0))"

  df <- data.frame(
    id = 1L,
    geom_wkt = wkt_invalid
  )

  con <- DBI::dbConnect(
    duckdb::duckdb(),
    dbdir = ":memory:"
  )

  on.exit(
    DBI::dbDisconnect(con, shutdown = TRUE),
    add = TRUE
  )

  DBI::dbExecute(con, "CREATE SCHEMA spatial")

  DBI::dbWriteTable(
    conn = con,
    name = DBI::Id(schema = "spatial", table = "invalid_geom_test"),
    value = df,
    overwrite = TRUE
  )

  y_raw <- read_sf_from_duckdb(
    con = con,
    table_name = "invalid_geom_test",
    schema = "spatial",
    crs = 4326,
    make_valid = FALSE,
    quiet = TRUE
  )

  y_fixed <- read_sf_from_duckdb(
    con = con,
    table_name = "invalid_geom_test",
    schema = "spatial",
    crs = 4326,
    make_valid = TRUE,
    quiet = TRUE
  )

  expect_s3_class(y_raw, "sf")
  expect_s3_class(y_fixed, "sf")

  expect_false(all(sf::st_is_valid(y_raw)))

  expect_s3_class(y_fixed, "sf")
  expect_equal(nrow(y_fixed), 1)
  expect_true(inherits(sf::st_geometry(y_fixed), "sfc"))
})


test_that("read_sf_from_duckdb supports drop_empty argument", {

  skip_if_not_installed("sf")
  skip_if_not_installed("DBI")
  skip_if_not_installed("duckdb")

  df <- data.frame(
    id = c(1L, 2L),
    geom_wkt = c(
      "POINT (144.9 -37.8)",
      "POINT EMPTY"
    )
  )

  con <- DBI::dbConnect(
    duckdb::duckdb(),
    dbdir = ":memory:"
  )

  on.exit(
    DBI::dbDisconnect(con, shutdown = TRUE),
    add = TRUE
  )

  DBI::dbExecute(con, "CREATE SCHEMA spatial")

  DBI::dbWriteTable(
    conn = con,
    name = DBI::Id(schema = "spatial", table = "empty_geom_test"),
    value = df,
    overwrite = TRUE
  )

  y_keep <- read_sf_from_duckdb(
    con = con,
    table_name = "empty_geom_test",
    schema = "spatial",
    crs = 4326,
    drop_empty = FALSE,
    quiet = TRUE
  )

  y_drop <- read_sf_from_duckdb(
    con = con,
    table_name = "empty_geom_test",
    schema = "spatial",
    crs = 4326,
    drop_empty = TRUE,
    quiet = TRUE
  )

  expect_equal(nrow(y_keep), 2)
  expect_equal(sum(sf::st_is_empty(y_keep)), 1)

  expect_equal(nrow(y_drop), 1)
  expect_false(any(sf::st_is_empty(y_drop)))
})