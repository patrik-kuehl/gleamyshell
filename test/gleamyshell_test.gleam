import gleam/result
import gleam/string
import gleamyshell.{type CommandError, Abort, Enoent, Failure, Unix}
import startest.{describe, it}
import startest/assertion_error.{AssertionError}
import startest/expect

pub fn main() {
  startest.run(startest.default_config())
}

pub fn execute_tests() {
  describe("gleamyshell::execute", [
    describe("succeeded commands", [
      it("returns expected output", fn() {
        let output = "Hello there!"

        gleamyshell.execute("echo", [output])
        |> expect.to_be_ok()
        |> expect.to_equal(output <> "\n")
      }),
    ]),
    describe("failed commands", [
      it("returns ENOENT error", fn() {
        gleamyshell.execute("_whoami_", [])
        |> expect.to_be_error()
        |> expect.to_equal(Abort(Enoent))
      }),
      it("returns exit code 1", fn() {
        let failure =
          gleamyshell.execute("cat", ["_whoami_"])
          |> expect.to_be_error()

        case failure {
          Failure(output, exit_code) -> {
            expect.to_equal(exit_code, 1)
            expect_to_contain(output, "No such file or directory")
          }
          _ -> panic
        }
      }),
      it("returns exit code 127", fn() {
        let failure =
          gleamyshell.execute("/bin/sh", ["-c", "_whoami_"])
          |> expect.to_be_error()

        case failure {
          Failure(output, exit_code) -> {
            expect.to_equal(exit_code, 127)
            expect_to_contain(output, "not found")
          }
          _ -> panic
        }
      }),
    ]),
  ])
}

pub fn execute_in_tests() {
  describe("gleamyshell::execute_in", [
    describe("succeeded commands", [
      it("returns expected output", fn() {
        let output = "/usr/bin"

        gleamyshell.execute_in("pwd", [], output)
        |> expect.to_be_ok()
        |> expect.to_equal(output <> "\n")
      }),
    ]),
    describe("failed commands", [
      it("returns ENOENT error", fn() {
        gleamyshell.execute_in("_whoami_", [], "/usr/bin")
        |> expect.to_be_error()
        |> expect.to_equal(Abort(Enoent))
      }),
      it("returns exit code 1", fn() {
        let failure =
          gleamyshell.execute_in("cat", ["_whoami_"], "/usr/bin")
          |> expect.to_be_error()

        case failure {
          Failure(output, exit_code) -> {
            expect.to_equal(exit_code, 1)
            expect_to_contain(output, "No such file or directory")
          }
          _ -> panic
        }
      }),
      it("returns exit code 127", fn() {
        let failure =
          gleamyshell.execute_in("/bin/sh", ["-c", "_whoami_"], "/usr/bin")
          |> expect.to_be_error()

        case failure {
          Failure(output, exit_code) -> {
            expect.to_equal(exit_code, 127)
            expect_to_contain(output, "not found")
          }
          _ -> panic
        }
      }),
    ]),
  ])
}

pub fn cwd_tests() {
  describe("gleamyshell::cwd", [
    it("returns the current working directory", fn() {
      let cwd =
        gleamyshell.execute("pwd", [])
        |> result.unwrap("")
        |> string.trim()

      gleamyshell.cwd()
      |> expect.to_be_some()
      |> expect.to_equal(cwd)
    }),
  ])
}

pub fn os_tests() {
  describe("gleamyshell::os", [
    it("returns the current operating system", fn() {
      case gleamyshell.os() {
        Unix(_) -> Nil
        _ -> panic as "Expected a Unix operating system."
      }
    }),
  ])
}

pub fn home_directory_tests() {
  describe("gleamyshell::home_directory", [
    it("returns the home directory of the current user", fn() {
      let home_directory =
        execute_test_script("home_directory.sh")
        |> result.unwrap("")
        |> string.trim()

      gleamyshell.home_directory()
      |> expect.to_be_some()
      |> expect.to_equal(home_directory)
    }),
  ])
}

fn expect_to_contain(haystack: String, needle: String) -> Nil {
  case string.contains(haystack, needle) {
    True -> Nil
    False ->
      AssertionError(
        string.concat([
          "Expected ",
          string.inspect(haystack),
          " to contain ",
          string.inspect(needle),
        ]),
        string.inspect(haystack),
        string.inspect(needle) <> " to be in",
      )
      |> assertion_error.raise()
  }
}

fn execute_test_script(file: String) -> Result(String, CommandError) {
  gleamyshell.execute("sh", ["test/scripts/" <> file])
}
