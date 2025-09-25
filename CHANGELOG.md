# Changelog
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [2.4.1] - 2025-09-25
### Changed
- [GRD-964](https://jira.oicr.on.ca/browse/GRD-964)
- Update workflow hg38 genome to genecode 44 
- Updated the regression test input file

## [2.4.0] - 2024-12-19
### Added
additionalParameters - optional string for passing any non-exposed parameters to arriba

## [2.3.0] - 2024-06-25
### Added
[GRD-797](https://jira.oicr.on.ca/browse/GRD-797)] - add vidarr labels to outputs (changes to medata only)

## [2.2.0] - 2023-06-22
### Changed
- Moving assembly-specific configuration code into wdl

## [2.1.0] - 2023-02-23
### Changed
- Upgrade to Arriba v2.4
- Use STAR BAM with Chimeric Reads
- Making Regression Tests more robusts by adding md5sum checks to replace line counts

## [2.0.2] - 2020-06-10
### Changed
- Made cosmic parameter optional, it's not available for all organisms

## [2.0.1] - 2020-05-31
### Changed
- Migrate to Vidarr

## [2.0.0] - 2021-02-01
### Changed
- Upgrade to be compatible with STAR 2.7.6a BAM, Upgrade to Arriba 2.0

## [1.0.0] - 2020-05-27
### Added
- Intial import of Arriba 1.0 code
