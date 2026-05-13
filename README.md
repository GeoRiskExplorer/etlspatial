# etlspatial

`etlspatial` is an R package for robust, repeatable, and scalable spatial ETL workflows.

It helps move spatial data between GIS formats, DuckDB, and R `sf` objects while keeping geometry handling, CRS checks, and QA steps visible and repeatable.

## What it does

Current capabilities include:

- Read/write workflows for DuckDB and spatial formats
- Support for file geodatabases, GeoPackages, and shapefiles
- WKT-based geometry storage and reconstruction
- Geometry validation and normalisation for the current processing context
- CRS checking and transformation workflows
- QA summaries and lightweight validation plots
- Bounding box filtering and selective field import
- ArcGIS Pro integration using `arcgisbinding`
- Reproducible `sf`-based ETL pipelines

## Planned expansion

Planned ecosystem expansion includes:

- Parquet support for scalable analytical workflows
- `qs2` support for fast R-native caching and persistence
- Extended cross-format round-trip testing
- Enhanced documentation, examples, and workflow vignettes

## Installation

Install the development version from GitHub:

```r
# install.packages("pak")

pak::pak("GeoRiskExplorer/etlspatial")
```

DuckDB workflows require the `duckdb` R package:

```r
install.packages("duckdb")
```

## Quick Start

```r
library(etlspatial)

# ---------------------------------------------------------
# Demo dataset
# ---------------------------------------------------------

demo_gpkg <- system.file(
  "extdata",
  "abs_sa4_vic_demo.gpkg",
  package = "etlspatial"
)

# ---------------------------------------------------------
# Read spatial layer
# ---------------------------------------------------------

vic_sa4 <- read_esri_layer(
  dsn = demo_gpkg,
  layer = "abs_sa4_vic_demo"
)

# ---------------------------------------------------------
# QA summary and plot
# ---------------------------------------------------------

qa_spatial_summary(vic_sa4)
qa_spatial_plot(vic_sa4)

# ---------------------------------------------------------
# Write to DuckDB using a database path
# ---------------------------------------------------------

duckdb_path <- tempfile(fileext = ".duckdb")

write_sf_to_duckdb(
  sf_obj = vic_sa4,
  db_path = duckdb_path,
  table_name = "vic_sa4"
)

# ---------------------------------------------------------
# Read back from DuckDB as sf
# ---------------------------------------------------------

vic_sa4_duck <- read_sf_from_duckdb(
  db_path = duckdb_path,
  table_name = "vic_sa4"
)

print(vic_sa4_duck)
```

## DuckDB behaviour

When writing to a new `.duckdb` file path, DuckDB will create the database file if it does not already exist.

When reading, `etlspatial` expects the DuckDB file and requested table to already exist. This avoids accidentally creating an empty database when the intention was to read an existing one.

## External data

External ESRI test datasets are not included in this repository. The package is designed to operate with user-provided spatial data sources.