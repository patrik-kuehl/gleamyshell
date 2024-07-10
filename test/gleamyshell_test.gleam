import gleam/string
import gleamyshell.{type CommandOutput, CommandOutput, Unix, Windows}
import gleeunit
import gleeunit/should

pub fn main() {
  gleeunit.main()
}

pub fn execute_test() {
  let assert CommandOutput(0, output) =
    execute_test_script(test_scripts_directory <> "greeting", in: ".", args: [])
    |> should.be_ok()

  output
  |> string.trim()
  |> should.equal("Hello there!")
  |> because("it equals the stdout of the command")

  let value = "test"

  let assert CommandOutput(0, output) =
    execute_test_script(test_scripts_directory <> "argument", in: ".", args: [
      value,
    ])
    |> should.be_ok()

  output
  |> string.trim()
  |> should.equal(value)
  |> because("the passed argument is identical to the stdout of the command")

  gleamyshell.execute("_whoami_", in: ".", args: [])
  |> should.be_error()
  |> should.equal("enoent")
  |> because("the executable could not be found")

  let assert CommandOutput(1, output) =
    execute_test_script(
      test_scripts_directory <> "failed_command",
      in: ".",
      args: [],
    )
    |> should.be_ok()

  output
  |> string.trim()
  |> should.equal("Nothing to worry about.")
  |> because("it equals the stderr of the command")

  let assert CommandOutput(0, output) =
    execute_test_script("greeting", in: test_scripts_directory, args: [])
    |> should.be_ok()
    |> because("it equals the stdout of the command")

  output
  |> string.trim()
  |> should.equal("Hello there!")

  let value = "test"

  let assert CommandOutput(0, output) =
    execute_test_script("argument", in: test_scripts_directory, args: [value])
    |> should.be_ok()

  output
  |> string.trim()
  |> should.equal(value)
  |> because("the passed argument is identical to the stdout of the command")

  gleamyshell.execute("_whoami_", in: test_scripts_directory, args: [])
  |> should.be_error()
  |> should.equal("enoent")
  |> because("the executable could not be found")

  let assert CommandOutput(1, output) =
    execute_test_script("failed_command", in: test_scripts_directory, args: [])
    |> should.be_ok()

  output
  |> string.trim()
  |> should.equal("Nothing to worry about.")
  |> because("it equals the stderr of the command")
}

pub fn cwd_test() {
  let CommandOutput(_, cwd) =
    execute_test_script(test_scripts_directory <> "pwd", in: ".", args: [])
    |> should.be_ok()

  gleamyshell.cwd()
  |> should.be_ok()
  |> should.equal(cwd |> string.trim())
}

pub fn home_directory_test() {
  let CommandOutput(_, home_directory) =
    execute_test_script(
      test_scripts_directory <> "home_directory",
      in: ".",
      args: [],
    )
    |> should.be_ok()

  gleamyshell.home_directory()
  |> should.be_ok()
  |> should.equal(home_directory |> string.trim())
}

pub fn env_test() {
  let CommandOutput(_, path) =
    execute_test_script(
      test_scripts_directory <> "path_env_output",
      in: ".",
      args: [],
    )
    |> should.be_ok()

  gleamyshell.env("PATH")
  |> should.be_ok()
  |> should.equal(path |> string.trim())
  |> because("the environment variable exists")

  gleamyshell.env("i_dont_exist")
  |> should.be_error()
  |> because("the environment variable does not exist")
}

pub fn which_test() {
  let CommandOutput(_, executable_path) =
    execute_test_script(test_scripts_directory <> "which", in: ".", args: [])
    |> should.be_ok()

  case gleamyshell.os() {
    Windows ->
      gleamyshell.which("cmd")
      |> should.be_ok()
    Unix(_) ->
      gleamyshell.which("sh")
      |> should.be_ok()
  }
  |> should.equal(executable_path |> string.trim())
  |> because("the executable could be found")

  gleamyshell.which("_whoami_")
  |> should.be_error()
  |> because("the executable could not be found")
}

const test_scripts_directory = "./test/scripts/"

fn execute_test_script(
  file_name: String,
  in working_directory: String,
  args args: List(String),
) -> Result(CommandOutput, String) {
  case gleamyshell.os() {
    Windows ->
      gleamyshell.execute("powershell", in: working_directory, args: [
        "./" <> file_name <> ".ps1",
        ..args
      ])
    Unix(_) ->
      gleamyshell.execute("sh", in: working_directory, args: [
        "./" <> file_name <> ".sh",
        ..args
      ])
  }
}

fn because(assertion_result: a, _description: String) -> a {
  assertion_result
}
