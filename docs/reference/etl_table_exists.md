# Check if a DuckDB table exists

Check if a DuckDB table exists

## Usage

``` r
etl_table_exists(duckdb_path, table_name, schema = "spatial", quiet = FALSE)
```

## Arguments

- duckdb_path:

  Path to DuckDB database.

- table_name:

  Table name to check.

- schema:

  DuckDB schema. Defaults to `"spatial"`.

- quiet:

  Logical. If `TRUE`, suppress status messages.

## Value

Logical. `TRUE` if table exists, otherwise `FALSE`.
