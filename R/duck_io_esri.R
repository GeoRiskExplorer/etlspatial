# 01 | End-to-end ETL: ESRI ↔ DuckDB ------------------------------------


#' End-to-end spatial ETL (ESRI ↔ DuckDB)
#'
#' Reads a spatial dataset, applies optional transformations,
#' and writes to DuckDB or spatial output formats.
#'
#' @param source Path to input dataset (GDB, shapefile, or GeoPackage).
#' @param source_layer Layer name.
#' @param source_type Optional format override (`"gdb"`, `"shapefile"`, `"gpkg"`).
#'
#' @param target Output target. Either DuckDB path or spatial file path.
#' @param target_type One of `"duckdb"`, `"gdb"`, `"shapefile"`, `"gpkg"`.
#' @param target_layer Output layer/table name.
#'
#' @param duckdb_path Path to DuckDB database (required if target_type = "duckdb").
#' @param schema DuckDB schema. Defaults to `"spatial"`.
#'
#' @param crs Optional CRS override.
#' @param validate_geom Logical. Validate geometry.
#' @param repair_geom Logical. Repair geometry.
#'
#' @param qa Logical. Run QA summary.
#' @param qa_plot Logical. Produce QA plot.
#'
#' @param quiet Logical. Suppress console output.
#' @param return_data_only Logical. If `TRUE`, return the processed sf object instead of writing output.
#'
#' @return Invisibly returns processed sf object (if `return_data_only = TRUE`).
#' @export
duck_io_esri <- function(source,
                         source_layer,
                         source_type = NULL,
                         target,
                         target_type = c("duckdb", "gdb", "shapefile", "gpkg"),
                         target_layer,
                         duckdb_path = NULL,
                         schema = "spatial",
                         crs = NULL,
                         validate_geom = TRUE,
                         repair_geom = TRUE,
                         qa = TRUE,
                         qa_plot = FALSE,
                         quiet = FALSE,
                         return_data_only = FALSE) {

  target_type <- match.arg(target_type)

  if (is.null(source) || is.null(source_layer)) {
    cli::cli_abort("{.arg source} and {.arg source_layer} must be supplied.")
  }

  if (is.null(target) || is.null(target_layer)) {
    cli::cli_abort("{.arg target} and {.arg target_layer} must be supplied.")
  }

  if (target_type == "duckdb" && is.null(duckdb_path)) {
    cli::cli_abort("{.arg duckdb_path} must be supplied for DuckDB output.")
  }

  # ---- Read -------------------------------------------------------------

  x <- read_esri_layer(
    dsn = source,
    layer = source_layer,
    format = source_type,
    quiet = TRUE
  )

  # ---- Geometry handling -----------------------------------------------

  if (!is.null(crs)) {
    x <- sf::st_set_crs(x, crs)
  }

  if (validate_geom) {
    x <- sf::st_make_valid(x)
  }

  if (repair_geom) {
    x <- sf::st_make_valid(x)
  }

  # ---- QA ---------------------------------------------------------------

  if (qa && !quiet) {
    qa_spatial_summary(x)
  }

  if (qa_plot && !quiet) {
    qa_spatial_plot(x)
  }

  # ---- Write ------------------------------------------------------------

  if (target_type == "duckdb") {

    con <- DBI::dbConnect(
      duckdb::duckdb(),
      dbdir = duckdb_path
    )

    on.exit(DBI::dbDisconnect(con, shutdown = TRUE), add = TRUE)

    write_sf_to_duckdb(
      x = x,
      con = con,
      table_name = target_layer,
      schema = schema,
      quiet = quiet
    )

  } else {

    write_esri_layer(
      x = x,
      dsn = target,
      layer = target_layer,
      format = target_type,
      quiet = quiet
    )
  }

  # ---- Output -----------------------------------------------------------

  if (!quiet) {
    cli::cli_h1("duck_io_esri completed")
    cli::cli_text("Target type: {target_type}")
    cli::cli_text("Output name: {target_layer}")
  }

  if (return_data_only) {
    return(invisible(x))
  }

  invisible(target_layer)
}