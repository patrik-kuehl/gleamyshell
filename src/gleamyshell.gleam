/// Represents information about why a command execution failed.
pub type CommandError {
  /// The command could be executed but returned a non-zero exit code.
  Failure(output: String, exit_code: Int)
  /// The command could not be executed completely and was aborted. You usually
  /// don't want to pattern match the specific reason and when targeting Bun,
  /// you won't receive any reason besides `Enoent` due to Bun's limitations here.
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
  /// The Unix operating system used by Apple as a core for its
  /// operating systems (e.g., macOS).
  Darwin
  /// A free Unix-like operating system descended from AT&T's UNIX.
  FreeBsd
  /// A free Unix-like operating system forked from NetBSD.
  OpenBsd
  /// The Linux kernel is the base for many Unix-like operating
  /// systems like Debian.
  Linux
  /// The Unix-like operating system SunOS is used as a core for
  /// other distributions like Solaris.
  SunOs
  /// An operating system not represented by the other options.
  OtherOs(String)
}

/// Executes the given command with arguments.
///
/// ## Example
/// 
/// ```gleam
/// case gleamyshell.execute("whoami", in: ".", args: []) {
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
@external(erlang, "gleamyshell_ffi", "execute")
@external(javascript, "./gleamyshell_ffi.mjs", "execute")
pub fn execute(
  executable: String,
  in working_directory: String,
  args args: List(String),
) -> Result(String, CommandError)

/// Returns the current working directory.
/// 
/// ## Example
/// 
/// ```gleam
/// case gleamyshell.cwd() {
///   Ok(working_directory) ->
///     io.println("Current working directory: " <> working_directory)
///   Error(_) -> io.println("Couldn't detect the current working directory.")
/// }
/// ```
@external(erlang, "gleamyshell_ffi", "cwd")
@external(javascript, "./gleamyshell_ffi.mjs", "cwd")
pub fn cwd() -> Result(String, Nil)

/// Returns information about the host's operating system.
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
///   Ok(home_directory) -> io.println("Home directory: " <> home_directory)
///   Error(_) ->
///     io.println("Couldn't detect the home directory of the current user.")
/// }
/// ```
@external(erlang, "gleamyshell_ffi", "home_directory")
@external(javascript, "./gleamyshell_ffi.mjs", "homeDirectory")
pub fn home_directory() -> Result(String, Nil)

/// Returns the value of the given environment variable if it is set.
/// 
/// ## Example
/// 
/// ```gleam
/// case gleamyshell.env("JAVA_HOME") {
///   Ok(dir) -> io.println("Java runtime location: " <> dir)
///   Error(_) -> 
///     io.println("The location of the Java runtime could not be found.")
/// }
/// ```
@external(erlang, "gleamyshell_ffi", "env")
@external(javascript, "./gleamyshell_ffi.mjs", "env")
pub fn env(identifier: String) -> Result(String, Nil)

/// Returns the location of the given executable if it could be found.
/// 
/// ## Example
/// 
/// ```gleam
/// case gleamyshell.which("git") {
///   Ok(_) -> io.println("Doing something with Git.")
///   Error(_) -> io.println("Git could not be found.")
/// }
/// ```
@external(erlang, "gleamyshell_ffi", "which")
@external(javascript, "./gleamyshell_ffi.mjs", "which")
pub fn which(executable: String) -> Result(String, Nil)
