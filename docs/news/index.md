# Changelog

## etlspatial 0.0.0.9000

### Package infrastructure

- Added custom pkgdown configuration.
- Added grouped reference sections.
- Added repeatable testing/check workflow.
- Improved package structure and cleanup rules.

### DuckDB workflows

- Added DuckDB read/write support for `sf` objects.
- Added `db_path` support for easier DuckDB workflows.
- Added table registry support.
- Added optional geometry repair on DuckDB readback.
- Added tests for DuckDB round-trips, file creation, registry integrity,
  and readback repair.

### Additional storage formats

- Added `qs2` support for fast R-native `sf` persistence.
- Added Parquet support using WKT geometry storage.
- Added DuckDB query test for Parquet outputs.

### Documentation

- Improved README structure.
- Added installation instructions.
- Added Quick Start example.
- Added DuckDB installation note.
