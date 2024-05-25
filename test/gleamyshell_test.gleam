import gleam/result
import gleamyshell
import startest.{describe, it}
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
        |> expect.to_equal(output)
      }),
    ]),
    describe("failed commands", [
      it("returns ENOENT error", fn() {
        gleamyshell.execute("_whoami_", [])
        |> expect.to_be_error()
        |> expect.to_equal(gleamyshell.Abort(gleamyshell.Enoent))
      }),
      it("returns exit code 127", fn() {
        let failure =
          gleamyshell.execute("/bin/sh", ["-c", "_whoami_"])
          |> expect.to_be_error()

        case failure {
          gleamyshell.Failure(_, exit_code) -> expect.to_equal(exit_code, 127)
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

      gleamyshell.cwd()
      |> expect.to_be_some()
      |> expect.to_equal(cwd)
    }),
  ])
}
