import gleam/bit_array
import gleam/dict
import gleam/json
import gleam/list
import gleam/string_tree
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

pub fn parse_scalar_types_test() {
  assert json_value.parse("null") == Ok(json_value.Null)
  assert json_value.parse("true") == Ok(json_value.Bool(True))
  assert json_value.parse("false") == Ok(json_value.Bool(False))
  assert json_value.parse("42") == Ok(json_value.Int(42))
  assert json_value.parse("-42") == Ok(json_value.Int(-42))
  assert json_value.parse("3.14") == Ok(json_value.Float(3.14))
  assert json_value.parse("-3.14") == Ok(json_value.Float(-3.14))
  assert json_value.parse("\"hello\"") == Ok(json_value.String("hello"))
  assert json_value.parse("[]") == Ok(json_value.Array([]))
  assert json_value.parse("{}") == Ok(json_value.Object(dict.new()))
}

pub fn number_edge_cases_test() {
  assert json_value.parse("0") == Ok(json_value.Int(0))
  assert json_value.parse("-0") == Ok(json_value.Int(0))
  assert json_value.parse("1e-3") == Ok(json_value.Float(0.001))
  assert json_value.parse("-1.25E+2") == integral_float(-125.0, -125)
  assert json_value.parse("1.0") == integral_float(1.0, 1)
  assert json_value.parse("1e3") == integral_float(1000.0, 1000)
}

// BEAM distinguishes floats from integers; JavaScript has one number type,
// so the decoder's integer branch wins for integral numbers on JavaScript.
@target(erlang)
fn integral_float(
  float: Float,
  _int: Int,
) -> Result(json_value.JsonValue, json.DecodeError) {
  Ok(json_value.Float(float))
}

@target(javascript)
fn integral_float(
  _float: Float,
  int: Int,
) -> Result(json_value.JsonValue, json.DecodeError) {
  Ok(json_value.Int(int))
}

pub fn float_serialization_test() {
  assert json_value.Float(1.0)
    |> json_value.to_string
    |> json_value.parse
    == integral_float(1.0, 1)
  assert json_value.Float(-0.125)
    |> json_value.to_string
    |> json_value.parse
    == Ok(json_value.Float(-0.125))
}

pub fn parse_nested_containers_test() {
  assert json_value.parse(
      " {\"items\": [1, true, null, {\"name\": \"hello\"}], \"empty\": []} ",
    )
    == Ok(nested_value())
}

pub fn nested_value_roundtrip_test() {
  let value = nested_value()
  assert value |> json_value.to_string |> json_value.parse == Ok(value)
}

fn nested_value() -> json_value.JsonValue {
  json_value.Object(
    dict.from_list([
      #(
        "items",
        json_value.Array([
          json_value.Int(1),
          json_value.Bool(True),
          json_value.Null,
          json_value.Object(
            dict.from_list([
              #("name", json_value.String("hello")),
            ]),
          ),
        ]),
      ),
      #("empty", json_value.Array([])),
    ]),
  )
}

pub fn string_escaping_test() {
  assert json_value.parse("\"quote: \\\" slash: \\\\ newline: \\n tab: \\t\"")
    == Ok(json_value.String("quote: \" slash: \\ newline: \n tab: \t"))
  assert json_value.parse("\"\\u00e9\\ud83d\\ude00\"")
    == Ok(json_value.String("é😀"))

  list.each(["", "\"\\\n\r\t", "héllo 世界 😀"], fn(text) {
    let value = json_value.String(text)
    assert value |> json_value.to_string |> json_value.parse == Ok(value)
  })
}

pub fn malformed_json_test() {
  list.each(
    [
      "",
      "[",
      "{\"key\":",
      "[1,]",
      "{\"key\" 1}",
      "\"unterminated",
      "true false",
      "01",
    ],
    fn(input) {
      let assert Error(_) = json_value.parse(input)
      let assert Error(_) = json_value.parse_bits(bit_array.from_string(input))
    },
  )
}

pub fn parse_bits_test() {
  let value = nested_value()
  let bits = value |> json_value.to_string |> bit_array.from_string
  assert json_value.parse_bits(bits) == Ok(value)
  let assert Error(_) = json_value.parse_bits(<<255>>)
}

pub fn serialization_wrappers_test() {
  let value = nested_value()
  assert value |> json_value.to_json |> json.to_string |> json_value.parse
    == Ok(value)
  assert value |> json_value.to_string_tree |> string_tree.to_string
    == json_value.to_string(value)
}

pub fn object_constructor_test() {
  assert json_value.object([]) == json_value.Object(dict.new())
  assert json_value.object([
      #("key", json_value.Int(1)),
      #("key", json_value.Int(2)),
    ])
    == json_value.Object(dict.from_list([#("key", json_value.Int(2))]))
}

pub fn array_constructor_test() {
  assert json_value.array([], json_value.int) == json_value.Array([])
  assert json_value.array([1, 2, 3], fn(n) { json_value.Int(n * 2) })
    == json_value.Array([
      json_value.Int(2),
      json_value.Int(4),
      json_value.Int(6),
    ])
}
