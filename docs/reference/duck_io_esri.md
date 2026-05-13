# End-to-end spatial ETL (ESRI ↔ DuckDB)

Reads a spatial dataset, applies optional transformations, and writes to
DuckDB or spatial output formats.

## Usage

``` r
duck_io_esri(
  source,
  source_layer,
  source_type = NULL,
  target,
  target_type = c("duckdb", "gdb", "shapefile", "gpkg"),
  target_layer,
  duckdb_path = NULL,
  schema = "spatial",
  crs = NULL,
  validate_geom = TRUE,
  repair_geom = TRUE,
  qa = TRUE,
  qa_plot = FALSE,
  quiet = FALSE,
  return_data_only = FALSE
)
```

## Arguments

- source:

  Path to input dataset (GDB, shapefile, or GeoPackage).

- source_layer:

  Layer name.

- source_type:

  Optional format override (`"gdb"`, `"shapefile"`, `"gpkg"`).

- target:

  Output target. Either DuckDB path or spatial file path.

- target_type:

  One of `"duckdb"`, `"gdb"`, `"shapefile"`, `"gpkg"`.

- target_layer:

  Output layer/table name.

- duckdb_path:

  Path to DuckDB database (required if target_type = "duckdb").

- schema:

  DuckDB schema. Defaults to `"spatial"`.

- crs:

  Optional CRS override.

- validate_geom:

  Logical. Validate geometry.

- repair_geom:

  Logical. Repair geometry.

- qa:

  Logical. Run QA summary.

- qa_plot:

  Logical. Produce QA plot.

- quiet:

  Logical. Suppress console output.

- return_data_only:

  Logical. If `TRUE`, return the processed sf object instead of writing
  output.

## Value

Invisibly returns processed sf object (if `return_data_only = TRUE`).
