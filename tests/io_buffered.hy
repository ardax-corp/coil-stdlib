use tests::assert;
use io::buffered::{Reader, Writer};
use io::file::{write_text, read_text};
use io::fs::remove_file;
use io::{open, close};
use io::net::tcp::{listen, connect, local_addr, shutdown};
use io::sync::{accept_wait};
use string::{to_bytes, from_bytes};
use task::{scope, Scope, sleep};

fn reader_over(string path, string text, int capacity) -> Reader {
    match write_text(path, text) {
        Result::Ok(_) => 0,
        Result::Err(_) => panic "write_text",
    }
    let f = match open(path, "r") {
        Result::Ok(s) => s,
        Result::Err(_) => panic "open",
    };
    return Reader::with_capacity(f, capacity);
}

fn text(Vec<byte> b) -> string {
    return match from_bytes(b) {
        Result::Ok(s) => s,
        Result::Err(_) => "<bad utf-8>",
    };
}

test("read_line across chunk boundaries") {
    // A 3-byte chunk splits every line and the `\r\n`.
    let r = reader_over("/tmp/coil_stdlib_buffered_lines.txt", "alpha\r\nbe\n\ngamma", 3);
    assert!(r.read_line() == Result::Ok(Option::Some("alpha")));
    assert!(r.read_line() == Result::Ok(Option::Some("be")));
    assert!(r.read_line() == Result::Ok(Option::Some("")));
    assert!(r.read_line() == Result::Ok(Option::Some("gamma")));
    assert!(r.read_line() == Result::Ok(Option::None));
    assert!(r.read_line() == Result::Ok(Option::None));
    let _ = remove_file("/tmp/coil_stdlib_buffered_lines.txt");
}

test("read_until keeps the delimiter") {
    let r = reader_over("/tmp/coil_stdlib_buffered_until.txt", "a,bc,d", 2);
    let comma: byte = ",";
    let first = match r.read_until(comma) {
        Result::Ok(Option::Some(b)) => text(b),
        default => "?",
    };
    assert!(first == "a,");
    let second = match r.read_until(comma) {
        Result::Ok(Option::Some(b)) => text(b),
        default => "?",
    };
    assert!(second == "bc,");
    let last = match r.read_until(comma) {
        Result::Ok(Option::Some(b)) => text(b),
        default => "?",
    };
    assert!(last == "d");
    assert!(r.read_until(comma) == Result::Ok(Option::None));
    let _ = remove_file("/tmp/coil_stdlib_buffered_until.txt");
}

test("read_exact, peek and take_buffered") {
    let r = reader_over("/tmp/coil_stdlib_buffered_exact.txt", "headerBODY", 4);
    let head = match r.read_exact(6) {
        Result::Ok(b) => text(b),
        Result::Err(_) => "?",
    };
    assert!(head == "header");
    let peeked = match r.peek(2) {
        Result::Ok(b) => text(b),
        Result::Err(_) => "?",
    };
    assert!(peeked == "BO");
    assert!(r.buffered() >= 2);
    let rest = text(r.take_buffered());
    assert!(r.buffered() == 0);
    let tail = match r.read_to_end() {
        Result::Ok(b) => text(b),
        Result::Err(_) => "?",
    };
    assert!(rest + tail == "BODY");
    let short = match r.read_exact(1) {
        Result::Err(IoError::Truncated) => true,
        default => false,
    };
    assert!(short);
    let _ = remove_file("/tmp/coil_stdlib_buffered_exact.txt");
}

test("read_some returns what is ready") {
    let r = reader_over("/tmp/coil_stdlib_buffered_some.txt", "xyz", 2);
    let a = match r.read_some() {
        Result::Ok(Option::Some(b)) => text(b),
        default => "?",
    };
    let b = match r.read_some() {
        Result::Ok(Option::Some(b)) => text(b),
        default => "?",
    };
    assert!(a + b == "xyz");
    assert!(r.read_some() == Result::Ok(Option::None));
    let _ = remove_file("/tmp/coil_stdlib_buffered_some.txt");
}

test("writer holds bytes until flush") {
    let path = "/tmp/coil_stdlib_buffered_writer.txt";
    let f = match open(path, "w") {
        Result::Ok(s) => s,
        Result::Err(_) => panic "open",
    };
    let w = Writer::with_capacity(f, 4);
    assert!(w.write_str("ab") == Result::Ok(()));
    assert!(w.buffered() == 2);
    // Reaching the capacity writes everything held.
    assert!(w.write(to_bytes("cdef")) == Result::Ok(()));
    assert!(w.buffered() == 0);
    assert!(w.write_str("g") == Result::Ok(()));
    assert!(w.flush() == Result::Ok(()));
    let _ = close(f);
    assert!(read_text(path) == Result::Ok("abcdefg"));
    let _ = remove_file(path);
}

test("reader waits for a slow peer inside a task") {
    let listener = match listen("127.0.0.1", 0) {
        Result::Ok(s) => s,
        Result::Err(_) => panic "listen",
    };
    let port = match local_addr(listener) {
        Result::Ok(a) => a[1],
        Result::Err(_) => panic "local_addr",
    };
    let got = scope(fn (Scope s) use (listener, port) {
        s.spawn(fn () use (port) {
            let c = match connect("127.0.0.1", port) {
                Result::Ok(c) => c,
                Result::Err(_) => panic "connect",
            };
            let w = Writer::new(c);
            let _ = w.write_str("hel");
            let _ = w.flush();
            sleep(20);
            let _ = w.write_str("lo\nworld\n");
            let _ = w.flush();
            let _ = shutdown(c, 1);
            sleep(5);
            let _ = close(c);
        });
        let conn = match accept_wait(listener) {
            Result::Ok(c) => c,
            Result::Err(_) => panic "accept",
        };
        let r = Reader::new(conn);
        let a = r.read_line();
        let b = r.read_line();
        let c = r.read_line();
        let _ = close(conn);
        return a == Result::Ok(Option::Some("hello")) && b == Result::Ok(Option::Some("world")) && c == Result::Ok(Option::None);
    });
    let _ = close(listener);
    assert!(got.unwrap_or(false));
}

test("reader timeout gives TimedOut while the peer is silent") {
    let listener = match listen("127.0.0.1", 0) {
        Result::Ok(s) => s,
        Result::Err(_) => panic "listen",
    };
    let port = match local_addr(listener) {
        Result::Ok(a) => a[1],
        Result::Err(_) => panic "local_addr",
    };
    let got = scope(fn (Scope s) use (listener, port) {
        s.spawn(fn () use (port) {
            let c = match connect("127.0.0.1", port) {
                Result::Ok(c) => c,
                Result::Err(_) => panic "connect",
            };
            sleep(60);
            let w = Writer::new(c);
            let _ = w.write_str("late\n");
            let _ = w.flush();
            let _ = close(c);
        });
        let conn = match accept_wait(listener) {
            Result::Ok(c) => c,
            Result::Err(_) => panic "accept",
        };
        let r = Reader::new(conn);
        r.set_timeout(10);
        let first = r.read_line();
        r.set_timeout(0);
        let second = r.read_line();
        let _ = close(conn);
        let timed_out = match first {
            Result::Err(IoError::TimedOut) => true,
            default => false,
        };
        return timed_out && second == Result::Ok(Option::Some("late"));
    });
    let _ = close(listener);
    assert!(got.unwrap_or(false));
}
