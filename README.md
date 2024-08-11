[![Package Version](https://img.shields.io/hexpm/v/gleamyshell)](https://hex.pm/packages/gleamyshell)
[![Hex Docs](https://img.shields.io/badge/hex-docs-ffaff3)](https://hexdocs.pm/gleamyshell)
![Erlang-compatible](https://img.shields.io/badge/target-erlang-a2003e)
![JavaScript-compatible](https://img.shields.io/badge/target-javascript-f1e05a)

# GleamyShell 🐚

GleamyShell is a cross-platform Gleam library for executing shell commands that supports all non-browser targets
(Erlang, Bun, Deno, and Node.js).

## Maintenance Notice 🐚

As of the 11th August, 2024, I won't be maintaining this project any longer.

I don't invest time in Gleam anymore, as I encountered too many breaking changes within minor version bumps, and too
many packages on Hex, which have been released as a first major version (1.0.0) without any battle-testing first, thus
being prone to breaking API changes or unexpected behavior.

I wish Gleam all the best, but I revert to other (enterprise-y) languages I'm already used to.

If you depend on GleamyShell and/or want to maintain it, feel free to get in touch with me. I'd be willing to transfer
the ownership of this repository and the package on Hex. No need to create a fork :v:

## When to use GleamyShell? 🐚

GleamyShell provides the ability to execute shell commands on multiple targets. While this might sound amazing,
supporting targets with fundamentally different concurrency models and APIs shrinks the common ground significantly.

In order to keep the public API homogenous across different targets, GleamyShell only provides synchronous bindings and
a minimal API with common functionalities supported by those targets.

You should use GleamyShell if

-   you need or want to support multiple targets _and/or_
-   synchronous shell command execution is not a concern, _and most importantly_,
-   you don't have special use cases that GleamyShell's API cannot serve\*.

\* Feel free to [open an issue](https://github.com/patrik-kuehl/gleamyshell/issues) on GitHub to discuss your feature
request. GleamyShell aims to implement features that can provide a similar, or ideally the same behavior on all
supported targets. Yours might be one of them.

The main workhorse of GleamyShell is its `execute` function. The remaining functions are quality-of-life features so
users of this library don't need to reach for further dependencies that often.

## Usage 🐚

### Getting the Current Username 🐚

```gleam
case gleamyshell.execute("whoami", in: ".", args: []) {
  Ok(CommandOutput(0, username)) ->
    io.println("Hello there, " <> string.trim(username) <> "!")
  Ok(CommandOutput(exit_code, output)) ->
    io.println(
      "Whoops!\nError ("
      <> int.to_string(exit_code)
      <> "): "
      <> string.trim(output),
    )
  Error(reason) -> io.println("Fatal: " <> reason)
}
```

### Getting the Current Working Directory 🐚

```gleam
case gleamyshell.cwd() {
  Ok(working_directory) ->
    io.println("Current working directory: " <> working_directory)
  Error(_) ->
    io.println("Couldn't detect the current working directory.")
}
```

### Doing OS-specific Stuff 🐚

```gleam
case gleamyshell.os() {
  Windows -> io.println("Doing stuff on Windows.")
  Unix(Darwin) -> io.println("Doing stuff on macOS.")
  Unix(_) -> io.println("Doing stuff on a Unix(-like) system.")
}
```

## Upgrading to Version 2 🐚

The changelog covers the breaking changes, and the API documentation has been updated accordingly.

In a nutshell:

-   `gleamyshell/set_env` and `gleamyshell/unset_env` have been removed due to the limitations of the APIs of Erlang and
    Node.js (e.g., referenced variables couldn't be resolved as one might expect it to happen when using the shell
    directly), so if you need to set and/or unset environment variables, do it in a platform-specific way within a
    script file instead
-   all functions, which returned an `Option` now return a `Result` to provide an API that is adhering to Gleam's
    guidelines (thus becoming more idiomatic) to prefer `Result` over `Option` for failible functions
-   `gleamyshell/execute` doesn't treat non-zero exit codes as errors any longer because for GleamyShell, a command that
    could exit, no matter the exit code, did complete successfully

## Changelog 🐚

Take a look at the [changelog](https://github.com/patrik-kuehl/gleamyshell/blob/main/CHANGELOG.md) to get an overview of
each release and its changes.

## Contribution Guidelines 🐚

More information can be found [here](https://github.com/patrik-kuehl/gleamyshell/blob/main/CONTRIBUTING.md).

## License 🐚

GleamyShell is licensed under the [MIT license](https://github.com/patrik-kuehl/gleamyshell/blob/main/LICENSE.md).
