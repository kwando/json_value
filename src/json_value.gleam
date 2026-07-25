//// A JSON value representation that can be used to decode arbitrary JSON into `json_value.JsonValue`
//// that can be manipulated and turned back into JSON again.

import gleam/dict
import gleam/dynamic/decode
import gleam/function
import gleam/json
import gleam/list
import gleam/string_tree

pub type JsonValue {
  Null
  String(String)
  Int(Int)
  Bool(Bool)
  Float(Float)
  Array(List(JsonValue))
  Object(dict.Dict(String, JsonValue))
}

/// Decodes a value into an json_value.Json.
pub fn decoder() -> decode.Decoder(JsonValue) {
  use <- decode.recursive
  decode.one_of(decode.string |> decode.map(String), [
    decode.int |> decode.map(Int),
    decode.bool |> decode.map(Bool),
    decode.float |> decode.map(Float),
    decode.list(decoder()) |> decode.map(Array),
    decode.dict(decode.string, decoder())
      |> decode.map(Object),
    decode.success(Null),
  ])
}

/// Convert a `JsonValue` to a `json.Json` value.
pub fn to_json(value: JsonValue) -> json.Json {
  case value {
    String(s) -> json.string(s)
    Int(i) -> json.int(i)
    Bool(b) -> json.bool(b)
    Float(f) -> json.float(f)
    Array(arr) -> json.array(arr, to_json)
    Object(obj) -> json.dict(obj, function.identity, to_json)
    Null -> json.null()
  }
}

// These are just convenience wrappers around the functions from the JSON module
/// Convert a `json_value.Json` to a JSON string.
pub fn to_string(value: JsonValue) -> String {
  value |> to_json |> json.to_string
}

/// Parse a `String` to a `json_value.Json`
pub fn parse(json: String) -> Result(JsonValue, json.DecodeError) {
  json.parse(json, decoder())
}

/// Parse a `BitArray` to a `json_value.Json`
pub fn parse_bits(json: BitArray) -> Result(JsonValue, json.DecodeError) {
  json.parse_bits(json, decoder())
}

/// Convert a `json_value.Json` to a `string_tree.StringTree`
pub fn to_string_tree(value: JsonValue) -> string_tree.StringTree {
  value |> to_json |> json.to_string_tree
}

/// Create a JSON object from a list of key-value pairs.
pub fn object(entries: List(#(String, JsonValue))) -> JsonValue {
  Object(dict.from_list(entries))
}

/// Create a JSON array by mapping a list of values into `JsonValue`s.
pub fn array(values: List(a), mapper: fn(a) -> JsonValue) -> JsonValue {
  Array(list.map(values, mapper))
}

/// A `JsonValue` representing an integer.
pub const int = Int

/// A `JsonValue` representing a float.
pub const float = Float

/// A `JsonValue` representing a boolean.
pub const bool = Bool

/// A `JsonValue` representing `null`.
pub const null = Null

/// A `JsonValue` representing a string.
pub const string = String
