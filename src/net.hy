// Connection loops over `io::net::tcp`.
use io::close;
use io::sync::{accept_wait};
use task::{scope, Scope, Channel, channel, TaskError};

/// Accepts connections on `listener` and runs `handler` on each one in its
/// own task, with at most `max` running at once (at least 1). Each
/// connection is closed when its handler returns.
///
/// Runs until `accept` fails, then waits for the running handlers and
/// returns the number of connections served. Closing the listener (from a
/// handler or another task) stops it: that ends with `Ok`.
///
/// # Errors
///
/// The `accept` error, other than the listener being closed.
///
/// # Panics
///
/// A panicking handler is a bug: it fails the whole call with the same
/// message, as a panic fails its `scope`.
fn serve(Stream listener, int max, Stream -> unit handler) -> Result<int, IoError> {
    let cap = max;
    if cap < 1 {
        cap = 1;
    }
    let r = scope(fn (Scope s) use (listener, cap, handler) {
        // One slot per running handler: a full channel holds the accept loop.
        let slots: Channel<int> = channel(cap);
        let served = 0;
        while true {
            let conn = match accept_wait(listener) {
                Result::Ok(c) => c,
                Result::Err(IoError::AlreadyClosed) => {
                    return Result::Ok(served);
                },
                Result::Err(e) => {
                    return Result::Err(e);
                },
            };
            let _ = slots.send(served);
            served = served + 1;
            s.spawn(fn () use (slots, conn, handler) => __serve_one(slots, conn, handler));
        }
        return Result::Ok(served);
    });
    return match r {
        Result::Ok(x) => x,
        Result::Err(TaskError::Panicked(m)) => {
            panic m;
        },
        Result::Err(_) => Result::Err(IoError::Other),
    };
}

fn __serve_one(Channel<int> slots, Stream conn, Stream -> unit handler) {
    defer use (slots, conn) {
        let _ = close(conn);
        let _ = slots.try_recv();
    }
    handler(conn);
}
