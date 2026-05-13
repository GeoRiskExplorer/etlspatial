# Check for likely similar DuckDB spatial tables

Flags tables that share row count, CRS, and geometry type.

## Usage

``` r
etl_registry_similarity_check(duckdb_path, schema = "spatial", quiet = FALSE)
```

## Arguments

- duckdb_path:

  Path to DuckDB database.

- schema:

  DuckDB schema containing `table_registry`.

- quiet:

  Logical. If `TRUE`, suppress status messages.

## Value

A tibble of potentially similar tables.
