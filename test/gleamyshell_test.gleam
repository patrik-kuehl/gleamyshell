import gleam/result
import gleam/string
import gleamyshell.{Abort, Enoent, Failure}
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

fn expect_to_contain(does: String, contains: String) -> Nil {
  case string.contains(does, contains) {
    True -> Nil
    False ->
      AssertionError(
        string.concat([
          "Expected ",
          string.inspect(does),
          " to contain ",
          string.inspect(contains),
        ]),
        string.inspect(does),
        string.inspect(contains) <> " to be in",
      )
      |> assertion_error.raise()
  }
}
