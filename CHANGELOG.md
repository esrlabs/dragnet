# Changelog
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

Please mark backwards incompatible changes with an exclamation mark at the start.

## [Unreleased]

### Fixed
- Dragnet no longer crashes when generating an HTML report for a repository
  hosted on Github.

## [5.3.0] - 2024-12-03

### Added
- The JSON export now includes the path to the MTR files.

### Changed
- The `description` field will now be rendered as Markdown in the HTML report.

## [5.2.1] - 2024-11-13

### Fixed
- Made the date/time format used for the `started_at` and `finished_at`
  attributes in the exported JSON files stable.

## [5.2.0] - 2024-04-16

### Added
- The JSON file produced when the `-e` CLI switch is given now includes:
  - The `started_at`, `finished_at` and `runtime` attributes under the
    `verification_result` structure.
  - A copy of the `started_at` and `finished_at` attributes directly in each of
    the exported objects (This is being added temporarily for
    backwards-compatibility reasons and will be removed later).

## [5.1.2] - 2023-12-11

### Fixed
- Fixed the rendering of array-type Test Record IDs in the HTML report. They are
  no longer directly rendered with the extra characters added by Ruby's default
  `#to_s` method.
- Fixed a `NoMethodError` that appeared after the release of ActiveSupport 7.1.

## [5.1.1] - 2023-07-14

### Fixed
- Fixed an issue that caused the validation to fail when the listed files or
  glob patterns had a `/` at the beginning.

## [5.1.0] - 2023-07-13

### Added
- The `Explorer` class will now log all the found MTR files.

## [5.0.1] - 2023-06-05

### Fixed
- Fixed a bug where the validated and transformed meta-data did not get assigned
  to the TestRecord. This, in turn, caused issues when rendering the HTML report
  since it assumes that these attributes will be arrays.

## [5.0.0] - 2023-05-26

### Changed
- ! Updated `activesupport` from `~> 6` to `~> 7`
- ! Set the minimum Ruby version for the project to `2.7.0`

## [4.0.0] - 2023-05-24

### Changed
- The "Tester name" attribute will only be visible in the HTML report when the
  MTR has a value in the `name` field.
- The `name` attribute of the MTRs will now be validated, only strings and
  arrays of strings are allowed now.

### Added
- Added the `test_method` and `tc_derivation_method` fields to the JSON and
  HTML exports.
- Added the `MetaDataFieldValidator` class.
- Added the `test_method` and `tc_derivation_method` attributes to the
  `TestRecord` class.
- Added validation for the `test_method` and `tc_derivation_method` attributes
  of the MTRs, they can only have strings or arrays of strings.

## [3.0.0] - 2023-04-05

### Added
- Added the `Exporters::IDGenerator` class.
- Added the `DescriptionValidator` class.

### Changed
- Changed the `JSONExporter` class. It now makes use of the `IDGenerator` class
  to attach a unique ID to each of the exported MTRs.
- Added validation for the `descriptionn` field of the MTRs. Only Strings are
  allowed now.

## [2.3.0] - 2023-03-31

### Added
- Added a `rescue` to the `software_branches` method in the `HTMLExporter` class
  to keep it from crashing when it cannot read the branches from one of the
  repositories.

## [2.2.0] - 2023-03-08

### Changed
- Moved the `repo_base` and `relative_to_repo` methods from the `HTMLExporter`
  class to the `RepositoryHelper` module.
- Moved the `initialize` method from the `HTMLExporter` class down to the parent
  `Exporter` class.
- Changed the `Exporter` class to allow it to export results to JSON format.

## [2.1.2] - 2023-01-12

### Fixed
- Fixed a bug that caused the verification to pass in multi-repo set-ups even
  when there were changes in the listed files when `.` was given as a path to
  the `check` command.

## [2.1.1] - 2022-12-22

### Fixed
- Fixed an issue with how the file names were being displayed in the HTML report
  when the repository's path was the current working directory: (`.`).

## [2.1.0] - 2022-12-19

### Added
- Added the `--multi-repo` command line switch. This switch tells Dragnet that
  it is running in a multi-repo environment and will prevent it from assuming
  that the given path is a Git repository.
- Dragnet can now recognize and validate MTR files that include the `repos`
  attribute (to reference files from multiple repositories).
- Added the `branches_with` and `branches_with_head` methods to the `Repository`
  class.

## [2.0.0] - 2022-09-13

### Changed
- Updated `activesupport` to version 6.x
- Updated `jay_api` to version 15.x
- Changed the minimum Ruby version requirement for the gem to 2.5.0

## [1.0.0] - 2021-07-02

### Changed
 - Two new entity objects were introduced `Dragnet::TestRecord` and
   `Dragnet::VerificationResult` these will be used instead of the previously
   used Hashes. This allows the logic of validation and value evaluation to be
   centralized.
 - The validation code for the Test Records was moved from
   `Dragnet::Validators::DataValidator` to the
   `Dragnet::Validators::Entities::TestRecordValidator` class and to a series of
   field validation classes inside the `Dragnet::Validators::Fields` module.

### Added
 - Introduced the `Dragnet::Exporter` class which handles exporting the results
   of the verification process to different formats (for the moment only HTML is
   available, via `Dragnet::Exporters::HTMLExporter`)
 - Changed the CLI to receive the `--export` option. (Which can be given
   multiple times).
 - Added the `Repository` class. A thin wrapper around the Git class. It just
   houses some utilitarian methods.

## [0.1.1] - 2021-06-10

### Removed
 - Removed a stray "require 'pry'" from a file.

### Added
 - Added "require 'colorize'" for validator and verifier classes.

## [0.1.0] - 2021-05-27

### Added
 - Basic structure of the gem
 - Added the basic classes for the Gem's CLI
 - Added the `Explorer` class. The class searches for Manual Test Record files
   on a given path with a set of glob patterns.
 - Added the `check` command to the CLI.
 - Implemented the `Validator` class.
 - Added `jay_api` to the development dependencies in order to be able to use
   the `TestDataCollector` class.
 - Adds configuration for the `TestDataCollector` class.
 - Enables the collection of Test Data for releases.
 - Added the `Verifier` class. The class verifies the actual test records and
   checks if there have been any changes since the commit specified in the MTR.
