use path::{Path};

test("join dirname basename extension") {
    let a = Path::from("a");
    let b = Path::from("b");
    let j = match a.join(b) {
        Result::Ok(p) => p,
        Result::Err(_) => panic "join",
    };
    assert(j.as_str() == "a/b")?;
    let a2 = Path::from("a/");
    let j2 = match a2.join(b) {
        Result::Ok(p) => p,
        Result::Err(_) => panic "join2",
    };
    assert(j2.as_str() == "a/b")?;
    let d = match Path::from("/tmp/x").dirname() {
        Result::Ok(p) => p,
        Result::Err(_) => panic "dirname",
    };
    assert(d.as_str() == "/tmp")?;
    let base = match Path::from("/tmp/x.txt").basename() {
        Result::Ok(s) => s,
        Result::Err(_) => panic "basename",
    };
    assert(base == "x.txt")?;
    let e = match Path::from("/tmp/x.txt").extension() {
        Result::Ok(s) => s,
        Result::Err(_) => panic "ext",
    };
    assert(e == "txt")?;
    assert(Path::from("/tmp").is_absolute())?;
    assert(Path::from("rel").is_absolute() == false)?;
}

test("join empty sides") {
    let j = match Path::from("a").join(Path::from("")) {
        Result::Ok(p) => p,
        Result::Err(_) => panic "join empty b",
    };
    assert(j.as_str() == "a")?;
    let j2 = match Path::from("").join(Path::from("b")) {
        Result::Ok(p) => p,
        Result::Err(_) => panic "join empty a",
    };
    assert(j2.as_str() == "b")?;
}

test("dirname basename extension edges") {
    let d = match Path::from("plain").dirname() {
        Result::Ok(p) => p,
        Result::Err(_) => panic "dirname plain",
    };
    assert(d.as_str() == ".")?;
    let b = match Path::from("plain").basename() {
        Result::Ok(s) => s,
        Result::Err(_) => panic "basename plain",
    };
    assert(b == "plain")?;
    let e = match Path::from("noext").extension() {
        Result::Ok(s) => s,
        Result::Err(_) => panic "extension none",
    };
    assert(e == "")?;
    let root = match Path::from("/").dirname() {
        Result::Ok(p) => p,
        Result::Err(_) => panic "dirname root",
    };
    assert(root.as_str() == "/")?;
    let trailing = match Path::from("/tmp/x/").basename() {
        Result::Ok(s) => s,
        Result::Err(_) => panic "basename trailing",
    };
    assert(trailing == "x")?;
    let dot = match Path::from("file.").extension() {
        Result::Ok(s) => s,
        Result::Err(_) => panic "extension empty",
    };
    assert(dot == "")?;
}

test("normalize and components") {
    let n = match Path::from("/a/./b/../c").normalize() {
        Result::Ok(p) => p,
        Result::Err(_) => panic "normalize",
    };
    assert(n.as_str() == "/a/c")?;
    let rel = match Path::from("a/b/../..").normalize() {
        Result::Ok(p) => p,
        Result::Err(_) => panic "normalize rel",
    };
    assert(rel.as_str() == ".")?;
    let empty = match Path::from("").normalize() {
        Result::Ok(p) => p,
        Result::Err(_) => panic "normalize empty",
    };
    assert(empty.as_str() == ".")?;
    let mixed = match Path::from("a\\b/../c").normalize() {
        Result::Ok(p) => p,
        Result::Err(_) => panic "normalize slash",
    };
    assert(mixed.as_str() == "a/c")?;
    let parts = match Path::from("/a/b").components() {
        Result::Ok(v) => v,
        Result::Err(_) => panic "components",
    };
    assert(len(parts) == 2)?;
    assert(parts[0] == "a")?;
    assert(parts[1] == "b")?;
}

test("join both seps and windows absolute") {
    let j = match Path::from("a/").join(Path::from("/b")) {
        Result::Ok(p) => p,
        Result::Err(_) => panic "join seps",
    };
    assert(j.as_str() == "a/b")?;
    assert(Path::from("C:/x").is_absolute())?;
    assert(Path::from("c:\\x").is_absolute())?;
    assert(Path::from("1:/x").is_absolute() == false)?;
}

test("path append text roundtrip") {
    let p = Path::from("/tmp/coil_stdlib_path_append.txt");
    match p.write_text("ab") {
        Result::Ok(_) => 0,
        Result::Err(_) => panic "write_text",
    };
    match p.append_text("cd") {
        Result::Ok(_) => 0,
        Result::Err(_) => panic "append_text",
    };
    let t = match p.read_text() {
        Result::Ok(s) => s,
        Result::Err(_) => panic "read_text",
    };
    assert(t == "abcd")?;
    match p.remove_file() {
        Result::Ok(_) => 0,
        Result::Err(_) => panic "remove",
    };
}
