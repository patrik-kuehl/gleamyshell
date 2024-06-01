import gleam/string
import gleamyshell.{type CommandError, Abort, Enoent, Failure, Unix, Windows}
import startest.{describe, it}
import startest/expect

pub fn main() {
  startest.run(startest.default_config())
}

pub fn execute_tests() {
  describe("gleamyshell/execute", [
    describe("in working directory \".\"", [
      it("returns expected output when command succeeded", fn() {
        execute_test_script("test/scripts/greeting", in: ".", args: [])
        |> expect.to_be_ok()
        |> string.trim()
        |> expect.to_equal("Hello there!")
      }),
      it(
        "returns expected output with resolved environment variable when it's set",
        fn() {
          let identifier = "GLEAMYSHELL_TEST_ENV"
          let value = "Greetings!"

          set_env(identifier, value)

          execute_test_script(
            "test/scripts/env_variable_output",
            in: ".",
            args: [],
          )
          |> expect.to_be_ok()
          |> string.trim()
          |> expect.to_equal(value)

          unset_env(identifier)
        },
      ),
      it("returns empty output when environment variable is not set", fn() {
        execute_test_script(
          "test/scripts/env_variable_output",
          in: ".",
          args: [],
        )
        |> expect.to_be_ok()
        |> string.trim()
        |> expect.to_equal("")
      }),
      it("returns expected output identical to the passed argument", fn() {
        let value = "test"

        execute_test_script("test/scripts/argument", in: ".", args: [value])
        |> expect.to_be_ok()
        |> string.trim()
        |> expect.to_equal(value)
      }),
      it("returns ENOENT error", fn() {
        gleamyshell.execute("_whoami_", in: ".", args: [])
        |> expect.to_be_error()
        |> expect.to_equal(Abort(Enoent))
      }),
      it("returns expected output when command failed", fn() {
        let failure =
          execute_test_script("test/scripts/failed_command", in: ".", args: [])
          |> expect.to_be_error()

        case failure {
          Failure(output, _) ->
            output
            |> string.trim()
            |> expect.to_equal("Nothing to worry about.")
          _ -> panic as "Did not expect the command to abort."
        }
      }),
    ]),
    describe("in working directory \"./test/scripts\"", [
      it("returns expected output when command succeeded", fn() {
        execute_test_script("greeting", in: "./test/scripts", args: [])
        |> expect.to_be_ok()
        |> string.trim()
        |> expect.to_equal("Hello there!")
      }),
      it(
        "returns expected output with resolved environment variable when it's set",
        fn() {
          let identifier = "GLEAMYSHELL_TEST_ENV"
          let value = "Greetings!"

          set_env(identifier, value)

          execute_test_script(
            "env_variable_output",
            in: "./test/scripts",
            args: [],
          )
          |> expect.to_be_ok()
          |> string.trim()
          |> expect.to_equal(value)

          unset_env(identifier)
        },
      ),
      it("returns empty output when environment variable is not set", fn() {
        execute_test_script(
          "env_variable_output",
          in: "./test/scripts",
          args: [],
        )
        |> expect.to_be_ok()
        |> string.trim()
        |> expect.to_equal("")
      }),
      it("returns expected output identical to the passed argument", fn() {
        let value = "test"

        execute_test_script("argument", in: "./test/scripts", args: [value])
        |> expect.to_be_ok()
        |> string.trim()
        |> expect.to_equal(value)
      }),
      it("returns ENOENT error", fn() {
        gleamyshell.execute("_whoami_", in: "./test/scripts", args: [])
        |> expect.to_be_error()
        |> expect.to_equal(Abort(Enoent))
      }),
      it("returns expected output when command failed", fn() {
        let failure =
          execute_test_script("failed_command", in: "./test/scripts", args: [])
          |> expect.to_be_error()

        case failure {
          Failure(output, _) ->
            output
            |> string.trim()
            |> expect.to_equal("Nothing to worry about.")
          _ -> panic as "Did not expect the command to abort."
        }
      }),
    ]),
  ])
}

pub fn cwd_tests() {
  describe("gleamyshell/cwd", [
    it("returns the current working directory", fn() {
      let cwd =
        execute_test_script("test/scripts/pwd", in: ".", args: [])
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
        execute_test_script("test/scripts/home_directory", in: ".", args: [])
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
    it(
      "returns the value of the given environment variable when it exists",
      fn() {
        let identifier = "GLEAMYSHELL_TEST_ENV"
        let value = "value"

        set_env(identifier, value)

        gleamyshell.env(identifier)
        |> expect.to_be_some()
        |> expect.to_equal(value)

        unset_env(identifier)
      },
    ),
    it(
      "returns nothing when the given environment variable does not exist",
      fn() { expect.to_be_none(gleamyshell.env("GLEAMYSHELL_TEST_ENV")) },
    ),
  ])
}

pub fn which_tests() {
  describe("gleamyshell/which", [
    it("returns the path of the given executable when it could be found", fn() {
      let executable_path =
        execute_test_script("test/scripts/which", in: ".", args: [])
        |> expect.to_be_ok()
        |> string.trim()

      case gleamyshell.os() {
        Windows ->
          gleamyshell.which("cmd")
          |> expect.to_be_some()
          |> expect.to_equal(executable_path)
        Unix(_) ->
          gleamyshell.which("sh")
          |> expect.to_be_some()
          |> expect.to_equal(executable_path)
      }

      Nil
    }),
    it("returns nothing when the given executable could not be found", fn() {
      expect.to_be_none(gleamyshell.which("_whoami_"))
    }),
  ])
}

fn execute_test_script(
  file_name: String,
  in working_directory: String,
  args args: List(String),
) -> Result(String, CommandError) {
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

@external(erlang, "gleamyshell_test_ffi", "set_env")
@external(javascript, "./gleamyshell_test_ffi.mjs", "setEnv")
fn set_env(identifier: String, value: String) -> Nil

@external(erlang, "gleamyshell_test_ffi", "unset_env")
@external(javascript, "./gleamyshell_test_ffi.mjs", "unsetEnv")
fn unset_env(identifier: String) -> Nil
