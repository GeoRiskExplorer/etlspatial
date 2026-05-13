# Write an sf object to a spatial file format

Writes an sf object to a file geodatabase, shapefile, or GeoPackage.

## Usage

``` r
write_esri_layer(
  x,
  dsn,
  layer,
  format = NULL,
  overwrite = TRUE,
  clean_names = TRUE,
  repair_geom = TRUE,
  quiet = FALSE
)
```

## Arguments

- x:

  An sf object.

- dsn:

  Output file geodatabase path, shapefile folder, or GeoPackage path.

- layer:

  Output layer name.

- format:

  Optional. One of `"gdb"`, `"shapefile"`, or `"gpkg"`. If `NULL`, the
  format is inferred from `dsn`.

- overwrite:

  Overwrite existing layer or files.

- clean_names:

  Clean field names before writing.

- repair_geom:

  Validate and normalise geometry for the target/current processing
  context.

- quiet:

  Logical. If `TRUE`, suppress status messages.

## Value

Invisibly returns output path or layer reference.
