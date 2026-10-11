# coil-stdlib docs

Userland `.hy` library for [Coil](https://github.com/ardax-corp/coil-lang).
Language builtins and virtual modules stay in the
[Coil references](https://github.com/ardax-corp/coil-website/tree/main/src/content/docs/references).

| Page | Contents |
|------|----------|
| [Consume](consume.md) | `spool` / path / language-repo submodule |
| [Modules](modules.md) | Catalog of `use` paths |
| [IO adapters](io.md) | `io::sync` and `io::file` |
| [JSON](codec.md) | [coil-json](https://github.com/ardax-corp/coil-json) — not in-tree `codec::json` |

HTTP is [coil-http](https://github.com/ardax-corp/coil-http) — install via spool.
JSON is [coil-json](https://github.com/ardax-corp/coil-json) — `spool add json --git … --rev …` or a sibling `--root`; see [JSON](codec.md).

Language tutorials that *use* these modules (virtual `io` + adapters):
[IO streams](https://github.com/ardax-corp/coil-website/blob/main/src/content/docs/manual/tutorial/10-io-streams.md).
