import gleam/option.{type Option, None, Some}
import gleam/string

/// Represents information about why a command execution failed.
pub type CommandError {
  /// The command could be executed but returned a non-zero exit code.
  Failure(output: String, exit_code: Int)
  /// The command did not execute and instead was aborted.
  Abort(reason: AbortReason)
}

/// Represents the reason why the execution of a command was aborted.
///
/// Most of these reasons are common POSIX errors.
pub type AbortReason {
  /// Not enough memory.
  Enomem
  /// Resource temporarily unavailable.
  Eagain
  /// Too long file name.
  Enametoolong
  /// Too many open files.
  Emfile
  /// File table overflow.
  Enfile
  /// Insufficient permissions.
  Eacces
  /// No such file or directory.
  Enoent
  /// An error not represented by the other options.
  OtherAbortReason(String)
}

/// Represents families of operating systems.
pub type OsFamily {
  /// The operating system is part of the Unix family.
  Unix(Os)
  /// The operating system is part of the Windows family.
  Windows
}

/// Represents names of operating systems.
pub type Os {
  /// The Unix operating system used by Apple as a core for its operating systems (e.g., macOS).
  Darwin
  /// A free Unix-like operating system descended from AT&T's UNIX.
  FreeBsd
  /// A free Unix-like operating system forked from NetBSD.
  OpenBsd
  /// The Linux kernel is the base for many Unix-like operating systems like Debian.
  Linux
  /// The Unix-like operating system SunOS is used as a core for other distributions like Solaris.
  SunOs
  /// An operating system not represented by the other options.
  OtherOs(String)
}

/// Executes the given command with arguments.
///
/// ## Example
/// 
/// ```gleam
/// let result = gleamyshell.execute("whoami", [])
/// 
/// case result {
///   Ok(username) ->
///     io.println("Hello there, " <> string.trim(username) <> "!")
///   Error(Failure(output, exit_code)) ->
///     io.println(
///       "Whoops!\nError ("
///       <> int.to_string(exit_code)
///       <> "): "
///       <> string.trim(output),
///     )
///   Error(Abort(_)) -> io.println("Something went terribly wrong.")
/// }
/// ```
/// 
/// This function can also be invoked by using labelled arguments.
/// 
/// ```gleam
/// let result = gleamyshell.execute("ls", args: ["-la"])
/// let another_result = gleamyshell.execute(command: "ls", args: ["-la"])
/// ```
pub fn execute(
  command command: String,
  args args: List(String),
) -> Result(String, CommandError) {
  internal_execute(command, args, None)
}

/// Executes the given command with arguments in a specified working directory.
///
/// ## Example
/// 
/// ```gleam
/// let result =
///   gleamyshell.execute_in("cat", [".bashrc"], "/home/username")
/// 
/// case result {
///   Ok(file_content) -> io.println(file_content)
///   Error(Failure(output, exit_code)) ->
///     io.println(
///       "Whoops!\nError ("
///       <> int.to_string(exit_code)
///       <> "): "
///       <> string.trim(output),
///     )
///   Error(Abort(_)) -> io.println("Something went terribly wrong.")
/// }
/// ```
/// 
/// This function can also be invoked by using labelled arguments.
/// 
/// ```gleam
/// let result =
///   gleamyshell.execute_in(
///     "ls",
///     args: ["-la"],
///     working_directory: "/usr/bin",
///   )
/// 
/// let another_result =
///   gleamyshell.execute_in(
///     command: "ls",
///     args: ["-la"],
///     working_directory: "/usr/bin",
///   )
/// ```
pub fn execute_in(
  command command: String,
  args args: List(String),
  working_directory working_directory: String,
) -> Result(String, CommandError) {
  internal_execute(command, args, Some(working_directory))
}

/// Returns the current working directory.
/// 
/// This function returns an `Option` because it can fail on Unix-like systems in rare circumstances.
/// 
/// ## Example
/// 
/// ```gleam
/// case gleamyshell.cwd() {
///   Some(working_directory) ->
///     io.println("Current working directory: " <> working_directory)
///   None -> io.println("Couldn't detect the current working directory.")
/// }
/// ```
@external(erlang, "gleamyshell_ffi", "cwd")
@external(javascript, "./gleamyshell_ffi.mjs", "cwd")
pub fn cwd() -> Option(String)

/// Returns information about the host's operating system.
/// 
/// This function is meant to be a quality-of-life feature where someone needs to execute different
/// shell commands that differ depending on the operating system.
/// 
/// ## Example
/// 
/// ```gleam
/// case gleamyshell.os() {
///   Windows -> io.println("Doing stuff on Windows.")
///   Unix(_) -> io.println("Doing stuff on a Unix(-like) system.")
/// }
/// ```
@external(erlang, "gleamyshell_ffi", "os")
@external(javascript, "./gleamyshell_ffi.mjs", "os")
pub fn os() -> OsFamily

/// Returns the home directory of the current user.
/// 
/// This function returns an `Option` because it can fail in rare circumstances.
/// 
/// ## Example
/// 
/// ```gleam
/// case gleamyshell.home_directory() {
///   Some(home_directory) -> io.println("Home directory: " <> home_directory)
///   None ->
///     io.println("Couldn't detect the home directory of the current user.")
/// }
/// ```
@external(erlang, "gleamyshell_ffi", "home_directory")
@external(javascript, "./gleamyshell_ffi.mjs", "homeDirectory")
pub fn home_directory() -> Option(String)

/// Returns the value of the given environment variable when it is set.
/// 
/// ## Example
/// 
/// ```gleam
/// case gleamyshell.env("JAVA_HOME") {
///   Some(dir) -> io.println("Java runtime location: " <> dir)
///   None -> 
///     io.println("The location of the Java runtime could not be found.")
/// }
/// ```
@external(erlang, "gleamyshell_ffi", "env")
@external(javascript, "./gleamyshell_ffi.mjs", "env")
pub fn env(identifier: String) -> Option(String)

fn to_abort_reason(reason: String) -> AbortReason {
  case
    reason
    |> string.trim()
    |> string.lowercase()
  {
    "enomem" -> Enomem
    "eagain" -> Eagain
    "enametoolong" -> Enametoolong
    "emfile" -> Emfile
    "enfile" -> Enfile
    "eacces" -> Eacces
    "enoent" -> Enoent
    error -> OtherAbortReason(error)
  }
}

fn internal_execute(
  command: String,
  args: List(String),
  working_directory: Option(String),
) -> Result(String, CommandError) {
  case execute_ffi(command, args, working_directory) {
    Ok(output) -> Ok(output)
    Error(#(output, Some(exit_code))) ->
      output
      |> Failure(exit_code)
      |> Error()
    Error(#(reason, None)) ->
      reason
      |> to_abort_reason()
      |> Abort()
      |> Error()
  }
}

@external(erlang, "Elixir.GleamyShell", "execute")
@external(javascript, "./gleamyshell_ffi.mjs", "execute")
fn execute_ffi(
  command: String,
  args: List(String),
  working_directory: Option(String),
) -> Result(String, #(String, Option(Int)))
