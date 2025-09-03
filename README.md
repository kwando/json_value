# json_value

[![Package Version](https://img.shields.io/hexpm/v/json_value)](https://hex.pm/packages/json_value)
[![Hex Docs](https://img.shields.io/badge/hex-docs-ffaff3)](https://hexdocs.pm/json_value/)

```sh
gleam add json_value@1
```
```gleam
import json_value

pub fn main() -> Nil {
  // decode into json_value.JsonValue value
  let assert Ok(json_data) = json.parse("[1, 2, null]", json_value.decode())

  // convert back to a String
  json_value.to_string(json_data)

  // convert it to a `json.Json` so it can used in another Json structure
  json.object([
    #("data", json_value.to_json(json_data))
  ])
}
```

Further documentation can be found at <https://hexdocs.pm/json_value>.

## Development

```sh
gleam run   # Run the project
gleam test  # Run the tests
```
