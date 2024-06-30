[![Package Version](https://img.shields.io/hexpm/v/gleamyshell)](https://hex.pm/packages/gleamyshell)
[![Hex Docs](https://img.shields.io/badge/hex-docs-ffaff3)](https://hexdocs.pm/gleamyshell)
![Erlang-compatible](https://img.shields.io/badge/target-erlang-a2003e)
![JavaScript-compatible](https://img.shields.io/badge/target-javascript-f1e05a)

# GleamyShell 🐚

GleamyShell is a cross-platform Gleam library for executing shell commands that supports all non-browser targets
(Erlang, Bun, Deno, and Node.js).

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

### Getting the current username 🐚

```gleam
case gleamyshell.execute("whoami", in: ".", args: []) {
  Ok(username) ->
    io.println("Hello there, " <> string.trim(username) <> "!")
  Error(Failure(output, exit_code)) ->
    io.println(
      "Whoops!\nError ("
      <> int.to_string(exit_code)
      <> "): "
      <> string.trim(output),
    )
  Error(Abort(_)) -> io.println("Something went terribly wrong.")
}
```

### Getting the current working directory 🐚

```gleam
case gleamyshell.cwd() {
  Ok(working_directory) ->
    io.println("Current working directory: " <> working_directory)
  Error(_) ->
    io.println("Couldn't detect the current working directory.")
}
```

### Choosing what to do depending on the operating system 🐚

```gleam
case gleamyshell.os() {
  Windows -> io.println("Doing stuff on Windows.")
  Unix(Darwin) -> io.println("Doing stuff on macOS.")
  Unix(_) -> io.println("Doing stuff on a Unix(-like) system.")
}
```

## Changelog 🐚

Take a look at the [changelog](https://github.com/patrik-kuehl/gleamyshell/blob/main/CHANGELOG.md) to get an overview of
each release and its changes.

## Contribution Guidelines 🐚

More information can be found [here](https://github.com/patrik-kuehl/gleamyshell/blob/main/CONTRIBUTING.md).

## License 🐚

GleamyShell is licensed under the [MIT license](https://github.com/patrik-kuehl/gleamyshell/blob/main/LICENSE.md).
