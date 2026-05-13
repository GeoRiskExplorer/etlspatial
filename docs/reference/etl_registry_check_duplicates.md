# Check for duplicate registry entries

Check for duplicate registry entries

## Usage

``` r
etl_registry_check_duplicates(duckdb_path, schema = "spatial", quiet = FALSE)
```

## Arguments

- duckdb_path:

  Path to DuckDB database.

- schema:

  DuckDB schema containing `table_registry`.

- quiet:

  Logical. If `TRUE`, suppress status messages.

## Value

A tibble of duplicate registry entries.
