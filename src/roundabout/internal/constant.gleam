import gleam/regexp
import gleam/string

pub opaque type Constant {
  Constant(value: String)
}

pub fn new(value: String) -> Result(Constant, String) {
  let assert Ok(re) = regexp.from_string("^[a-zA-Z0-9._~%-]+$")

  let candidate = string.lowercase(value)

  case regexp.check(re, candidate) {
    True -> Ok(Constant(candidate))
    False -> Error("Invalid constant value " <> value)
  }
}

pub fn unsafe(value: String) {
  Constant(value)
}

pub fn value(input: Constant) -> String {
  input.value
}
