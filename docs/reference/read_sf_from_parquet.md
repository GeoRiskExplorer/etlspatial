# Read sf object from Parquet using WKT geometry storage

Read sf object from Parquet using WKT geometry storage

## Usage

``` r
read_sf_from_parquet(
  path,
  geom_wkt_col = "geom_wkt",
  crs_col = "crs_epsg",
  crs = NULL,
  geom_col = "geom",
  quiet = FALSE
)
```

## Arguments

- path:

  Input Parquet file path.

- geom_wkt_col:

  Name of WKT geometry column.

- crs_col:

  Name of CRS EPSG column.

- crs:

  Optional CRS override.

- geom_col:

  Name of active sf geometry column in output.

- quiet:

  Logical. If `TRUE`, suppress status messages.

## Value

An sf object.
