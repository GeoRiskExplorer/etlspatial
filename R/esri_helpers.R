# 01 | List layers in a file geodatabase ---------------------------------

#' List layers in a File Geodatabase
#'
#' @param gdb_path Path to .gdb folder.
#'
#' @return A tibble of layers.
#' @export
etl_list_gdb_layers <- function(gdb_path) {

  if (!fs::dir_exists(gdb_path)) {
    cli::cli_abort("GDB path does not exist: {.path {gdb_path}}")
  }

  layers <- sf::st_layers(gdb_path)

  geom_clean <- vapply(
    layers$geomtype,
    FUN = function(x) {
      if (is.null(x) || length(x) == 0) {
        NA_character_
      } else {
        as.character(x[[1]])
      }
    },
    FUN.VALUE = character(1)
  )

  out <- tibble::tibble(
    layer_name = layers$name,
    geom_type = geom_clean,
    feature_count = layers$features
  )

  cli::cli_h1("GDB layer listing")
  cli::cli_text("Path: {gdb_path}")
  cli::cli_text("Layers found: {nrow(out)}")

  return(out)
}


# 02 | Check a single spatial layer --------------------------------------

#' Inspect a spatial layer before loading
#'
#' @param dsn Path to GDB, shapefile folder, or GeoPackage.
#' @param layer Layer name.
#' @param format One of `"gdb"`, `"shapefile"`, or `"gpkg"`.
#' @param sample_n Number of rows to sample. Defaults to 100.
#'
#' @return A list with summary and sample sf object.
#' @export
etl_check_layer <- function(dsn,
                            layer,
                            format = c("gdb", "shapefile", "gpkg"),
                            sample_n = 100) {

  format <- match.arg(format)

  x <- read_esri_layer(
    dsn = dsn,
    layer = layer,
    format = format
  )

  n <- nrow(x)
  sample_n <- min(sample_n, n)

  x_sample <- x |>
    dplyr::slice_sample(n = sample_n)

  bbox <- sf::st_bbox(x)

  summary <- tibble::tibble(
    layer_name = layer,
    format = format,
    rows = n,
    columns = ncol(x),
    geom_column = attr(x, "sf_column"),
    geom_type = paste(unique(sf::st_geometry_type(x)), collapse = ", "),
    crs = sf::st_crs(x)$epsg,
    valid = sum(sf::st_is_valid(x)),
    invalid = sum(!sf::st_is_valid(x)),
    empty = sum(sf::st_is_empty(x)),
    xmin = unname(bbox["xmin"]),
    ymin = unname(bbox["ymin"]),
    xmax = unname(bbox["xmax"]),
    ymax = unname(bbox["ymax"])
  )

  cli::cli_h1("Layer check")
  cli::cli_text("Layer: {layer}")
  cli::cli_text("Format: {format}")
  cli::cli_text("Rows: {n}")
  cli::cli_text("Geometry: {summary$geom_type}")
  cli::cli_text("CRS: {summary$crs}")
  cli::cli_text("Empty geometries: {summary$empty}")

  return(list(
    summary = summary,
    sample = x_sample
  ))
}