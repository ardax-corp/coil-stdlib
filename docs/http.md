# HTTP/1.1 client (`http`)

Userland request builder (`src/http/`). Cleartext TCP
(`io::net::tcp::connect`) for `http://`; verified TLS
(`tcp::connect` + `io::net::tls::client::enable(..., { verify: true, ca_pem: Option::None, ca_path: Option::None, timeout_ms: 0 })`)
for `https://` — never insecure by default.

Virtual TCP/TLS APIs: [coil-lang `io`](https://github.com/ardax-corp/coil-lang/blob/main/docs/references/io.md).
How to put this package on `[module].roots`: [Consume](consume.md).

## API

```coil
use http::client::{get, post};

fn main() {
    match get("http://127.0.0.1:41250/") {
        Result::Ok(_) => { /* success */ },
        Result::Err(_) => { panic "get failed"; },
    };
}
```

| Function | Role |
|----------|------|
| `get(url)` | `GET` with empty body |
| `post(url, body)` | `POST` with `Vec<byte>` body |
| `request(method, url, headers, body)` | Full builder |
| `status_code(r)` / `body_len(r)` | Result-mode accessors for `Response` |

`Response` carries `status: int`, parallel `header_names` / `header_values`, and
`body: Vec<byte>`. Errors use `HttpError` (`BadUrl`, `BadResponse`,
`UnsupportedScheme`, `Io`).

Requests are HTTP/1.1 with `Host`, `Content-Length`, and `Connection: close`.
Extra headers passed to `request` are written on the wire; attempts to override
`Host` / `Content-Length` / `Connection` (common ASCII spellings such as
`host` / `HOST` / `content-length` / `CONTENT-LENGTH`) are ignored so the
client always emits those itself. Full Unicode/case-fold matching is out of
scope for v1 (`to_bytes` would invalidate live header name slots).

| File | Role |
|------|------|
| `src/http/url.hy` | URL parse, `HttpError`, `Headers`, request build, response parse |
| `src/http/request.hy` | Re-exports `http::url` |
| `src/http/response.hy` | Re-exports `http::url` |
| `src/http/client.hy` | `get` / `post` / `request` (+ `status_code` / `body_len`) |

Impl detail: request/response helpers live in `url.hy` so `client` depends on a
**single** sibling module. Importing overlapping facades that each pull from
`http::url` can hide `url` symbols — prefer one explicit import path.

## Example

Self-contained cleartext demo in the language repo (local server + client):

```bash
# from a coil-lang checkout
./examples/projects/04-http/demo.sh
# ok
```

[04-http showcase](https://github.com/ardax-corp/coil-lang/tree/main/examples/projects/04-http)
(`cd examples/projects/04-http && coil test` for URL/request/response parse, no network).

The HTTPS path uses webpki roots and no handshake deadline by default:

```coil
tls_enable(s, host, { verify: true, ca_pem: Option::None, ca_path: Option::None, timeout_ms: 0 })
```

## Limitations (v1)

- No redirects, cookies, or connection pooling
- No chunked transfer encoding (uses `Content-Length` or read-to-close)
- No HTTP/2 / HTTP/3
- `http::client` requires Coil Cargo feature `tls` (imports `io::net::tls::client`; default-on)
- IPv6 URL literals are not supported — the first `:` before `/` is the port
- HTTPS URLs should use a DNS hostname for SNI / cert name checks; literal-IP
  hosts may fail verification depending on the peer certificate
- Connect failures and TLS errors collapse to `HttpError::Io`; inspect the
  underlying `IoError` only when using raw IO/TLS APIs directly
- No TCP connect or TLS handshake deadline on this client
- CR/LF in URL host/path, method, or header names/values → `HttpError::BadUrl`
- When `Content-Length` exceeds available body bytes → `HttpError::BadResponse`
- HTTPS against public hosts needs a normal PKI trust path; local MITM/dev
  certs need raw `tls::client::enable` with `ca_pem` / `ca_path`
  (`Option::Some(...)` appends to webpki) or `verify: false`; this client
  always verifies with webpki roots (no extras)

### Known compiler note

Request Content-Length formatting uses `body_len_str` / `cl_trailer` lookup
helpers because concatenating `int_to_dec` into the request head under
Result-mode dependency helpers has been flaky (SEGV) on some lengths. This is
a known compiler issue to track — not an HTTP design choice. Prefer `/?q=` over
bare `host?q=` (slash-prefix under Result-mode parse also SEGVs).
