# Read a spatial layer as sf

Reads a spatial layer from a file geodatabase, shapefile, or GeoPackage.

## Usage

``` r
read_esri_layer(dsn, layer, format = NULL, quiet = FALSE)
```

## Arguments

- dsn:

  Path to a file geodatabase, shapefile folder, shapefile, or
  GeoPackage.

- layer:

  Layer name.

- format:

  Optional. One of `"gdb"`, `"shapefile"`, or `"gpkg"`. If `NULL`, the
  format is inferred from `dsn`.

- quiet:

  Logical. If `TRUE`, suppress status messages.

## Value

An sf object.
