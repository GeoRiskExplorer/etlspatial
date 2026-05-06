# 01 | Spatial QA summary ------------------------------------------------


#' Spatial QA summary
#'
#' Provides a quick summary of spatial dataset structure and geometry validity.
#'
#' @param x An sf object.
#' @param quiet Logical. If `TRUE`, suppress console output.
#'
#' @return A tibble summarising spatial properties.
#' @export
qa_spatial_summary <- function(x, quiet = FALSE) {

  if (!inherits(x, "sf")) {
    cli::cli_abort("{.arg x} must be an sf object.")
  }

  geom_col <- attr(x, "sf_column")

  geom <- sf::st_geometry(x)

  geom_type <- unique(as.character(sf::st_geometry_type(geom)))
  geom_type <- paste(geom_type, collapse = ",")

  crs_obj <- sf::st_crs(x)

  crs_epsg <- crs_obj$epsg
  crs_name <- crs_obj$Name

  valid <- sum(sf::st_is_valid(geom), na.rm = TRUE)
  invalid <- sum(!sf::st_is_valid(geom), na.rm = TRUE)
  empty <- sum(sf::st_is_empty(geom), na.rm = TRUE)

  bbox <- sf::st_bbox(x)

  out <- tibble::tibble(
    dataset = NA_character_,
    rows = nrow(x),
    columns = ncol(x),
    geom_column = geom_col,
    geom_type = geom_type,
    crs_epsg = crs_epsg,
    crs_name = crs_name,
    valid_geometries = valid,
    invalid_geometries = invalid,
    empty_geometries = empty,
    xmin = bbox["xmin"],
    ymin = bbox["ymin"],
    xmax = bbox["xmax"],
    ymax = bbox["ymax"]
  )

  if (!quiet) {
    cli::cli_h2("Spatial QA Summary")
    cli::cli_text("Rows: {nrow(x)}")
    cli::cli_text("Columns: {ncol(x)}")
    cli::cli_text("Geometry column: {geom_col}")
    cli::cli_text("Geometry type: {geom_type}")
    cli::cli_text("CRS: {crs_epsg} - {crs_name}")
    cli::cli_text("Valid geometries: {valid}")
    cli::cli_text("Invalid geometries: {invalid}")
    cli::cli_text("Empty geometries: {empty}")
  }

  out
}


# 02 | Spatial QA plot ---------------------------------------------------


#' Quick spatial QA plot
#'
#' Produces a simple plot of spatial features for quick visual inspection.
#'
#' @param x An sf object.
#' @param quiet Logical. If `TRUE`, suppress messages.
#'
#' @return A ggplot object.
#' @export
qa_spatial_plot <- function(x, quiet = FALSE) {

  if (!inherits(x, "sf")) {
    cli::cli_abort("{.arg x} must be an sf object.")
  }

  p <- ggplot2::ggplot(x) +
    ggplot2::geom_sf(fill = "lightblue", colour = "grey30", linewidth = 0.2) +
    ggplot2::theme_minimal() +
    ggplot2::labs(
      title = "Spatial QA Plot",
      subtitle = paste0(
        "Rows: ", nrow(x),
        " | CRS: ", sf::st_crs(x)$epsg
      )
    )

  if (!quiet) {
    cli::cli_alert_info("Spatial QA plot generated")
  }

  p
}