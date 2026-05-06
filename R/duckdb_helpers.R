# 01 | Inspect DuckDB registry ------------------------------------------


#' Inspect the etlspatial DuckDB registry
#'
#' @param duckdb_path Path to DuckDB database.
#' @param schema Schema containing registry table. Defaults to `"spatial"`.
#' @param show_path Logical. If `TRUE`, print the full DuckDB path. If `FALSE`,
#' only the file name is printed.
#' @param quiet Logical. If `TRUE`, suppress status messages.
#'
#' @return A tibble of registered spatial tables.
#' @export
etl_duckdb_registry <- function(duckdb_path,
                                schema = "spatial",
                                show_path = FALSE,
                                quiet = FALSE) {

  if (is.null(duckdb_path) || !is.character(duckdb_path) || length(duckdb_path) != 1) {
    cli::cli_abort("{.arg duckdb_path} must be a single DuckDB file path.")
  }

  if (!fs::file_exists(duckdb_path)) {
    cli::cli_abort("DuckDB file does not exist: {.path {basename(duckdb_path)}}")
  }

  con <- DBI::dbConnect(
    duckdb::duckdb(),
    dbdir = duckdb_path,
    read_only = TRUE
  )

  on.exit(DBI::dbDisconnect(con, shutdown = TRUE), add = TRUE)

  registry_table <- paste0(schema, ".table_registry")

  has_registry <- DBI::dbExistsTable(
    con,
    DBI::Id(schema = schema, table = "table_registry")
  )

  if (!has_registry) {
    cli::cli_abort("Registry table not found: {registry_table}")
  }

  out <- DBI::dbGetQuery(
    con,
    glue::glue("
      SELECT
        table_name,
        source_type,
        geom_type,
        crs,
        row_count,
        created_at
      FROM {registry_table}
      ORDER BY created_at DESC;
    ")
  )

  if (!quiet) {
    db_label <- if (show_path) duckdb_path else basename(duckdb_path)

    cli::cli_h1("DuckDB spatial registry")
    cli::cli_text("Database: {db_label}")
    cli::cli_text("Registered tables: {nrow(out)}")
  }

  out
}


# 02 | Drop tables from DuckDB + registry --------------------------------


#' Drop tables from DuckDB and remove them from the registry
#'
#' @param duckdb_path Path to DuckDB database.
#' @param tables Character vector of table names to drop.
#' @param schema Schema name. Defaults to `"spatial"`.
#' @param quiet Logical. If `TRUE`, suppress status messages.
#'
#' @return Invisibly returns dropped table names.
#' @export
etl_duckdb_drop_tables <- function(duckdb_path,
                                   tables,
                                   schema = "spatial",
                                   quiet = FALSE) {

  if (is.null(duckdb_path) || !is.character(duckdb_path) || length(duckdb_path) != 1) {
    cli::cli_abort("{.arg duckdb_path} must be a single DuckDB file path.")
  }

  if (is.null(tables) || length(tables) == 0) {
    cli::cli_abort("Provide at least one table name to drop.")
  }

  if (!fs::file_exists(duckdb_path)) {
    cli::cli_abort("DuckDB file does not exist: {.path {basename(duckdb_path)}}")
  }

  con <- DBI::dbConnect(
    duckdb::duckdb(),
    dbdir = duckdb_path,
    read_only = FALSE
  )

  on.exit(DBI::dbDisconnect(con, shutdown = TRUE), add = TRUE)

  dropped <- character()

  for (tbl in tables) {

    full_name <- DBI::Id(schema = schema, table = tbl)

    exists <- DBI::dbExistsTable(con, full_name)

    if (!exists) {
      if (!quiet) {
        cli::cli_alert_warning("Table not found: {schema}.{tbl}")
      }
      next
    }

    DBI::dbExecute(
      con,
      glue::glue("DROP TABLE {schema}.{tbl}")
    )

    registry_exists <- DBI::dbExistsTable(
      con,
      DBI::Id(schema = schema, table = "table_registry")
    )

    if (registry_exists) {
      DBI::dbExecute(
        con,
        glue::glue("
          DELETE FROM {schema}.table_registry
          WHERE table_name = '{tbl}'
        ")
      )
    }

    if (!quiet) {
      cli::cli_alert_success("Dropped: {schema}.{tbl}")
    }

    dropped <- c(dropped, tbl)
  }

  if (!quiet) {
    cli::cli_h1("Drop summary")
    cli::cli_text("Tables dropped: {length(dropped)}")
  }

  invisible(dropped)
}


# 03 | Check whether DuckDB table exists ---------------------------------


#' Check if a DuckDB table exists
#'
#' @param duckdb_path Path to DuckDB database.
#' @param table_name Table name to check.
#' @param schema DuckDB schema. Defaults to `"spatial"`.
#' @param quiet Logical. If `TRUE`, suppress status messages.
#'
#' @return Logical. `TRUE` if table exists, otherwise `FALSE`.
#' @export
etl_table_exists <- function(duckdb_path,
                             table_name,
                             schema = "spatial",
                             quiet = FALSE) {

  if (is.null(duckdb_path) || !is.character(duckdb_path) || length(duckdb_path) != 1) {
    cli::cli_abort("{.arg duckdb_path} must be a single DuckDB file path.")
  }

  if (is.null(table_name) || !is.character(table_name) || length(table_name) != 1) {
    cli::cli_abort("{.arg table_name} must be a single table name.")
  }

  if (!fs::file_exists(duckdb_path)) {
    cli::cli_abort("DuckDB file does not exist: {.path {basename(duckdb_path)}}")
  }

  con <- DBI::dbConnect(
    duckdb::duckdb(),
    dbdir = duckdb_path,
    read_only = TRUE
  )

  on.exit(DBI::dbDisconnect(con, shutdown = TRUE), add = TRUE)

  exists <- DBI::dbExistsTable(
    con,
    DBI::Id(schema = schema, table = table_name)
  )

  if (!quiet) {
    if (exists) {
      cli::cli_alert_success("Table exists: {schema}.{table_name}")
    } else {
      cli::cli_alert_warning("Table not found: {schema}.{table_name}")
    }
  }

  exists
}


# 04 | Check duplicate registry entries ----------------------------------


#' Check for duplicate registry entries
#'
#' @param duckdb_path Path to DuckDB database.
#' @param schema DuckDB schema containing `table_registry`.
#' @param quiet Logical. If `TRUE`, suppress status messages.
#'
#' @return A tibble of duplicate registry entries.
#' @export
etl_registry_check_duplicates <- function(duckdb_path,
                                          schema = "spatial",
                                          quiet = FALSE) {

  registry <- etl_duckdb_registry(
    duckdb_path = duckdb_path,
    schema = schema,
    quiet = TRUE
  )

  dupes <- registry |>
    dplyr::count(table_name, name = "registry_rows") |>
    dplyr::filter(.data$registry_rows > 1) |>
    dplyr::arrange(dplyr::desc(.data$registry_rows), .data$table_name)

  if (!quiet) {
    cli::cli_h1("Registry duplicate check")

    if (nrow(dupes) == 0) {
      cli::cli_alert_success("No duplicate registry entries found.")
    } else {
      cli::cli_alert_warning("Duplicate registry entries found: {nrow(dupes)}")
    }
  }

  dupes
}


# 05 | Check likely similar tables ---------------------------------------


#' Check for likely similar DuckDB spatial tables
#'
#' Flags tables that share row count, CRS, and geometry type.
#'
#' @param duckdb_path Path to DuckDB database.
#' @param schema DuckDB schema containing `table_registry`.
#' @param quiet Logical. If `TRUE`, suppress status messages.
#'
#' @return A tibble of potentially similar tables.
#' @export
etl_registry_similarity_check <- function(duckdb_path,
                                          schema = "spatial",
                                          quiet = FALSE) {

  registry <- etl_duckdb_registry(
    duckdb_path = duckdb_path,
    schema = schema,
    quiet = TRUE
  )

  similar <- registry |>
    dplyr::group_by(.data$row_count, .data$crs, .data$geom_type) |>
    dplyr::filter(dplyr::n() > 1) |>
    dplyr::arrange(.data$row_count, .data$crs, .data$geom_type, .data$table_name) |>
    dplyr::ungroup()

  if (!quiet) {
    cli::cli_h1("Registry similarity check")

    if (nrow(similar) == 0) {
      cli::cli_alert_success("No likely similar tables found.")
    } else {
      cli::cli_alert_warning("Likely similar tables found: {nrow(similar)} rows flagged.")
    }
  }

  similar
}