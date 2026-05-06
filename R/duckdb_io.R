# 01 | Write sf to DuckDB ------------------------------------------------


#' Write sf object to DuckDB using WKT geometry storage
#'
#' @param x An sf object.
#' @param con DuckDB connection.
#' @param table_name Name of output table.
#' @param schema DuckDB schema. Defaults to `"spatial"`.
#' @param geom_wkt_col Name of WKT geometry column.
#' @param source_type Source type recorded in registry.
#' @param overwrite Logical. If `TRUE`, overwrite an existing table.
#' @param quiet Logical. If `TRUE`, suppress status messages.
#'
#' @return Invisibly returns the written table name.
#' @export
write_sf_to_duckdb <- function(x,
                               con,
                               table_name,
                               schema = "spatial",
                               geom_wkt_col = "geom_wkt",
                               source_type = "sf",
                               overwrite = TRUE,
                               quiet = FALSE) {

  if (!inherits(x, "sf")) {
    cli::cli_abort("{.arg x} must be an sf object.")
  }

  if (!DBI::dbIsValid(con)) {
    cli::cli_abort("Invalid DuckDB connection.")
  }

  if (is.null(table_name) || !is.character(table_name) || length(table_name) != 1) {
    cli::cli_abort("{.arg table_name} must be a single table name.")
  }

  DBI::dbExecute(con, glue::glue("CREATE SCHEMA IF NOT EXISTS {schema}"))

  DBI::dbExecute(con, glue::glue("
    CREATE TABLE IF NOT EXISTS {schema}.table_registry (
      table_name VARCHAR,
      source_type VARCHAR,
      geom_type VARCHAR,
      crs INTEGER,
      row_count INTEGER,
      created_at TIMESTAMP
    )
  "))

  geom_type <- unique(as.character(sf::st_geometry_type(x)))
  geom_type <- paste(geom_type, collapse = ",")

  crs_epsg <- sf::st_crs(x)$epsg

  if (is.null(crs_epsg) || is.na(crs_epsg)) {
    crs_sql <- "NULL"
  } else {
    crs_sql <- as.character(crs_epsg)
  }

  x_out <- x
  x_out[[geom_wkt_col]] <- sf::st_as_text(sf::st_geometry(x_out))
  x_out <- sf::st_drop_geometry(x_out)

  if (overwrite && DBI::dbExistsTable(con, DBI::Id(schema = schema, table = table_name))) {
    DBI::dbRemoveTable(con, DBI::Id(schema = schema, table = table_name))

    DBI::dbExecute(
      con,
      glue::glue("
        DELETE FROM {schema}.table_registry
        WHERE table_name = '{table_name}'
      ")
    )
  }

  DBI::dbWriteTable(
    conn = con,
    name = DBI::Id(schema = schema, table = table_name),
    value = x_out,
    overwrite = overwrite
  )

  DBI::dbExecute(
    con,
    glue::glue("
      INSERT INTO {schema}.table_registry (
        table_name,
        source_type,
        geom_type,
        crs,
        row_count,
        created_at
      )
      VALUES (
        '{table_name}',
        '{source_type}',
        '{geom_type}',
        {crs_sql},
        {nrow(x_out)},
        CURRENT_TIMESTAMP
      )
    ")
  )

  if (!quiet) {
    cli::cli_alert_success("DuckDB table written: {schema}.{table_name}")
    cli::cli_text("Rows: {nrow(x_out)}")
    cli::cli_text("Geometry WKT column: {geom_wkt_col}")
    cli::cli_text("CRS: {ifelse(crs_sql == 'NULL', 'NA', crs_sql)}")
    cli::cli_text("Geometry type: {geom_type}")
  }

  invisible(paste0(schema, ".", table_name))
}


# 02 | Read sf from DuckDB -----------------------------------------------


#' Read sf object from DuckDB using WKT geometry storage
#'
#' @param con DuckDB connection.
#' @param table_name Name of table to read.
#' @param schema DuckDB schema. Defaults to `"spatial"`.
#' @param crs Coordinate reference system to assign to the output sf object.
#' @param geom_wkt_col Name of the WKT geometry column in DuckDB.
#' @param geom_col Name of the active sf geometry column in the output.
#' @param quiet Logical. If `TRUE`, suppress status messages.
#'
#' @return An sf object.
#' @export
read_sf_from_duckdb <- function(con,
                                table_name,
                                schema = "spatial",
                                crs = NULL,
                                geom_wkt_col = "geom_wkt",
                                geom_col = "geom",
                                quiet = FALSE) {

  if (!DBI::dbIsValid(con)) {
    cli::cli_abort("Invalid DuckDB connection.")
  }

  if (!DBI::dbExistsTable(con, DBI::Id(schema = schema, table = table_name))) {
    cli::cli_abort("Table not found: {schema}.{table_name}")
  }

  df <- DBI::dbReadTable(
    conn = con,
    name = DBI::Id(schema = schema, table = table_name)
  )

  if (!(geom_wkt_col %in% names(df))) {
    cli::cli_abort("WKT geometry column not found: {geom_wkt_col}")
  }

  if (is.null(crs)) {
    has_registry <- DBI::dbExistsTable(
      con,
      DBI::Id(schema = schema, table = "table_registry")
    )

    if (has_registry) {
      crs_lookup <- DBI::dbGetQuery(
        con,
        glue::glue("
          SELECT crs
          FROM {schema}.table_registry
          WHERE table_name = '{table_name}'
          ORDER BY created_at DESC
          LIMIT 1
        ")
      )

      if (nrow(crs_lookup) == 1 && !is.na(crs_lookup$crs[1])) {
        crs <- crs_lookup$crs[1]
      }
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
    cli::cli_alert_success("Read sf from DuckDB: {schema}.{table_name}")
  }

  out
}