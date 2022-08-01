# Changelog

## [1.0.1] - 31JUL2022

### Fixed

- Fixed a bug that would create corrupted ICO files if the source images weren't in RGBA8 format. All source files are now properly re-encoded before embedding into the ICO file.