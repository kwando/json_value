# json_value

[![Package Version](https://img.shields.io/hexpm/v/json_value)](https://hex.pm/packages/json_value)
[![Hex Docs](https://img.shields.io/badge/hex-docs-ffaff3)](https://hexdocs.pm/json_value/)

```sh
gleam add json_value@1
```
```gleam
import gleam/json
import json_value

pub fn main() -> json.Json {
  // decode into json_value.JsonValue value
  let assert Ok(json_data) = json_value.parse("[1, 2, null]")

  // convert back to a String
  json_value.to_string(json_data)

  // convert it to a `json.Json` so it can used in another Json structure
  json.object([
    #("data", json_value.to_json(json_data))
  ])
}
```

Further documentation can be found at <https://hexdocs.pm/json_value>.

## Numbers across targets

On Erlang, parsing `1` produces `Int(1)`, while `1.0` and `1e0` produce
`Float(1.0)`. On JavaScript, all three produce `Int(1)`: its JSON parser uses
one number type and does not preserve the original number syntax.
Non-integral numbers, such as `1.5`, decode as `Float` on both targets.

Consequently, serializing and parsing a value such as `Float(1.0)` on
JavaScript returns `Int(1)`, not the original `Float` variant.

## Development

```sh
gleam test                       # Run the tests on Erlang
gleam test --target javascript   # Run the tests on JavaScript
```
