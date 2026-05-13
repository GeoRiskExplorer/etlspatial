# etlspatial

`etlspatial` is an R package for robust, repeatable, and scalable spatial ETL workflows.

The package focuses on reliable movement of spatial data between GIS formats, analytical databases, and R spatial environments while preserving geometry integrity, CRS consistency, and reproducible processing workflows.

Current capabilities include:

- Read/write workflows for DuckDB and spatial formats
- Support for file geodatabases, GeoPackages, and shapefiles
- Geometry validation and normalisation for processing contexts
- CRS checking and transformation workflows
- WKT-based geometry storage and reconstruction
- QA summaries and lightweight validation reporting
- Bounding box filtering and selective field import
- ArcGIS Pro integration using `arcgisbinding`
- Reproducible `sf`-based ETL pipelines

Planned ecosystem expansion includes:

- Parquet support for scalable analytical workflows
- `qs2` support for fast R-native caching and persistence
- Extended cross-format round-trip testing
- Enhanced documentation, examples, and workflow vignettes

The package is designed for analysts, GIS practitioners, and spatial data scientists working with operational or large spatial datasets in reproducible R workflows.

External ESRI test datasets are not included in this repository. The package is designed to operate with user-provided spatial data sources.

---

## Installation

Install the development version from GitHub:

```r
# install.packages("pak")

pak::pak("GeoRiskExplorer/etlspatial")
```