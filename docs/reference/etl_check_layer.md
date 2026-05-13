# Inspect a spatial layer before loading

Inspect a spatial layer before loading

## Usage

``` r
etl_check_layer(
  dsn,
  layer,
  format = c("gdb", "shapefile", "gpkg"),
  sample_n = 100
)
```

## Arguments

- dsn:

  Path to GDB, shapefile folder, or GeoPackage.

- layer:

  Layer name.

- format:

  One of `"gdb"`, `"shapefile"`, or `"gpkg"`.

- sample_n:

  Number of rows to sample. Defaults to 100.

## Value

A list with summary and sample sf object.
