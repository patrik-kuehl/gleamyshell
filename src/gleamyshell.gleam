import gleam/option.{type Option, None, Some}
import gleam/string

pub type CommandError {
  Failure(output: String, exit_code: Int)
  Abort(reason: AbortReason)
}

pub type AbortReason {
  Enomem
  Eagain
  Enametoolong
  Emfile
  Enfile
  Eacces
  Enoent
  Other(String)
}

pub fn execute(
  command command: String,
  args args: List(String),
) -> Result(String, CommandError) {
  case execute_ffi(command, args) {
    Ok(output) ->
      output
      |> string.trim()
      |> Ok()
    Error(#(output, Some(exit_code))) ->
      output
      |> string.trim()
      |> Failure(exit_code)
      |> Error()
    Error(#(reason, None)) ->
      reason
      |> to_abort_reason()
      |> Abort()
      |> Error()
  }
}

pub fn cwd() -> Option(String) {
  case cwd_ffi() {
    Some(path) ->
      path
      |> string.trim()
      |> Some()
    None -> None
  }
}

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
    value -> Other(value)
  }
}

@external(erlang, "Elixir.GleamyShell", "execute")
@external(javascript, "./gleamyshell_ffi.mjs", "execute")
fn execute_ffi(
  command: String,
  args: List(String),
) -> Result(String, #(String, Option(Int)))

@external(erlang, "Elixir.GleamyShell", "cwd")
@external(javascript, "./gleamyshell_ffi.mjs", "cwd")
fn cwd_ffi() -> Option(String)
