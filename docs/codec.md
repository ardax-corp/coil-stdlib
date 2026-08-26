# JSON (coil-json)

JSON parse/stringify is not in this package. It lives in
[coil-json](https://github.com/ardax-corp/coil-json)
(`use json::{Json, JsonValue, JsonError};`).

There is no in-tree `codec::json`. This package does not re-export `json`
and must not `use json`.

Walkthrough: [coil-json consume.md](https://github.com/ardax-corp/coil-json/blob/main/docs/consume.md).

## Depend

There is no public `spool` CLI. Do not `spool add json`. Until
[COI-219](https://linear.app/ardax/issue/COI-219), use a sibling root or a
`{ git }` dep plus a `coil.lock` pin (`rev` + `content_hash`).

Sibling checkout:

```toml
[module]
roots = ["./src", "../coil-json/src", "../coil-stdlib/src"]
```

Git dep (`version` is optional schema, not a tag):

```toml
[dependencies]
json = { git = "https://github.com/ardax-corp/coil-json.git" }

[module]
roots = ["./src", "./.spool/deps/json/src", "../coil-stdlib/src"]
```

```
# spool lockfile v1
[[package]]
name = 'json'
git = 'https://github.com/ardax-corp/coil-json.git'
rev = '<commit SHA>'
content_hash = '<tree SHA>'
```

`rev` is the commit. `content_hash` is that commit's git tree
(`git rev-parse 'HEAD^{tree}'`). The compiler does not read `coil.lock`
and does not inject roots. Native `[ffi] search_paths` are documented in
the consume walkthrough.

## Call

`Json::strict()` is RFC 8259 one-shot encode/decode.
`Json::jsonc()` is parse-only: comments and trailing commas on decode.
Encode stays RFC 8259. Not JSON5.

```coil
use json::{Json, JsonValue, JsonError};

let j = Json::strict();
let v = j.decode_str("{\"a\":[1,true,null],\"b\":\"x\"}")?;
let s = j.encode_str(v)?;
let bytes = j.encode(v)?;
```

`JsonValue` / `JsonError` and the rest of the call surface are in the
consume walkthrough. This page does not re-document them.

## HTTP bodies

[coil-http](https://github.com/ardax-corp/coil-http) keeps request bodies as
`Vec<byte>`. Encode in the app, then post. Not a client-core change.

```coil
use json::{Json, JsonValue, JsonError};
use http::client::{Client};

let j = Json::strict();
let body = j.encode(v)?;
let c = Client::new();
c.post(url, body)?;
```
