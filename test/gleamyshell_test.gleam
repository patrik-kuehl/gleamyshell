import gleam/int
import gleam/result
import gleamyshell
import startest.{describe, it}
import startest/expect

pub fn main() {
  startest.run(startest.default_config())
}

pub fn execute_tests() {
  describe("gleamyshell::execute", [
    describe("successful commands", [
      it("echo returns expected output", fn() {
        let output = "Hello there!"

        gleamyshell.execute("echo", [output])
        |> expect.to_be_ok()
        |> expect.to_equal(output)
      }),
    ]),
    describe("erroneous commands", [
      it("unknown command returns exit code 127", fn() {
        gleamyshell.execute("_whoami_", [])
        |> expect.to_be_error()
        |> expect.to_equal(gleamyshell.CommandError("", 127))
      }),
      it("non-zero exit code via exit command", fn() {
        let output = "Nope"
        let exit_code = 5

        gleamyshell.execute(
          "echo " <> output <> " && exit " <> int.to_string(exit_code),
          [],
        )
        |> expect.to_be_error()
        |> expect.to_equal(gleamyshell.CommandError(output, exit_code))
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
