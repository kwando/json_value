import gleam/json
import gleeunit
import json_value

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
  let assert Ok(json_value) = json.parse(value, json_value.decoder())
  assert value == json_value.to_string(json_value)
}

pub fn preprocessed_array_test() {
  assert json_value.Array([json_value.null])
    == json_value.preprocessed_array([json_value.null])
}
