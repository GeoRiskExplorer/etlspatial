# =========================================================
# Tests — DuckDB connection lifecycle
# =========================================================

test_that("read_sf_from_duckdb does not close caller-owned connection", {

  skip_if_not_installed("sf")
  skip_if_not_installed("DBI")
  skip_if_not_installed("duckdb")

  demo_gpkg <- system.file(
    "extdata",
    "abs_sa4_vic_demo.gpkg",
    package = "etlspatial"
  )

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
    table_name = "connection_lifecycle_test",
    quiet = TRUE
  )

  y <- read_sf_from_duckdb(
    con = con,
    table_name = "connection_lifecycle_test",
    quiet = TRUE
  )

  expect_s3_class(y, "sf")
  expect_true(DBI::dbIsValid(con))

  result <- DBI::dbGetQuery(con, "SELECT 1 AS ok")

  expect_equal(result$ok, 1)
})