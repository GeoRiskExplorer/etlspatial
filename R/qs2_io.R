# =========================================================
# qs2 IO for sf objects
# =========================================================

#' Write sf object to qs2
#'
#' @param x An sf object.
#' @param sf_obj Optional alias for `x`.
#' @param path Output qs2 file path.
#' @param overwrite Logical. If `TRUE`, overwrite an existing file.
#' @param quiet Logical. If `TRUE`, suppress status messages.
#'
#' @return Invisibly returns the output path.
#' @export
write_sf_to_qs2 <- function(x = NULL,
                            sf_obj = NULL,
                            path,
                            overwrite = TRUE,
                            quiet = FALSE) {

  rlang::check_installed("qs2")

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

  qs2::qs_save(
    x,
    file = path
  )

  crs_epsg <- sf::st_crs(x)$epsg

  if (is.null(crs_epsg) || is.na(crs_epsg)) {
    crs_epsg <- "NA"
  }

  if (!quiet) {
    cli::cli_alert_success("sf object written to qs2: {.path {path}}")
    cli::cli_text("Rows: {nrow(x)}")
    cli::cli_text("CRS: {crs_epsg}")
  }

  invisible(path)
}


#' Read sf object from qs2
#'
#' @param path Input qs2 file path.
#' @param quiet Logical. If `TRUE`, suppress status messages.
#'
#' @return An sf object.
#' @export
read_sf_from_qs2 <- function(path,
                             quiet = FALSE) {

  rlang::check_installed("qs2")

  if (missing(path) || is.null(path) || !is.character(path) || length(path) != 1) {
    cli::cli_abort("{.arg path} must be a single file path.")
  }

  if (!file.exists(path)) {
    cli::cli_abort("qs2 file not found: {.path {path}}")
  }

  x <- qs2::qs_read(path)

  if (!inherits(x, "sf")) {
    cli::cli_abort("Object read from qs2 is not an sf object.")
  }

  crs_epsg <- sf::st_crs(x)$epsg

  if (is.null(crs_epsg) || is.na(crs_epsg)) {
    crs_epsg <- "NA"
  }

  if (!quiet) {
    cli::cli_alert_success("sf object read from qs2: {.path {path}}")
    cli::cli_text("Rows: {nrow(x)}")
    cli::cli_text("CRS: {crs_epsg}")
  }

  x
}