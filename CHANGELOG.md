# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/), and this project adheres to
[Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [2.0.1] - 2024-07-14

### Removed

-   Removed an outdated sentence in the documentation comment of `gleamyshell/home_directory`.

## [2.0.0] - 2024-07-12

### Changed

-   **(breaking)** `gleamyshell/execute` doesn't treat non-zero exit codes as errors any longer.
-   **(breaking)** Made `gleamyshell/which` return a `Result` instead of an `Option`.
-   **(breaking)** Made `gleamyshell/env` return a `Result` instead of an `Option`.
-   **(breaking)** Made `gleamyshell/home_directory` return a `Result` instead of an `Option`.
-   **(breaking)** Made `gleamyshell/cwd` return a `Result` instead of an `Option`.

### Removed

-   **(breaking)** Removed `gleamyshell/set_env` due to limitations of the APIs of Erlang and Node.js.
-   **(breaking)** Removed `gleamyshell/unset_env`.

## [1.1.0] - 2024-06-06

### Added

-   Introduced official support for [Bun](https://bun.sh/).

## [1.0.0] - 2024-06-04

### Added

-   Added `gleamyshell/unset_env` to unset an environment variable.
-   Added `gleamyshell/set_env` to set an environment variable.

## [0.5.0] - 2024-06-01

### Removed

-   Removed Elixir as a dependency.
-   **(breaking)** Removed `gleamyshell/execute_in` in favor of `gleamyshell/execute`.

## [0.4.0] - 2024-05-31

### Added

-   Added `gleamyshell/env` to get the value of an environment variable.
-   Added `gleamyshell/which` to get the path of an executable.

## [0.3.1] - 2024-05-29

### Fixed

-   Made `gleamyshell/cwd_ffi` private again.

## [0.3.0] - 2024-05-29

### Added

-   Added `gleamyshell/home_directory` to get the path of the user's home directory.

### Fixed

-   **(breaking)** `gleamyshell/cwd` now returns a consistent output across all supported targets.
-   Removed the freezing of the standard library version. Discovered and fixed thanks to
    [@darky](https://github.com/darky).

## [0.2.0] - 2024-05-28

### Added

-   Added `gleamyshell/os` to get information about the operating system.
-   **(breaking)** Defined the `gleamyshell/OsFamily` and `gleamyshell/Os` types, and renamed a constructor of the
    `gleamyshell/AbortReason` type.

## [0.1.0] - 2024-05-26

### Added

-   Added `gleamyshell/execute_in` to run a command in a specific working directory.
-   Added `gleamyshell/cwd` to get the path of the current working directory.
-   Added `gleamyshell/execute` to run a command.
-   Defined the `gleamyshell/CommandError` and `gleamyshell/AbortReason` types.

[unreleased]: https://github.com/patrik-kuehl/gleamyshell/compare/v2.0.1...HEAD
[2.0.1]: https://github.com/patrik-kuehl/gleamyshell/compare/v2.0.0...v2.0.1
[2.0.0]: https://github.com/patrik-kuehl/gleamyshell/compare/v1.1.0...v2.0.0
[1.1.0]: https://github.com/patrik-kuehl/gleamyshell/compare/v1.0.0...v1.1.0
[1.0.0]: https://github.com/patrik-kuehl/gleamyshell/compare/v0.5.0...v1.0.0
[0.5.0]: https://github.com/patrik-kuehl/gleamyshell/compare/v0.4.0...v0.5.0
[0.4.0]: https://github.com/patrik-kuehl/gleamyshell/compare/v0.3.1...v0.4.0
[0.3.1]: https://github.com/patrik-kuehl/gleamyshell/compare/v0.3.0...v0.3.1
[0.3.0]: https://github.com/patrik-kuehl/gleamyshell/compare/v0.2.0...v0.3.0
[0.2.0]: https://github.com/patrik-kuehl/gleamyshell/compare/v0.1.0...v0.2.0
[0.1.0]: https://github.com/patrik-kuehl/gleamyshell/releases/tag/v0.1.0
