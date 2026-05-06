# 01 | ESRI / spatial file IO helpers ------------------------------------


# Internal helper ---------------------------------------------------------

#' Guess spatial file format
#'
#' @param dsn Path to a spatial data source.
#'
#' @return One of `"gdb"`, `"shapefile"`, or `"gpkg"`.
#' @keywords internal
guess_spatial_format <- function(dsn) {
  if (is.null(dsn) || !is.character(dsn) || length(dsn) != 1) {
    cli::cli_abort("{.arg dsn} must be a single file or folder path.")
  }

  dsn_lower <- tolower(dsn)

  if (grepl("\\.gdb$", dsn_lower)) {
    return("gdb")
  }

  if (grepl("\\.gpkg$", dsn_lower)) {
    return("gpkg")
  }

  if (grepl("\\.shp$", dsn_lower)) {
    return("shapefile")
  }

  if (fs::dir_exists(dsn)) {
    return("shapefile")
  }

  cli::cli_abort(
    "Could not infer spatial format from {.path {basename(dsn)}}. Supply {.arg format} explicitly."
  )
}


#' Read a spatial layer as sf
#'
#' Reads a spatial layer from a file geodatabase, shapefile, or GeoPackage.
#'
#' @param dsn Path to a file geodatabase, shapefile folder, shapefile, or GeoPackage.
#' @param layer Layer name.
#' @param format Optional. One of `"gdb"`, `"shapefile"`, or `"gpkg"`. If `NULL`, the format is inferred from `dsn`.
#' @param quiet Logical. If `TRUE`, suppress status messages.
#'
#' @return An sf object.
#' @export
read_esri_layer <- function(dsn,
                            layer,
                            format = NULL,
                            quiet = FALSE) {

  if (is.null(dsn)) {
    cli::cli_abort("{.arg dsn} must be supplied.")
  }

  if (is.null(layer)) {
    cli::cli_abort("{.arg layer} must be supplied.")
  }

  if (is.null(format)) {
    format <- guess_spatial_format(dsn)
  } else {
    format <- match.arg(format, choices = c("gdb", "shapefile", "gpkg"))
  }

  if (format == "gdb") {
    if (!fs::dir_exists(dsn)) {
      cli::cli_abort("File geodatabase does not exist: {.path {basename(dsn)}}")
    }
  }

  if (format == "shapefile") {
    if (grepl("\\.shp$", tolower(dsn))) {
      if (!fs::file_exists(dsn)) {
        cli::cli_abort("Shapefile does not exist: {.path {basename(dsn)}}")
      }
    } else {
      if (!fs::dir_exists(dsn)) {
        cli::cli_abort("Shapefile folder does not exist: {.path {basename(dsn)}}")
      }

      shp_path <- file.path(dsn, paste0(layer, ".shp"))

      if (!fs::file_exists(shp_path)) {
        cli::cli_abort("Shapefile does not exist: {.path {paste0(layer, '.shp')}}")
      }
    }
  }

  if (format == "gpkg") {
    if (!fs::file_exists(dsn)) {
      cli::cli_abort("GeoPackage does not exist: {.path {basename(dsn)}}")
    }
  }

  x <- sf::st_read(
    dsn = dsn,
    layer = layer,
    quiet = TRUE
  )

  if (!quiet) {
    cli::cli_alert_success("Spatial layer read: {layer}")
    cli::cli_text("Format: {format}")
    cli::cli_text("Rows: {nrow(x)}")
  }

  x
}


#' Write an sf object to a spatial file format
#'
#' Writes an sf object to a file geodatabase, shapefile, or GeoPackage.
#'
#' @param x An sf object.
#' @param dsn Output file geodatabase path, shapefile folder, or GeoPackage path.
#' @param layer Output layer name.
#' @param format Optional. One of `"gdb"`, `"shapefile"`, or `"gpkg"`. If `NULL`, the format is inferred from `dsn`.
#' @param overwrite Overwrite existing layer or files.
#' @param clean_names Clean field names before writing.
#' @param repair_geom Validate and normalise geometry for the target/current processing context.
#' @param quiet Logical. If `TRUE`, suppress status messages.
#'
#' @return Invisibly returns output path or layer reference.
#' @export
write_esri_layer <- function(x,
                             dsn,
                             layer,
                             format = NULL,
                             overwrite = TRUE,
                             clean_names = TRUE,
                             repair_geom = TRUE,
                             quiet = FALSE) {

  if (!inherits(x, "sf")) {
    cli::cli_abort("Input {.arg x} must be an sf object.")
  }

  if (is.null(dsn)) {
    cli::cli_abort("{.arg dsn} must be supplied.")
  }

  if (is.null(layer)) {
    cli::cli_abort("{.arg layer} must be supplied.")
  }

  if (is.null(format)) {
    format <- guess_spatial_format(dsn)
  } else {
    format <- match.arg(format, choices = c("gdb", "shapefile", "gpkg"))
  }

  if (clean_names) {
    x <- janitor::clean_names(x)
  }

  if (repair_geom) {
    x <- sf::st_make_valid(x)
  }

  if (format == "gdb") {
    if (!fs::dir_exists(dsn)) {
      cli::cli_abort("File geodatabase does not exist: {.path {basename(dsn)}}")
    }

    sf::st_write(
      obj = x,
      dsn = dsn,
      layer = layer,
      delete_layer = overwrite,
      quiet = TRUE
    )

    if (!quiet) {
      cli::cli_alert_success("File geodatabase layer written: {layer}")
    }

    return(invisible(file.path(dsn, layer)))
  }

  if (format == "shapefile") {
    if (grepl("\\.shp$", tolower(dsn))) {
      out_dir <- dirname(dsn)
      out_layer <- tools::file_path_sans_ext(basename(dsn))
    } else {
      out_dir <- dsn
      out_layer <- layer
    }

    if (!fs::dir_exists(out_dir)) {
      fs::dir_create(out_dir)
    }

    existing_files <- list.files(
      out_dir,
      pattern = paste0("^", out_layer, "\\."),
      full.names = TRUE
    )

    if (overwrite && length(existing_files) > 0) {
      unlink(existing_files)
    }

    sf::st_write(
      obj = x,
      dsn = out_dir,
      layer = out_layer,
      driver = "ESRI Shapefile",
      delete_layer = overwrite,
      quiet = TRUE
    )

    if (!quiet) {
      cli::cli_alert_success("Shapefile written: {out_layer}")
    }

    return(invisible(file.path(out_dir, paste0(out_layer, ".shp"))))
  }

  if (format == "gpkg") {
    out_dir <- dirname(dsn)

    if (!fs::dir_exists(out_dir)) {
      fs::dir_create(out_dir)
    }

    sf::st_write(
      obj = x,
      dsn = dsn,
      layer = layer,
      driver = "GPKG",
      delete_layer = overwrite,
      quiet = TRUE
    )

    if (!quiet) {
      cli::cli_alert_success("GeoPackage layer written: {layer}")
    }

    return(invisible(dsn))
  }
}