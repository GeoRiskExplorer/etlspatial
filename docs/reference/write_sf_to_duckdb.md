# Write sf object to DuckDB using WKT geometry storage

Write sf object to DuckDB using WKT geometry storage

## Usage

``` r
write_sf_to_duckdb(
  x,
  con,
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

- con:

  DuckDB connection.

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
