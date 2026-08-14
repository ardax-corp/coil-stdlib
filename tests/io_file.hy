use io::file::{read_text, write_text, append_text, read_bytes, append_bytes};
use io::fs::{exists, remove_file};
use string::{to_bytes};
use bytes::{eq};

test("read write text roundtrip") {
    let path = "/tmp/coil_stdlib_file_test.txt";
    match write_text(path, "hello") {
        Result::Ok(_) => 0,
        Result::Err(_) => panic "write_text",
    };
    let ex = match exists(path) {
        Result::Ok(v) => v,
        Result::Err(_) => panic "exists",
    };
    assert(ex)?;
    let t = match read_text(path) {
        Result::Ok(s) => s,
        Result::Err(_) => panic "read_text",
    };
    assert(t == "hello")?;
    match remove_file(path) {
        Result::Ok(_) => 0,
        Result::Err(_) => panic "remove",
    };
}

test("append text and bytes") {
    let path = "/tmp/coil_stdlib_file_append.txt";
    match write_text(path, "ab") {
        Result::Ok(_) => 0,
        Result::Err(_) => panic "write",
    };
    match append_text(path, "cd") {
        Result::Ok(_) => 0,
        Result::Err(_) => panic "append_text",
    };
    let t = match read_text(path) {
        Result::Ok(s) => s,
        Result::Err(_) => panic "read after append",
    };
    assert(t == "abcd")?;
    match append_bytes(path, to_bytes("ef")) {
        Result::Ok(_) => 0,
        Result::Err(_) => panic "append_bytes",
    };
    let got = match read_bytes(path) {
        Result::Ok(v) => v,
        Result::Err(_) => panic "read_bytes",
    };
    assert(eq(got, to_bytes("abcdef")))?;
    match remove_file(path) {
        Result::Ok(_) => 0,
        Result::Err(_) => panic "remove",
    };
}
