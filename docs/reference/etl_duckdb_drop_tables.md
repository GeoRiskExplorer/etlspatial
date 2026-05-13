# Drop tables from DuckDB and remove them from the registry

Drop tables from DuckDB and remove them from the registry

## Usage

``` r
etl_duckdb_drop_tables(duckdb_path, tables, schema = "spatial", quiet = FALSE)
```

## Arguments

- duckdb_path:

  Path to DuckDB database.

- tables:

  Character vector of table names to drop.

- schema:

  Schema name. Defaults to `"spatial"`.

- quiet:

  Logical. If `TRUE`, suppress status messages.

## Value

Invisibly returns dropped table names.
