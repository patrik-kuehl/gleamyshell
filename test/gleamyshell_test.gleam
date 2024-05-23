import gleamyshell
import gleeunit
import gleeunit/should

pub fn main() {
  gleeunit.main()
}

pub fn placeholder_test() {
  gleamyshell.placeholder()
  |> should.equal("placeholder")
}
