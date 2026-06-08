# =========================================================
# Parquet IO for sf objects
# =========================================================

#' Write sf object to Parquet using WKT geometry storage
#'
#' @param x An sf object.
#' @param sf_obj Optional alias for `x`.
#' @param path Output Parquet file path.
#' @param geom_wkt_col Name of WKT geometry column.
#' @param crs_col Name of CRS EPSG column.
#' @param overwrite Logical. If `TRUE`, overwrite an existing file.
#' @param compression Parquet compression codec. Defaults to `"snappy"`.
#' @param quiet Logical. If `TRUE`, suppress status messages.
#'
#' @return Invisibly returns the output path.
#' @export
write_sf_to_parquet <- function(x = NULL,
                                sf_obj = NULL,
                                path,
                                geom_wkt_col = "geom_wkt",
                                crs_col = "crs_epsg",
                                overwrite = TRUE,
                                compression = "snappy",
                                quiet = FALSE) {

  rlang::check_installed("arrow")

  if (is.null(x) && !is.null(sf_obj)) {
    x <- sf_obj
  }

  if (is.null(x)) {
    cli::cli_abort("No sf object supplied. Use {.arg x} or {.arg sf_obj}.")
  }

  if (!inherits(x, "sf")) {
    cli::cli_abort("{.arg x} must be an sf object.")
  }

  if (missing(path) || is.null(path) || !is.character(path) || length(path) != 1) {
    cli::cli_abort("{.arg path} must be a single file path.")
  }

  if (file.exists(path) && !overwrite) {
    cli::cli_abort("File already exists: {.path {path}}")
  }

  dir.create(
    dirname(path),
    recursive = TRUE,
    showWarnings = FALSE
  )

  crs_epsg <- sf::st_crs(x)$epsg

  if (is.null(crs_epsg) || is.na(crs_epsg)) {
    crs_epsg <- NA_integer_
  }

  x_out <- x
  x_out[[geom_wkt_col]] <- sf::st_as_text(sf::st_geometry(x_out))
  x_out[[crs_col]] <- crs_epsg
  x_out <- sf::st_drop_geometry(x_out)

  arrow::write_parquet(
    x = x_out,
    sink = path,
    compression = compression
  )

  if (!quiet) {
    cli::cli_alert_success("sf object written to Parquet: {.path {path}}")
    cli::cli_text("Rows: {nrow(x_out)}")
    cli::cli_text("Geometry WKT column: {geom_wkt_col}")
    cli::cli_text("CRS column: {crs_col}")
  }

  invisible(path)
}


#' Read sf object from Parquet using WKT geometry storage
#'
#' @param path Input Parquet file path.
#' @param geom_wkt_col Name of WKT geometry column.
#' @param crs_col Name of CRS EPSG column.
#' @param crs Optional CRS override.
#' @param geom_col Name of active sf geometry column in output.
#' @param quiet Logical. If `TRUE`, suppress status messages.
#'
#' @return An sf object.
#' @export
read_sf_from_parquet <- function(path,
                                 geom_wkt_col = "geom_wkt",
                                 crs_col = "crs_epsg",
                                 crs = NULL,
                                 geom_col = "geom",
                                 quiet = FALSE) {

  rlang::check_installed("arrow")

  if (missing(path) || is.null(path) || !is.character(path) || length(path) != 1) {
    cli::cli_abort("{.arg path} must be a single file path.")
  }

  if (!file.exists(path)) {
    cli::cli_abort("Parquet file not found: {.path {path}}")
  }

  df <- arrow::read_parquet(path)

  if (!(geom_wkt_col %in% names(df))) {
    cli::cli_abort("WKT geometry column not found: {geom_wkt_col}")
  }

  if (is.null(crs) && crs_col %in% names(df)) {
    crs_values <- unique(df[[crs_col]])
    crs_values <- crs_values[!is.na(crs_values)]

    if (length(crs_values) == 1) {
      crs <- crs_values[1]
    }
  }

  out <- sf::st_as_sf(
    df,
    wkt = geom_wkt_col,
    crs = crs
  )

  names(out)[names(out) == geom_wkt_col] <- geom_col
  sf::st_geometry(out) <- geom_col

  if (!quiet) {
    cli::cli_alert_success("sf object read from Parquet: {.path {path}}")
    cli::cli_text("Rows: {nrow(out)}")
  }

  out
}