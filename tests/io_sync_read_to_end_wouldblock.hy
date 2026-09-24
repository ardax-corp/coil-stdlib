// Uses `fn main` so `thread::spawn` is wired (harness `test()` cases do not).
use io::{close, IoError};
use io::net::tcp::{accept, connect, listen, local_addr, shutdown};
use io::sync::{write_all, read_to_end};
use thread::{join, spawn};
use clock::{sleep_ms};
use string::{to_bytes, from_bytes};

fn payload() -> Vec<byte> {
    return to_bytes("later!");
}

fn delayed_write(int port) -> int {
    let client = match connect("127.0.0.1", port) {
        Result::Ok(s) => s,
        Result::Err(_) => panic "connect",
    };
    sleep_ms(80);
    match write_all(client, payload()) {
        Result::Ok(_) => 0,
        Result::Err(_) => panic "write",
    };
    match shutdown(client, 1) {
        Result::Ok(_) => 0,
        Result::Err(_) => panic "shutdown",
    };
    match close(client) {
        Result::Ok(_) => 0,
        Result::Err(_) => panic "close",
    };
    return 0;
}

fn main() {
    let listener = match listen("127.0.0.1", 0) {
        Result::Ok(s) => s,
        Result::Err(_) => panic "listen",
    };
    let addr = match local_addr(listener) {
        Result::Ok(v) => v,
        Result::Err(_) => panic "local_addr",
    };
    let t = match spawn(delayed_write, addr[1]) {
        Result::Ok(v) => v,
        Result::Err(_) => panic "spawn",
    };
    sleep_ms(40);
    let server = match accept(listener) {
        Result::Ok(s) => s,
        Result::Err(IoError::WouldBlock) => panic "accept not ready",
        Result::Err(_) => panic "accept",
    };
    let got = match read_to_end(server) {
        Result::Ok(v) => v,
        Result::Err(IoError::WouldBlock) => panic "wouldblock leaked",
        Result::Err(_) => panic "read_to_end",
    };
    let text = match from_bytes(got) {
        Result::Ok(v) => v,
        Result::Err(_) => panic "from_bytes",
    };
    if text != "later!" {
        panic "payload";
    }
    match join(t) {
        Result::Ok(_) => 0,
        Result::Err(_) => panic "join",
    };
    match close(server) {
        Result::Ok(_) => 0,
        Result::Err(_) => panic "close s",
    };
    match close(listener) {
        Result::Ok(_) => 0,
        Result::Err(_) => panic "close l",
    };
}
