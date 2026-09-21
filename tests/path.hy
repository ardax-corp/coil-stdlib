use path::{Path};

test("join dirname basename extension") {
    let a = Path::from("a");
    let b = Path::from("b");
    // Path ops are infallible on UTF-8 we build; Result<Path, IoError> niche match was Err.
    let j = a.join(b);
    assert(j.as_str() == "a/b")?;
    let a2 = Path::from("a/");
    let j2 = a2.join(Path::from("b"));
    assert(j2.as_str() == "a/b")?;
    let d = Path::from("/tmp/x").dirname();
    assert(d.as_str() == "/tmp")?;
    let base = Path::from("/tmp/x.txt").basename();
    assert(base == "x.txt")?;
    let e = Path::from("/tmp/x.txt").extension();
    assert(e == "txt")?;
    assert(Path::from("/tmp").is_absolute())?;
    assert(Path::from("rel").is_absolute() == false)?;
}

test("join empty sides") {
    let j = Path::from("a").join(Path::from(""));
    assert(j.as_str() == "a")?;
    let j2 = Path::from("").join(Path::from("b"));
    assert(j2.as_str() == "b")?;
}

test("dirname basename extension edges") {
    let d = Path::from("plain").dirname();
    assert(d.as_str() == ".")?;
    let b = Path::from("plain").basename();
    assert(b == "plain")?;
    let e = Path::from("noext").extension();
    assert(e == "")?;
    let root = Path::from("/").dirname();
    assert(root.as_str() == "/")?;
}
