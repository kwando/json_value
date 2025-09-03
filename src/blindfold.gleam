//// A JSON value representation that can be used to decode arbitrary JSON structures.

import gleam/dict
import gleam/dynamic/decode
import gleam/json
import gleam/list
import gleam/pair

/// A JSON value representation that can be used to decode arbitrary JSON structures.
pub opaque type Value {
  JsonNull
  JsonString(String)
  JsonInt(Int)
  JsonBool(Bool)
  JsonFloat(Float)
  JsonArray(List(Value))
  JsonObject(dict.Dict(String, Value))
}

pub fn decode() {
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

pub fn to_json(value: Value) {
  case value {
    JsonString(s) -> json.string(s)
    JsonInt(i) -> json.int(i)
    JsonBool(b) -> json.bool(b)
    JsonFloat(f) -> json.float(f)
    JsonArray(arr) -> json.array(arr, to_json)
    JsonObject(obj) ->
      json.object(dict.to_list(obj) |> list.map(pair.map_second(_, to_json)))
    JsonNull -> json.null()
  }
}
