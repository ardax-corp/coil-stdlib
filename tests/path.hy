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
}
