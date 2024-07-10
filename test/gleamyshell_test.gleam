import gleam/string
import gleamyshell.{type CommandOutput, CommandOutput, Unix, Windows}
import startest.{describe, it}
import startest/expect

pub fn main() {
  startest.run(startest.default_config())
}

pub fn execute_tests() {
  describe("gleamyshell/execute", [
    describe("in working directory \".\"", [
      it("returns expected output when command succeeded", fn() {
        let assert CommandOutput(0, output) =
          execute_test_script(
            test_scripts_directory <> "greeting",
            in: ".",
            args: [],
          )
          |> expect.to_be_ok()

        output
        |> string.trim()
        |> expect.to_equal("Hello there!")
      }),
      it("returns expected output identical to the passed argument", fn() {
        let value = "test"

        let assert CommandOutput(0, output) =
          execute_test_script(
            test_scripts_directory <> "argument",
            in: ".",
            args: [value],
          )
          |> expect.to_be_ok()

        output
        |> string.trim()
        |> expect.to_equal(value)
      }),
      it("returns ENOENT error", fn() {
        gleamyshell.execute("_whoami_", in: ".", args: [])
        |> expect.to_be_error()
        |> expect.to_equal("enoent")
      }),
      it("returns expected output when command failed", fn() {
        let assert CommandOutput(1, output) =
          execute_test_script(
            test_scripts_directory <> "failed_command",
            in: ".",
            args: [],
          )
          |> expect.to_be_ok()

        output
        |> string.trim()
        |> expect.to_equal("Nothing to worry about.")
      }),
    ]),
    describe("in working directory \"" <> test_scripts_directory <> "\"", [
      it("returns expected output when command succeeded", fn() {
        let assert CommandOutput(0, output) =
          execute_test_script("greeting", in: test_scripts_directory, args: [])
          |> expect.to_be_ok()

        output
        |> string.trim()
        |> expect.to_equal("Hello there!")
      }),
      it("returns expected output identical to the passed argument", fn() {
        let value = "test"

        let assert CommandOutput(0, output) =
          execute_test_script("argument", in: test_scripts_directory, args: [
            value,
          ])
          |> expect.to_be_ok()

        output
        |> string.trim()
        |> expect.to_equal(value)
      }),
      it("returns ENOENT error", fn() {
        gleamyshell.execute("_whoami_", in: test_scripts_directory, args: [])
        |> expect.to_be_error()
        |> expect.to_equal("enoent")
      }),
      it("returns expected output when command failed", fn() {
        let assert CommandOutput(1, output) =
          execute_test_script(
            "failed_command",
            in: test_scripts_directory,
            args: [],
          )
          |> expect.to_be_ok()

        output
        |> string.trim()
        |> expect.to_equal("Nothing to worry about.")
      }),
    ]),
  ])
}

pub fn cwd_tests() {
  describe("gleamyshell/cwd", [
    it("returns the current working directory", fn() {
      let CommandOutput(_, cwd) =
        execute_test_script(test_scripts_directory <> "pwd", in: ".", args: [])
        |> expect.to_be_ok()

      gleamyshell.cwd()
      |> expect.to_be_ok()
      |> expect.to_equal(cwd |> string.trim())
    }),
  ])
}

pub fn home_directory_tests() {
  describe("gleamyshell/home_directory", [
    it("returns the home directory of the current user", fn() {
      let CommandOutput(_, home_directory) =
        execute_test_script(
          test_scripts_directory <> "home_directory",
          in: ".",
          args: [],
        )
        |> expect.to_be_ok()

      gleamyshell.home_directory()
      |> expect.to_be_ok()
      |> expect.to_equal(home_directory |> string.trim())
    }),
  ])
}

pub fn env_tests() {
  describe("gleamyshell/env", [
    it(
      "returns the value of the given environment variable when it exists",
      fn() {
        let CommandOutput(_, path) =
          execute_test_script(
            test_scripts_directory <> "path_env_output",
            in: ".",
            args: [],
          )
          |> expect.to_be_ok()

        gleamyshell.env("PATH")
        |> expect.to_be_ok()
        |> expect.to_equal(path |> string.trim())
      },
    ),
    it(
      "returns an error when the given environment variable does not exist",
      fn() { expect.to_be_error(gleamyshell.env("i_dont_exist")) },
    ),
  ])
}

pub fn which_tests() {
  describe("gleamyshell/which", [
    it("returns the path of the given executable when it could be found", fn() {
      let CommandOutput(_, executable_path) =
        execute_test_script(
          test_scripts_directory <> "which",
          in: ".",
          args: [],
        )
        |> expect.to_be_ok()

      case gleamyshell.os() {
        Windows ->
          gleamyshell.which("cmd")
          |> expect.to_be_ok()
          |> expect.to_equal(executable_path |> string.trim())
        Unix(_) ->
          gleamyshell.which("sh")
          |> expect.to_be_ok()
          |> expect.to_equal(executable_path |> string.trim())
      }

      Nil
    }),
    it("returns an error when the given executable could not be found", fn() {
      expect.to_be_error(gleamyshell.which("_whoami_"))
    }),
  ])
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
