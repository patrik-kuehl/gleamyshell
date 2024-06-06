# Changelog

All notable changes to this project will be documented in this file.

This project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## 1.1.0 - 2024-06-06

### Features

-   Introduced official support for [Bun](https://bun.sh/).

## 1.0.0 - 2024-06-04

### Features

-   Implemented the `unset_env` function.
-   Implemented the `set_env` function.

## 0.5.0 - 2024-06-01

**Side note**: The existing API of GleamyShell is now locked as a preparation for the upcoming 1.0.0 release.

### Refactor

-   [**breaking**] Finalized the API for the `execute` function.

### Miscellaneous Tasks

-   Removed Elixir as a dependency.
-   [**breaking**] The `execute_in` function has been removed in favor of the `execute` function.

## 0.4.0 - 2024-05-31

### Features

-   Implemented the `env` function.
-   Implemented the `which` function.

## 0.3.1 - 2024-05-29

### Bug Fixes

-   Made the internal `cwd_ffi` function private again.

## 0.3.0 - 2024-05-29

### Features

-   Implemented the `home_directory` function.

### Bug Fixes

-   [**breaking**] The `cwd` function now provides a consistent output across all supported targets.
-   Removed the freezing of the standard library version for consumers of the library. Discovered and fixed thanks to
    [@darky](https://github.com/darky).

## 0.2.0 - 2024-05-28

### Features

-   Implemented the `os` function.
-   [**breaking**] Defined the `OsFamily` and `Os` types, and renamed a constructor of the `AbortReason` type.

## 0.1.0 - 2024-05-26

### Features

-   Implemented the `execute_in` function.
-   Implemented the `cwd` function.
-   Implemented the `execute` function.
-   Defined the `CommandError` and `AbortReason` types.

<!-- scaffolded by git-cliff -->
