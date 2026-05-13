# Read sf object from DuckDB using WKT geometry storage

Read sf object from DuckDB using WKT geometry storage

## Usage

``` r
read_sf_from_duckdb(
  con = NULL,
  db_path = NULL,
  table_name,
  schema = "spatial",
  crs = NULL,
  geom_wkt_col = "geom_wkt",
  geom_col = "geom",
  quiet = FALSE
)
```

## Arguments

- con:

  Optional DuckDB connection.

- db_path:

  Optional path to a DuckDB database file. If supplied and `con` is
  `NULL`, a connection is created automatically.

- table_name:

  Name of table to read.

- schema:

  DuckDB schema. Defaults to `"spatial"`.

- crs:

  Coordinate reference system to assign to the output sf object.

- geom_wkt_col:

  Name of the WKT geometry column in DuckDB.

- geom_col:

  Name of the active sf geometry column in the output.

- quiet:

  Logical. If `TRUE`, suppress status messages.

## Value

An sf object.
