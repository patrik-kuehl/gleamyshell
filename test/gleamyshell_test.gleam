import gleam/string
import gleamyshell.{type CommandError, Abort, Enoent, Failure, Unix, Windows}
import startest.{describe, it}
import startest/expect

pub fn main() {
  startest.run(startest.default_config())
}

pub fn execute_tests() {
  describe("gleamyshell/execute", [
    it("returns expected output when command succeeded", fn() {
      execute_test_script("greeting")
      |> expect.to_be_ok()
      |> string.trim()
      |> expect.to_equal("Hello there!")
    }),
    it("returns ENOENT error", fn() {
      gleamyshell.execute("_whoami_", [])
      |> expect.to_be_error()
      |> expect.to_equal(Abort(Enoent))
    }),
    it("returns expected output when command failed", fn() {
      let failure =
        execute_test_script("failed_command")
        |> expect.to_be_error()

      case failure {
        Failure(output, _) ->
          output
          |> string.trim()
          |> expect.to_equal("Nothing to worry about.")
        _ -> panic as "Did not expect the command to abort."
      }
    }),
  ])
}

pub fn execute_in_tests() {
  describe("gleamyshell/execute_in", [
    it("returns expected output when command succeeded", fn() {
      execute_test_script_in("greeting", "test/scripts")
      |> expect.to_be_ok()
      |> string.trim()
      |> expect.to_equal("Hello there!")
    }),
    it("returns ENOENT error", fn() {
      gleamyshell.execute_in("_whoami_", [], "../")
      |> expect.to_be_error()
      |> expect.to_equal(Abort(Enoent))
    }),
    it("returns expected output when command failed", fn() {
      let failure =
        execute_test_script_in("failed_command", "test/scripts")
        |> expect.to_be_error()

      case failure {
        Failure(output, _) ->
          output
          |> string.trim()
          |> expect.to_equal("Nothing to worry about.")
        _ -> panic as "Did not expect the command to abort."
      }
    }),
  ])
}

pub fn cwd_tests() {
  describe("gleamyshell/cwd", [
    it("returns the current working directory", fn() {
      let cwd =
        execute_test_script("pwd")
        |> expect.to_be_ok()
        |> string.trim()

      gleamyshell.cwd()
      |> expect.to_be_some()
      |> expect.to_equal(cwd)
    }),
  ])
}

pub fn home_directory_tests() {
  describe("gleamyshell/home_directory", [
    it("returns the home directory of the current user", fn() {
      let home_directory =
        execute_test_script("home_directory")
        |> expect.to_be_ok()
        |> string.trim()

      gleamyshell.home_directory()
      |> expect.to_be_some()
      |> expect.to_equal(home_directory)
    }),
  ])
}

pub fn env_tests() {
  describe("gleamyshell/env", [
    it("returns the value of environment variable when it exists", fn() {
      let identifier = "GLEAMYSHELL_TEST_ENV"
      let value = "value"

      set_env(identifier, value)

      gleamyshell.env(identifier)
      |> expect.to_be_some()
      |> expect.to_equal(value)

      unset_env(identifier)
    }),
    it("returns nothing when the environment variable does not exist", fn() {
      expect.to_be_none(gleamyshell.env("GLEAMYSHELL_TEST_ENV"))
    }),
  ])
}

fn execute_test_script(file_name: String) -> Result(String, CommandError) {
  let test_script_directory = "test/scripts/"

  case gleamyshell.os() {
    Windows ->
      gleamyshell.execute("powershell", [
        test_script_directory <> file_name <> ".ps1",
      ])
    Unix(_) ->
      gleamyshell.execute("sh", [test_script_directory <> file_name <> ".sh"])
  }
}

fn execute_test_script_in(
  file_name: String,
  working_directory: String,
) -> Result(String, CommandError) {
  case gleamyshell.os() {
    Windows ->
      gleamyshell.execute_in(
        "powershell",
        ["./" <> file_name <> ".ps1"],
        working_directory,
      )
    Unix(_) ->
      gleamyshell.execute_in("sh", [file_name <> ".sh"], working_directory)
  }
}

@external(erlang, "gleamyshell_test_ffi", "set_env")
@external(javascript, "./gleamyshell_test_ffi.mjs", "setEnv")
fn set_env(identifier: String, value: String) -> Nil

@external(erlang, "gleamyshell_test_ffi", "unset_env")
@external(javascript, "./gleamyshell_test_ffi.mjs", "unsetEnv")
fn unset_env(identifier: String) -> Nil
