# GleamyShell

GleamyShell is a cross-platform Gleam library for executing shell commands that supports multiple targets (Erlang, Deno,
and Node.js).

## When to use GleamyShell?

GleamyShell provides the ability to execute shell commands on multiple targets. While this might sound amazing,
supporting targets with fundamentally different concurrency models shrinks the common ground significantly.

In order to keep the public API homogenous across different targets, GleamyShell only provides synchronous bindings.

You should use GleamyShell if

-   you need or want to support multiple targets _and/or_
-   synchronous shell command execution is not a concern.

## Changelog

Take a look at the [changelog](https://github.com/patrik-kuehl/gleamyshell/blob/main/CHANGELOG.md) to get an overview of
each release and its changes.

## Contribution Guidelines

More information can be found [here](https://github.com/patrik-kuehl/gleamyshell/blob/main/CONTRIBUTING.md).

## License

GleamyShell is licensed under the [MIT license](https://github.com/patrik-kuehl/gleamyshell/blob/main/LICENSE.md).
