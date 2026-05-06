# etlspatial

`etlspatial` is a personal R package for robust, repeatable spatial ETL workflows.

Initial focus:

- Read/write between DuckDB and ESRI formats
- Support shapefiles and file geodatabases
- Geometry validation and repair
- CRS checks and transformation
- QA summaries and optional QA plots
- Reduce repeated one-off import/export scripts

External ESRI test files are not included in this repository. 

The package is designed to work with user-provided spatial data sources.
