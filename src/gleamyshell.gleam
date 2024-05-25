pub type CommandError {
  CommandError(output: String, exit_code: Int)
}

pub fn execute(
  command: String,
  args: List(String),
) -> Result(String, CommandError) {
  case execute_ffi(command, args) {
    Ok(output) -> Ok(output)
    Error(#(output, exit_code)) -> Error(CommandError(output, exit_code))
  }
}

@external(erlang, "Elixir.GleamyShell", "execute")
@external(javascript, "./gleamyshell_ffi.mjs", "execute")
fn execute_ffi(
  command: String,
  args: List(String),
) -> Result(String, #(String, Int))
