//// A JSON value representation that can be used to decode arbitrary JSON into `json_value.Json`
//// that can be manipulated and turned back into JSON again.

import gleam/dict
import gleam/dynamic/decode
import gleam/function
import gleam/json
import gleam/string_tree

pub type Json {
  Null
  String(String)
  Int(Int)
  Bool(Bool)
  Float(Float)
  Array(List(Json))
  Object(dict.Dict(String, Json))
}

/// Decodes a value into an json_value.Json.
pub fn decoder() -> decode.Decoder(Json) {
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

/// Convert a `json_value.Json` value to a `json_value.Json` value.
pub fn to_json(value: Json) -> json.Json {
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
pub fn to_string(value: Json) -> String {
  value
  |> to_json
  |> json.to_string
}

/// Parse a `String` to a `json_value.Json`
pub fn parse(json: String) -> Result(Json, json.DecodeError) {
  json.parse(json, decoder())
}

/// Parse a `BitArray` to a `json_value.Json`
pub fn parse_bits(json: BitArray) -> Result(Json, json.DecodeError) {
  json.parse_bits(json, decoder())
}

/// Convert a `json_value.Json` to a `string_tree.StringTree`
pub fn to_string_tree(value: Json) -> string_tree.StringTree {
  value |> to_json |> json.to_string_tree
}
