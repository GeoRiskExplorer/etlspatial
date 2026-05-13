# Package index

## Main ETL workflow

- [`duck_io_esri()`](https://georiskexplorer.github.io/etlspatial/reference/duck_io_esri.md)
  : End-to-end spatial ETL (ESRI ↔ DuckDB)
- [`read_esri_layer()`](https://georiskexplorer.github.io/etlspatial/reference/read_esri_layer.md)
  : Read a spatial layer as sf
- [`write_esri_layer()`](https://georiskexplorer.github.io/etlspatial/reference/write_esri_layer.md)
  : Write an sf object to a spatial file format
- [`write_sf_to_duckdb()`](https://georiskexplorer.github.io/etlspatial/reference/write_sf_to_duckdb.md)
  : Write sf object to DuckDB using WKT geometry storage
- [`read_sf_from_duckdb()`](https://georiskexplorer.github.io/etlspatial/reference/read_sf_from_duckdb.md)
  : Read sf object from DuckDB using WKT geometry storage

## DuckDB helpers

- [`etl_duckdb_registry()`](https://georiskexplorer.github.io/etlspatial/reference/etl_duckdb_registry.md)
  : Inspect the etlspatial DuckDB registry
- [`etl_duckdb_drop_tables()`](https://georiskexplorer.github.io/etlspatial/reference/etl_duckdb_drop_tables.md)
  : Drop tables from DuckDB and remove them from the registry
- [`etl_table_exists()`](https://georiskexplorer.github.io/etlspatial/reference/etl_table_exists.md)
  : Check if a DuckDB table exists

## QA and validation

- [`qa_spatial_summary()`](https://georiskexplorer.github.io/etlspatial/reference/qa_spatial_summary.md)
  : Spatial QA summary
- [`qa_spatial_plot()`](https://georiskexplorer.github.io/etlspatial/reference/qa_spatial_plot.md)
  : Quick spatial QA plot
- [`etl_check_layer()`](https://georiskexplorer.github.io/etlspatial/reference/etl_check_layer.md)
  : Inspect a spatial layer before loading

## Registry checks

- [`etl_registry_check_duplicates()`](https://georiskexplorer.github.io/etlspatial/reference/etl_registry_check_duplicates.md)
  : Check for duplicate registry entries
- [`etl_registry_similarity_check()`](https://georiskexplorer.github.io/etlspatial/reference/etl_registry_similarity_check.md)
  : Check for likely similar DuckDB spatial tables

## Format helpers

- [`guess_spatial_format()`](https://georiskexplorer.github.io/etlspatial/reference/guess_spatial_format.md)
  : Guess spatial file format
- [`etl_list_gdb_layers()`](https://georiskexplorer.github.io/etlspatial/reference/etl_list_gdb_layers.md)
  : List layers in a File Geodatabase
