# Write sf object to Parquet using WKT geometry storage

Write sf object to Parquet using WKT geometry storage

## Usage

``` r
write_sf_to_parquet(
  x = NULL,
  sf_obj = NULL,
  path,
  geom_wkt_col = "geom_wkt",
  crs_col = "crs_epsg",
  overwrite = TRUE,
  compression = "snappy",
  quiet = FALSE
)
```

## Arguments

- x:

  An sf object.

- sf_obj:

  Optional alias for `x`.

- path:

  Output Parquet file path.

- geom_wkt_col:

  Name of WKT geometry column.

- crs_col:

  Name of CRS EPSG column.

- overwrite:

  Logical. If `TRUE`, overwrite an existing file.

- compression:

  Parquet compression codec. Defaults to `"snappy"`.

- quiet:

  Logical. If `TRUE`, suppress status messages.

## Value

Invisibly returns the output path.
