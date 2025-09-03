//// A JSON value representation that can be used to decode arbitrary JSON into an json_valueue value
//// that can be turned back into JSON again.
////
//// Sometimes you have a JSON value but it is json_valueue to your application.

import gleam/dict
import gleam/dynamic/decode
import gleam/function
import gleam/json

pub type Json {
  JsonNull
  JsonString(String)
  JsonInt(Int)
  JsonBool(Bool)
  JsonFloat(Float)
  JsonArray(List(Json))
  JsonObject(dict.Dict(String, Json))
}

/// Decodes a value into an opaque JSON value.
pub fn decode() -> decode.Decoder(Json) {
  use <- decode.recursive
  decode.one_of(decode.failure(JsonNull, "no json"), [
    decode.string |> decode.map(JsonString),
    decode.int |> decode.map(JsonInt),
    decode.bool |> decode.map(JsonBool),
    decode.float |> decode.map(JsonFloat),
    decode.list(decode()) |> decode.map(JsonArray),
    decode.dict(decode.string, decode())
      |> decode.map(JsonObject),
    decode.success(JsonNull),
  ])
}

/// Convert a `opaq.Json` value to a `json.Json` value.
pub fn to_json(value: Json) -> json.Json {
  case value {
    JsonString(s) -> json.string(s)
    JsonInt(i) -> json.int(i)
    JsonBool(b) -> json.bool(b)
    JsonFloat(f) -> json.float(f)
    JsonArray(arr) -> json.array(arr, to_json)
    JsonObject(obj) -> json.dict(obj, function.identity, to_json)
    JsonNull -> json.null()
  }
}

/// Convert a `opaq.Json` to a JSON string.
pub fn to_string(value: Json) -> String {
  value
  |> to_json
  |> json.to_string
}
