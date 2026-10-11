# JSON (coil-json)

JSON parse/stringify is not in this package. It lives in
[coil-json](https://github.com/ardax-corp/coil-json)
(`use json::{Json, JsonValue, JsonError};`).

There is no in-tree `codec::json`. This package does not re-export `json`
and must not `use json`.

Walkthrough: [coil-json consume.md](https://github.com/ardax-corp/coil-json/blob/main/docs/consume.md).

## Depend

With [spool](https://github.com/ardax-corp/spool):

```bash
spool add json --git https://github.com/ardax-corp/coil-json.git --rev <commit SHA>
```

spool records the dependency in `coil.toml`, pins it in `coil.lock`, and
passes the `--root` flags to `coil`. The compiler reads neither file.

Without spool, use a sibling checkout and pass the roots yourself:

```bash
coil --root ../coil-json/src --root ../coil-stdlib/src main.hy
```

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
