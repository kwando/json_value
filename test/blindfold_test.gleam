import blindfold
import gleam/json
import gleeunit

pub fn main() -> Nil {
  gleeunit.main()
}

// gleeunit test functions end in `_test`
pub fn blindfold_test() {
  roundtrip("null")
  roundtrip("true")
  roundtrip("false")
  roundtrip("42")
  roundtrip("-42")
  roundtrip("3.14")
  roundtrip("-3.14")
  roundtrip("[]")
  roundtrip("{}")
}

fn roundtrip(value: String) {
  let assert Ok(json_value) = json.parse(value, blindfold.decode())
  assert value == json.to_string(blindfold.to_json(json_value))
}
