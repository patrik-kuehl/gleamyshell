# Changelog

All notable changes to this project will be documented in this file.

This project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## 0.3.1 - 2024-05-29

### Bug Fixes

-   Made the internal `cwd_ffi` function private again.

## 0.3.0 - 2024-05-29

### Features

-   Implemented the `home_directory` function.

### Bug Fixes

-   [**breaking**] The `cwd` function now provides a consistent output across all supported targets.
-   Removed the freezing of the standard library version for consumers of the library. Discovered and fixed thanks to
    the GitHub user [darky](https://github.com/darky).

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
