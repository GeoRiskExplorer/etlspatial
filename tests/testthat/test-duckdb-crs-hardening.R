# =========================================================
# Tests — DuckDB CRS and geometry hardening
# =========================================================

make_duckdb_con <- function() {
  con <- DBI::dbConnect(
    duckdb::duckdb(),
    dbdir = ":memory:"
  )

  DBI::dbExecute(con, "CREATE SCHEMA spatial")

  con
}


write_test_table <- function(con,
                             table_name,
                             df) {
  DBI::dbWriteTable(
    conn = con,
    name = DBI::Id(
      schema = "spatial",
      table = table_name
    ),
    value = df,
    overwrite = TRUE
  )
}


test_that("read_sf_from_duckdb reads table with explicit CRS", {

  con <- make_duckdb_con()

  on.exit(
    DBI::dbDisconnect(con, shutdown = TRUE),
    add = TRUE
  )

  write_test_table(
    con = con,
    table_name = "explicit_crs_test",
    df = data.frame(
      id = 1L,
      geom_wkt = "POINT (144.9 -37.8)"
    )
  )

  x <- read_sf_from_duckdb(
    con = con,
    schema = "spatial",
    table_name = "explicit_crs_test",
    crs = 9473,
    quiet = TRUE
  )

  expect_s3_class(x, "sf")
  expect_equal(nrow(x), 1)
  expect_equal(sf::st_crs(x)$epsg, 9473)
})


test_that("read_sf_from_duckdb reads CRS from table_registry when available", {

  con <- make_duckdb_con()

  on.exit(
    DBI::dbDisconnect(con, shutdown = TRUE),
    add = TRUE
  )

  write_test_table(
    con = con,
    table_name = "registry_crs_test",
    df = data.frame(
      id = 1L,
      geom_wkt = "POINT (144.9 -37.8)"
    )
  )

  DBI::dbWriteTable(
    conn = con,
    name = DBI::Id(schema = "spatial", table = "table_registry"),
    value = data.frame(
      table_name = "registry_crs_test",
      source_type = "test",
      geom_type = "POINT",
      crs = 9473L,
      row_count = 1L,
      created_at = Sys.time()
    ),
    overwrite = TRUE
  )

  x <- read_sf_from_duckdb(
    con = con,
    schema = "spatial",
    table_name = "registry_crs_test",
    quiet = TRUE
  )

  expect_s3_class(x, "sf")
  expect_equal(nrow(x), 1)
  expect_equal(sf::st_crs(x)$epsg, 9473)
})


test_that("read_sf_from_duckdb reads with NA CRS when registry is missing", {

  con <- make_duckdb_con()

  on.exit(
    DBI::dbDisconnect(con, shutdown = TRUE),
    add = TRUE
  )

  write_test_table(
    con = con,
    table_name = "missing_registry_test",
    df = data.frame(
      id = 1L,
      geom_wkt = "POINT (144.9 -37.8)"
    )
  )

  x <- read_sf_from_duckdb(
    con = con,
    schema = "spatial",
    table_name = "missing_registry_test",
    quiet = TRUE
  )

  expect_s3_class(x, "sf")
  expect_equal(nrow(x), 1)
  expect_true(is.na(sf::st_crs(x)$epsg))
})


test_that("read_sf_from_duckdb reads with NA CRS when registry has no matching row", {

  con <- make_duckdb_con()

  on.exit(
    DBI::dbDisconnect(con, shutdown = TRUE),
    add = TRUE
  )

  write_test_table(
    con = con,
    table_name = "registry_no_match_test",
    df = data.frame(
      id = 1L,
      geom_wkt = "POINT (144.9 -37.8)"
    )
  )

  DBI::dbWriteTable(
    conn = con,
    name = DBI::Id(schema = "spatial", table = "table_registry"),
    value = data.frame(
      table_name = "different_table",
      source_type = "test",
      geom_type = "POINT",
      crs = 9473L,
      row_count = 1L,
      created_at = Sys.time()
    ),
    overwrite = TRUE
  )

  x <- read_sf_from_duckdb(
    con = con,
    schema = "spatial",
    table_name = "registry_no_match_test",
    quiet = TRUE
  )

  expect_s3_class(x, "sf")
  expect_equal(nrow(x), 1)
  expect_true(is.na(sf::st_crs(x)$epsg))
})


test_that("read_sf_from_duckdb errors clearly when geom_wkt column is missing", {

  con <- make_duckdb_con()

  on.exit(
    DBI::dbDisconnect(con, shutdown = TRUE),
    add = TRUE
  )

  write_test_table(
    con = con,
    table_name = "missing_geom_wkt_test",
    df = data.frame(
      id = 1L,
      not_geom = "POINT (144.9 -37.8)"
    )
  )

  expect_error(
    read_sf_from_duckdb(
      con = con,
      schema = "spatial",
      table_name = "missing_geom_wkt_test",
      quiet = TRUE
    ),
    "WKT geometry column not found"
  )
})


test_that("read_sf_from_duckdb errors clearly when geom_wkt is all NA", {

  con <- make_duckdb_con()

  on.exit(
    DBI::dbDisconnect(con, shutdown = TRUE),
    add = TRUE
  )

  write_test_table(
    con = con,
    table_name = "all_na_geom_wkt_test",
    df = data.frame(
      id = c(1L, 2L),
      geom_wkt = c(NA_character_, NA_character_)
    )
  )

  expect_error(
    read_sf_from_duckdb(
      con = con,
      schema = "spatial",
      table_name = "all_na_geom_wkt_test",
      crs = 9473,
      quiet = TRUE
    ),
    "WKT geometry column contains only NA values"
  )
})


test_that("read_sf_from_duckdb errors clearly when table is empty", {

  con <- make_duckdb_con()

  on.exit(
    DBI::dbDisconnect(con, shutdown = TRUE),
    add = TRUE
  )

  empty_df <- data.frame(
    id = integer(),
    geom_wkt = character()
  )

  write_test_table(
    con = con,
    table_name = "empty_table_test",
    df = empty_df
  )

  expect_error(
    read_sf_from_duckdb(
      con = con,
      schema = "spatial",
      table_name = "empty_table_test",
      crs = 9473,
      quiet = TRUE
    ),
    "DuckDB table is empty"
  )
})


test_that("read_sf_from_duckdb errors clearly when table is missing", {

  con <- make_duckdb_con()

  on.exit(
    DBI::dbDisconnect(con, shutdown = TRUE),
    add = TRUE
  )

  expect_error(
    read_sf_from_duckdb(
      con = con,
      schema = "spatial",
      table_name = "does_not_exist",
      quiet = TRUE
    ),
    "Table not found"
  )
})


test_that("read_sf_from_duckdb does not close caller-owned connection", {

  con <- make_duckdb_con()

  on.exit(
    DBI::dbDisconnect(con, shutdown = TRUE),
    add = TRUE
  )

  write_test_table(
    con = con,
    table_name = "connection_lifecycle_harden_test",
    df = data.frame(
      id = 1L,
      geom_wkt = "POINT (144.9 -37.8)"
    )
  )

  x <- read_sf_from_duckdb(
    con = con,
    schema = "spatial",
    table_name = "connection_lifecycle_harden_test",
    crs = 9473,
    quiet = TRUE
  )

  expect_s3_class(x, "sf")
  expect_true(DBI::dbIsValid(con))

  y <- DBI::dbGetQuery(con, "SELECT 1 AS ok")

  expect_equal(y$ok, 1)
})