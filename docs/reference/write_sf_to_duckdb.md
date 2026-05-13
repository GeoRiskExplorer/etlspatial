# Write sf object to DuckDB using WKT geometry storage

Write sf object to DuckDB using WKT geometry storage

## Usage

``` r
write_sf_to_duckdb(
  x = NULL,
  sf_obj = NULL,
  con = NULL,
  db_path = NULL,
  table_name,
  schema = "spatial",
  geom_wkt_col = "geom_wkt",
  source_type = "sf",
  overwrite = TRUE,
  quiet = FALSE
)
```

## Arguments

- x:

  An sf object.

- sf_obj:

  Optional alias for `x`.

- con:

  Optional DuckDB connection.

- db_path:

  Optional path to a DuckDB database file. If supplied and `con` is
  `NULL`, a connection is created automatically.

- table_name:

  Name of output table.

- schema:

  DuckDB schema. Defaults to `"spatial"`.

- geom_wkt_col:

  Name of WKT geometry column.

- source_type:

  Source type recorded in registry.

- overwrite:

  Logical. If `TRUE`, overwrite an existing table.

- quiet:

  Logical. If `TRUE`, suppress status messages.

## Value

Invisibly returns the written table name.
