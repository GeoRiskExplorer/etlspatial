# =========================================================
# Tests — DuckDB round-trip integrity
# =========================================================

test_that("sf object survives DuckDB round-trip", {

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
    table_name = "roundtrip_test",
    schema = "spatial",
    overwrite = TRUE,
    quiet = TRUE
  )

  y <- read_sf_from_duckdb(
    con = con,
    table_name = "roundtrip_test",
    schema = "spatial"
  )

  # -------------------------------------------------------
  # Core integrity checks
  # -------------------------------------------------------

expect_s3_class(y, "sf")

expect_equal(
  nrow(y),
  nrow(x)
)

expect_equal(
  sf::st_crs(y)$epsg,
  sf::st_crs(x)$epsg
)

expect_true(
  inherits(sf::st_geometry(y), "sfc")
)

expect_equal(
  length(sf::st_geometry(y)),
  length(sf::st_geometry(x))
)

expect_false(
  all(sf::st_is_empty(y))
)

})