# =========================================================
# qs2 IO for sf objects
# =========================================================

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
    cli::cli_abort("No sf object supplied. Use `x` or `sf_obj`.")
  }

  if (!inherits(x, "sf")) {
    cli::cli_abort("`x` must be an sf object.")
  }

  if (file.exists(path) && !overwrite) {
    cli::cli_abort("File already exists: {.path {path}}")
  }

  dir.create(dirname(path), recursive = TRUE, showWarnings = FALSE)

  qs2::qs_save(x, file = path)

  if (!quiet) {
    cli::cli_alert_success("sf object written to qs2: {.path {path}}")
  }

  invisible(path)
}


read_sf_from_qs2 <- function(path,
                                   quiet = FALSE) {

  rlang::check_installed("qs2")

  if (!file.exists(path)) {
    cli::cli_abort("qs2 file not found: {.path {path}}")
  }

  x <- qs2::qs_read(path)

  if (!inherits(x, "sf")) {
    cli::cli_abort("Object read from qs2 is not an sf object.")
  }

  if (!quiet) {
    cli::cli_alert_success("sf object read from qs2: {.path {path}}")
  }

  x
}