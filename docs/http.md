# HTTP moved to coil-http

The function-oriented HTTP/1.1 client (`src/http/`) has moved to
**[ardax-corp/coil-http](https://github.com/ardax-corp/coil-http)** with class-oriented
`Client` and `Server` APIs.

## Migrate

```toml
[dependencies]
http = { git = "https://github.com/ardax-corp/coil-http.git", version = "^0.1" }

[module]
roots = ["./src", "./.spool/deps/http", "../coil-stdlib/src"]
```

```coil
use http::{Client, Server, Request, Response};

fn main() {
    let client = Client::new();
    let r = client.get("http://example.com/")?;
}
```

See [coil-http docs](https://github.com/ardax-corp/coil-http/blob/main/docs/README.md).
