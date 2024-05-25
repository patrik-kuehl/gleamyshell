import gleam/option.{type Option, None, Some}
import gleam/string

pub type CommandError {
  CommandError(output: String, exit_code: Int)
}

pub fn execute(
  command: String,
  args: List(String),
) -> Result(String, CommandError) {
  case execute_ffi(command, args) {
    Ok(output) ->
      output
      |> string.trim()
      |> Ok()
    Error(#(output, exit_code)) ->
      output
      |> string.trim()
      |> CommandError(exit_code)
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

@external(erlang, "Elixir.GleamyShell", "execute")
@external(javascript, "./gleamyshell_ffi.mjs", "execute")
fn execute_ffi(
  command: String,
  args: List(String),
) -> Result(String, #(String, Int))

@external(erlang, "Elixir.GleamyShell", "cwd")
@external(javascript, "./gleamyshell_ffi.mjs", "cwd")
fn cwd_ffi() -> Option(String)
