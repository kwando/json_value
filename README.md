# opaq

[![Package Version](https://img.shields.io/hexpm/v/opaq)](https://hex.pm/packages/opaq)
[![Hex Docs](https://img.shields.io/badge/hex-docs-ffaff3)](https://hexdocs.pm/opaq/)

```sh
gleam add opaq@1
```
```gleam
import opaq

pub fn main() -> Nil {
  // decode into opaque JSON value
  let assert Ok(json_value) = json.parse("[1, 2, null]", opaq.decode())

  // convert back to a String
  opaq.to_string(json_value)
}
```

Further documentation can be found at <https://hexdocs.pm/opaq>.

## Development

```sh
gleam run   # Run the project
gleam test  # Run the tests
```
