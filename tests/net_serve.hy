use tests::assert;
use cell::Ref;
use net::{serve};
use io::buffered::{Reader, Writer};
use io::{close};
use io::net::tcp::{listen, connect, local_addr, shutdown};
use task::{scope, Scope, Task, sleep};

fn echo_client(int port, string msg) -> string {
    let c = match connect("127.0.0.1", port) {
        Result::Ok(c) => c,
        Result::Err(_) => panic "connect",
    };
    let w = Writer::new(c);
    let _ = w.write_str(msg + "\n");
    let _ = w.flush();
    let r = Reader::new(c);
    let reply = match r.read_line() {
        Result::Ok(Option::Some(l)) => l,
        default => "?",
    };
    let _ = close(c);
    return reply;
}

test("serve runs a handler per connection and caps concurrency") {
    let listener = match listen("127.0.0.1", 0) {
        Result::Ok(s) => s,
        Result::Err(_) => panic "listen",
    };
    let port = match local_addr(listener) {
        Result::Ok(a) => a[1],
        Result::Err(_) => panic "local_addr",
    };
    let running = Ref::new(0);
    let peak = Ref::new(0);
    let replies = Ref::new("");
    let out = scope(fn (Scope s) use (listener, port, running, peak, replies) {
        let server = s.spawn(fn () use (listener, running, peak) {
            return serve(listener, 2, fn (Stream conn) use (running, peak) {
                let now = running.update(fn (int n) => n + 1);
                if now > peak.get() {
                    peak.set(now);
                }
                let r = Reader::new(conn);
                let line = match r.read_line() {
                    Result::Ok(Option::Some(l)) => l,
                    default => "",
                };
                sleep(5);
                let w = Writer::new(conn);
                let _ = w.write_str("echo " + line + "\n");
                let _ = w.flush();
                running.update(fn (int n) => n - 1);
            });
        });
        let clients: Vec<Task<string>> = Vec::new();
        let i = 0;
        while i < 5 {
            let k = i;
            clients.push(s.spawn(fn () use (port, k) => echo_client(port, k.show())));
            i = i + 1;
        }
        let all_ok = true;
        let j = 0;
        for c in clients {
            if c.join().unwrap_or("") != "echo " + j.show() {
                all_ok = false;
            }
            j = j + 1;
        }
        let _ = close(listener);
        let served = match server.join() {
            Result::Ok(Result::Ok(n)) => n,
            default => -1,
        };
        return all_ok && served == 5;
    });
    assert!(out.unwrap_or(false));
    assert!(peak.get() <= 2);
    assert!(peak.get() >= 1);
}
