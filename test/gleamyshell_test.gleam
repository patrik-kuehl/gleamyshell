import gleam/string
import gleamyshell.{type CommandError, Abort, Enoent, Failure, Unix, Windows}
import startest.{describe, it}
import startest/expect

const test_scripts_directory = "./test/scripts/"

const test_environment_variable_identifier = "GLEAMYSHELL_TEST_ENV"

pub fn main() {
  startest.run(startest.default_config())
}

pub fn execute_tests() {
  describe("gleamyshell/execute", [
    describe("in working directory \".\"", [
      it("returns expected output when command succeeded", fn() {
        execute_test_script(
          test_scripts_directory <> "greeting",
          in: ".",
          args: [],
        )
        |> expect.to_be_ok()
        |> string.trim()
        |> expect.to_equal("Hello there!")
      }),
      it(
        "returns expected output with resolved environment variable when it's set",
        fn() {
          let value = "Greetings!"

          gleamyshell.set_env(test_environment_variable_identifier, value)

          execute_test_script(
            test_scripts_directory <> "env_variable_output",
            in: ".",
            args: [],
          )
          |> expect.to_be_ok()
          |> string.trim()
          |> expect.to_equal(value)

          clean_up_environment_variables([test_environment_variable_identifier])
        },
      ),
      it("returns empty output when environment variable is not set", fn() {
        execute_test_script(
          test_scripts_directory <> "env_variable_output",
          in: ".",
          args: [],
        )
        |> expect.to_be_ok()
        |> string.trim()
        |> expect.to_equal("")
      }),
      it("returns expected output identical to the passed argument", fn() {
        let value = "test"

        execute_test_script(
          test_scripts_directory <> "argument",
          in: ".",
          args: [value],
        )
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
          execute_test_script(
            test_scripts_directory <> "failed_command",
            in: ".",
            args: [],
          )
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
    describe("in working directory \"" <> test_scripts_directory <> "\"", [
      it("returns expected output when command succeeded", fn() {
        execute_test_script("greeting", in: test_scripts_directory, args: [])
        |> expect.to_be_ok()
        |> string.trim()
        |> expect.to_equal("Hello there!")
      }),
      it(
        "returns expected output with resolved environment variable when it's set",
        fn() {
          let value = "Greetings!"

          gleamyshell.set_env(test_environment_variable_identifier, value)

          execute_test_script(
            "env_variable_output",
            in: test_scripts_directory,
            args: [],
          )
          |> expect.to_be_ok()
          |> string.trim()
          |> expect.to_equal(value)

          clean_up_environment_variables([test_environment_variable_identifier])
        },
      ),
      it("returns empty output when environment variable is not set", fn() {
        execute_test_script(
          "env_variable_output",
          in: test_scripts_directory,
          args: [],
        )
        |> expect.to_be_ok()
        |> string.trim()
        |> expect.to_equal("")
      }),
      it("returns expected output identical to the passed argument", fn() {
        let value = "test"

        execute_test_script("argument", in: test_scripts_directory, args: [
          value,
        ])
        |> expect.to_be_ok()
        |> string.trim()
        |> expect.to_equal(value)
      }),
      it("returns ENOENT error", fn() {
        gleamyshell.execute("_whoami_", in: test_scripts_directory, args: [])
        |> expect.to_be_error()
        |> expect.to_equal(Abort(Enoent))
      }),
      it("returns expected output when command failed", fn() {
        let failure =
          execute_test_script(
            "failed_command",
            in: test_scripts_directory,
            args: [],
          )
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
        execute_test_script(test_scripts_directory <> "pwd", in: ".", args: [])
        |> expect.to_be_ok()
        |> string.trim()

      gleamyshell.cwd()
      |> expect.to_be_ok()
      |> expect.to_equal(cwd)
    }),
  ])
}

pub fn home_directory_tests() {
  describe("gleamyshell/home_directory", [
    it("returns the home directory of the current user", fn() {
      let home_directory =
        execute_test_script(
          test_scripts_directory <> "home_directory",
          in: ".",
          args: [],
        )
        |> expect.to_be_ok()
        |> string.trim()

      gleamyshell.home_directory()
      |> expect.to_be_ok()
      |> expect.to_equal(home_directory)
    }),
  ])
}

pub fn env_tests() {
  describe("gleamyshell/env", [
    it(
      "returns the value of the given environment variable when it exists",
      fn() {
        let value = "value"

        gleamyshell.set_env(test_environment_variable_identifier, value)

        gleamyshell.env(test_environment_variable_identifier)
        |> expect.to_be_some()
        |> expect.to_equal(value)

        clean_up_environment_variables([test_environment_variable_identifier])
      },
    ),
    it(
      "returns nothing when the given environment variable does not exist",
      fn() {
        expect.to_be_none(gleamyshell.env(test_environment_variable_identifier))
      },
    ),
  ])
}

pub fn set_env_tests() {
  describe("gleamyshell/set_env", [
    it("returns true when the environment variable could be set", fn() {
      let value = "value"

      gleamyshell.set_env(test_environment_variable_identifier, value)
      |> expect.to_be_true()

      gleamyshell.env(test_environment_variable_identifier)
      |> expect.to_be_some()
      |> expect.to_equal(value)

      clean_up_environment_variables([test_environment_variable_identifier])
    }),
    it("returns false when the environment variable could not be set", fn() {
      let identifier = "123GLEAMYSHELL_TEST_ENV"
      let value = "value"

      gleamyshell.set_env(identifier, value)
      |> expect.to_be_false()

      gleamyshell.env(identifier)
      |> expect.to_be_none()

      clean_up_environment_variables([identifier])
    }),
  ])
}

pub fn unset_env_tests() {
  describe("gleamyshell/unset_env", [
    it("returns true when the environment variable could be unset", fn() {
      gleamyshell.set_env(test_environment_variable_identifier, "value")
      |> expect.to_be_true()

      gleamyshell.unset_env(test_environment_variable_identifier)
      |> expect.to_be_true()

      clean_up_environment_variables([test_environment_variable_identifier])
    }),
  ])
}

pub fn which_tests() {
  describe("gleamyshell/which", [
    it("returns the path of the given executable when it could be found", fn() {
      let executable_path =
        execute_test_script(
          test_scripts_directory <> "which",
          in: ".",
          args: [],
        )
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

fn clean_up_environment_variables(identifiers: List(String)) -> Nil {
  case identifiers {
    [] -> Nil
    [identifier, ..rest] -> {
      gleamyshell.unset_env(identifier)

      clean_up_environment_variables(rest)
    }
  }
}
