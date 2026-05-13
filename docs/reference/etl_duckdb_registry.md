# Inspect the etlspatial DuckDB registry

Inspect the etlspatial DuckDB registry

## Usage

``` r
etl_duckdb_registry(
  duckdb_path,
  schema = "spatial",
  show_path = FALSE,
  quiet = FALSE
)
```

## Arguments

- duckdb_path:

  Path to DuckDB database.

- schema:

  Schema containing registry table. Defaults to `"spatial"`.

- show_path:

  Logical. If `TRUE`, print the full DuckDB path. If `FALSE`, only the
  file name is printed.

- quiet:

  Logical. If `TRUE`, suppress status messages.

## Value

A tibble of registered spatial tables.
