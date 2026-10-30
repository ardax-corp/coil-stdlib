// Futures over tasks: `Promise<T>`, `Group<T>` and combinators.
//
// Tasks are stackful, so waiting is already a plain call that suspends: a
// `Task<R>` is the future for work you start. This module adds a value someone
// else sets (`Promise`), tasks taken in completion order (`Group`) and
// combinators over lists of bodies (`all`, `try_all`, `race`, `first_ok`,
// `limit`). Everything runs on the task scheduler natives; nothing here is a
// language feature.
use prelude::task::{task_cond_new, task_cond_wait, task_cond_notify};
use task::{scope, Scope, Task, TaskError, timeout};

// The scheduler's status for a wait no other task can end.
fn __deadlock() -> int {
    return 3;
}

fn __wait_on(int cond) {
    if task_cond_wait(cond) == __deadlock() {
        panic "task deadlock: every task is waiting on another task";
    }
}

/// A one-shot value that some other code sets: the resolver side of a future.
///
/// Make one with `Promise::new`, hand it to whoever will produce the value,
/// and `wait` for it. The first `resolve` wins; every waiter wakes. A promise
/// is not owned by a scope, so it can cross scopes and live in maps (a reply
/// matched to its request by id).
///
/// # Examples
///
/// ```
/// use future::{Promise};
/// use task::{scope, Scope, sleep};
/// # use tests::assert;
/// let r = scope(fn (Scope s) {
///     let p: Promise<int> = Promise::new();
///     s.spawn(fn () use (p) {
///         sleep(1);
///         p.resolve(42);
///     });
///     return p.wait();
/// });
/// assert!(r.unwrap_or(Result::Ok(0)).unwrap_or(0) == 42);
/// ```
shared class Promise<T> {
    pub __value: Option<T>,
    pub __cancelled: bool,
    // Wait condition, made on the first wait that has to suspend; -1 until then.
    pub __cond: int,
}

impl Promise<T> {
    /// A promise with no value yet.
    pub static fn new() -> Promise<T> {
        return new Promise(Option::None, false, -1);
    }

    /// A promise that already holds `value`.
    pub static fn resolved(T value) -> Promise<T> {
        return new Promise(Option::Some(value), false, -1);
    }

    /// Sets the value and wakes every waiter. Returns `false`, and changes
    /// nothing, when the promise was already resolved or cancelled.
    pub fn resolve(T value) -> bool {
        if self.is_done() {
            return false;
        }
        self.__value = Option::Some(value);
        self.__wake();
        return true;
    }

    /// Marks the promise as never getting a value (its producer is gone):
    /// waiters get `Err(TaskError::Cancelled)`. Returns `false` when it was
    /// already resolved or cancelled.
    pub fn cancel() -> bool {
        if self.is_done() {
            return false;
        }
        self.__cancelled = true;
        self.__wake();
        return true;
    }

    /// Waits for the value (a suspension point).
    ///
    /// # Errors
    ///
    /// `Err(TaskError::Cancelled)` once the promise is cancelled.
    ///
    /// # Panics
    ///
    /// Panics on a deadlock: the promise is unresolved and no other task can run.
    pub fn wait() -> Result<T, TaskError> {
        while !self.is_done() {
            if self.__cond < 0 {
                self.__cond = task_cond_new();
            }
            __wait_on(self.__cond);
        }
        return match self.__value {
            Option::Some(v) => Result::Ok(v),
            Option::None => Result::Err(TaskError::Cancelled),
        };
    }

    /// Like `wait`, giving up after `ms` milliseconds.
    ///
    /// # Errors
    ///
    /// `Err(TaskError::TimedOut)` when no value came in time, or
    /// `Err(TaskError::Cancelled)` once the promise is cancelled.
    pub fn wait_timeout(int ms) -> Result<T, TaskError> {
        if self.is_done() {
            return self.wait();
        }
        let p = self;
        return match timeout(ms, fn () use (p) => p.wait()) {
            Result::Ok(r) => r,
            Result::Err(e) => Result::Err(e),
        };
    }

    /// The value if it is set, without waiting.
    pub fn try_get() -> Option<T> {
        return self.__value;
    }

    /// `true` once the promise is resolved or cancelled.
    pub fn is_done() -> bool {
        return self.__value.is_some() || self.__cancelled;
    }

    fn __wake() {
        if self.__cond >= 0 {
            task_cond_notify(self.__cond);
        }
    }
}

/// Tasks of one scope, handed back in the order they finish.
///
/// `Task::join` waits for one particular task; `Group::next` gives whichever
/// finishes next, which is what every "first one wins" or "as they come"
/// pattern needs. A child counts as finished when it returns, panics or is
/// cancelled.
///
/// # Examples
///
/// ```
/// use future::{Group};
/// use task::{scope, Scope, sleep};
/// # use tests::assert;
/// let r = scope(fn (Scope s) {
///     let g: Group<string> = Group::new(s);
///     g.spawn(fn () {
///         sleep(50);
///         return "slow";
///     });
///     g.spawn(fn () {
///         sleep(1);
///         return "fast";
///     });
///     let first = match g.next() {
///         Option::Some(t) => t.join().unwrap_or(""),
///         Option::None => "",
///     };
///     g.cancel_all();
///     return first;
/// });
/// assert!(r.unwrap_or("") == "fast");
/// ```
shared class Group<T> {
    pub __scope: Scope,
    pub __tasks: Vec<Task<T>>,
    // Indices of finished children, oldest first; `__head` is the next to hand out.
    pub __done: Vec<int>,
    pub __head: int,
    pub __cond: int,
}

// Runs a child body and reports its index however it ends.
fn __group_run<T>(Group<T> g, int idx, unit -> T body) -> T {
    defer use (g, idx) {
        g.__finished(idx);
    }
    return body();
}

impl Group<T> {
    /// An empty group whose children run in scope `s`.
    pub static fn new(Scope s) -> Group<T> {
        let tasks: Vec<Task<T>> = Vec::new();
        let done: Vec<int> = Vec::new();
        return new Group(s, tasks, done, 0, task_cond_new());
    }

    /// Starts `body` as a child task of the group's scope.
    pub fn spawn(unit -> T body) -> Task<T> {
        let g = self;
        let idx = self.__tasks.len();
        let t = self.__scope.spawn(fn () use (g, idx, body) => __group_run(g, idx, body));
        self.__tasks.push(t);
        return t;
    }

    /// Waits for the next child to finish and returns it; `None` once every
    /// child has been returned. `join` on the result does not wait.
    ///
    /// # Panics
    ///
    /// Panics on a deadlock: children are pending and none can run.
    pub fn next() -> Option<Task<T>> {
        return match self.next_index() {
            Option::Some(i) => Option::Some(self.__tasks[i]),
            Option::None => Option::None,
        };
    }

    /// Like `next`, giving the child's position in spawn order instead.
    pub fn next_index() -> Option<int> {
        if self.__head == self.__tasks.len() {
            return Option::None;
        }
        while self.__head == self.__done.len() {
            __wait_on(self.__cond);
        }
        let i = self.__done[self.__head];
        self.__head = self.__head + 1;
        return Option::Some(i);
    }

    /// The child started `i`-th (from 0).
    pub fn task(int i) -> Task<T> {
        return self.__tasks[i];
    }

    /// Number of children started.
    pub fn len() -> int {
        return self.__tasks.len();
    }

    /// Number of children `next` has not returned yet.
    pub fn pending() -> int {
        return self.__tasks.len() - self.__head;
    }

    /// Cancels every child that has not finished. Each one unwinds at its
    /// next suspension point, running its `defer`s, and still comes out of
    /// `next`.
    pub fn cancel_all() {
        for t in self.__tasks {
            t.cancel();
        }
    }

    /// Records that child `idx` finished (called from its `defer`).
    pub fn __finished(int idx) {
        self.__done.push(idx);
        task_cond_notify(self.__cond);
    }
}

fn __flatten<T>(Result<Result<T, TaskError>, TaskError> r) -> Result<T, TaskError> {
    return match r {
        Result::Ok(inner) => inner,
        Result::Err(e) => Result::Err(e),
    };
}

/// Runs every body concurrently and returns their results in input order.
///
/// A panicking body fails the whole call (`Err(TaskError::Panicked)`), as a
/// panic fails its scope; a body's own errors are values (`T` may be a
/// `Result`, see `try_all`).
///
/// # Examples
///
/// ```
/// use future::{all};
/// # use tests::assert;
/// let bodies: Vec<unit -> int> = Vec::new();
/// bodies.push(fn () => 1);
/// bodies.push(fn () => 2);
/// let ok = match all(bodies) {
///     Result::Ok(out) => out.len() == 2 && out[0] == 1 && out[1] == 2,
///     Result::Err(_) => false,
/// };
/// assert!(ok);
/// ```
fn all<T>(Vec<unit -> T> bodies) -> Result<Vec<T>, TaskError> {
    return limit(bodies.len(), bodies);
}

/// Like `all`, with at most `n` bodies running at once (`n` at least 1).
/// The next body starts as soon as a running one finishes.
///
/// # Panics
///
/// Panics when `n` is less than 1.
fn limit<T>(int n, Vec<unit -> T> bodies) -> Result<Vec<T>, TaskError> {
    if n < 1 && bodies.len() > 0 {
        panic "future::limit needs n of at least 1";
    }
    let r = scope(fn (Scope s) use (n, bodies) {
        let g: Group<T> = Group::new(s);
        let slots: Vec<Option<T>> = Vec::new();
        for b in bodies {
            slots.push(Option::None);
        }
        let started = 0;
        while started < n && started < bodies.len() {
            g.spawn(bodies[started]);
            started = started + 1;
        }
        while let Option::Some(i) = g.next_index() {
            match g.task(i).join() {
                Result::Ok(v) => {
                    slots[i] = Option::Some(v);
                },
                Result::Err(e) => {
                    g.cancel_all();
                    return Result::Err(e);
                },
            }
            if started < bodies.len() {
                g.spawn(bodies[started]);
                started = started + 1;
            }
        }
        let out: Vec<T> = Vec::new();
        for slot in slots {
            match slot {
                Option::Some(v) => {
                    out.push(v);
                },
                Option::None => {
                    panic "future::limit: a body left no result";
                },
            }
        }
        return Result::Ok(out);
    });
    return __flatten(r);
}

/// Runs bodies that return `Result` and collects their `Ok` values in input
/// order. The first `Err` cancels the bodies still running and is returned.
///
/// # Panics
///
/// A panicking body is a bug, not an outcome: it fails the call with the same
/// message.
///
/// # Examples
///
/// ```
/// use future::{try_all};
/// # use tests::assert;
/// let bodies: Vec<unit -> Result<int, string>> = Vec::new();
/// bodies.push(fn () => Result::Ok(1));
/// bodies.push(fn () => Result::Err("no"));
/// assert!(try_all(bodies) == Result::Err("no"));
/// ```
fn try_all<T, E>(Vec<unit -> Result<T, E>> bodies) -> Result<Vec<T>, E> {
    let r = scope(fn (Scope s) use (bodies) {
        let g: Group<Result<T, E>> = Group::new(s);
        let slots: Vec<Option<T>> = Vec::new();
        for b in bodies {
            slots.push(Option::None);
            g.spawn(b);
        }
        while let Option::Some(i) = g.next_index() {
            match g.task(i).join() {
                Result::Ok(Result::Ok(v)) => {
                    slots[i] = Option::Some(v);
                },
                Result::Ok(Result::Err(e)) => {
                    g.cancel_all();
                    return Result::Err(e);
                },
                Result::Err(e) => {
                    g.cancel_all();
                    __repanic(e);
                },
            }
        }
        let out: Vec<T> = Vec::new();
        for slot in slots {
            match slot {
                Option::Some(v) => {
                    out.push(v);
                },
                Option::None => {
                    panic "future::try_all: a body left no result";
                },
            }
        }
        return Result::Ok(out);
    });
    return match r {
        Result::Ok(x) => x,
        Result::Err(e) => {
            __repanic(e);
            panic "unreachable";
        },
    };
}

/// Runs every body and returns the first to finish; the others are
/// cancelled (they unwind, running their `defer`s).
///
/// # Errors
///
/// The first finisher's `TaskError` when it did not produce a value.
///
/// # Panics
///
/// Panics when `bodies` is empty.
///
/// # Examples
///
/// ```
/// use future::{race};
/// use task::{sleep};
/// # use tests::assert;
/// let bodies: Vec<unit -> string> = Vec::new();
/// bodies.push(fn () {
///     sleep(50);
///     return "slow";
/// });
/// bodies.push(fn () => "fast");
/// let winner = race(bodies);
/// assert!(winner.unwrap_or("") == "fast");
/// ```
fn race<T>(Vec<unit -> T> bodies) -> Result<T, TaskError> {
    if bodies.len() == 0 {
        panic "future::race needs at least one body";
    }
    let r = scope(fn (Scope s) use (bodies) {
        let g: Group<T> = Group::new(s);
        for b in bodies {
            g.spawn(b);
        }
        let first = match g.next() {
            Option::Some(t) => t.join(),
            Option::None => Result::Err(TaskError::Cancelled),
        };
        g.cancel_all();
        return first;
    });
    return __flatten(r);
}

/// Runs bodies that return `Result` and returns the first `Ok`, cancelling
/// the rest. When every body fails, returns all the errors in input order.
///
/// # Panics
///
/// A panicking body fails the call with the same message.
///
/// # Examples
///
/// ```
/// use future::{first_ok};
/// # use tests::assert;
/// let bodies: Vec<unit -> Result<int, string>> = Vec::new();
/// bodies.push(fn () => Result::Err("down"));
/// bodies.push(fn () => Result::Ok(7));
/// assert!(first_ok(bodies).unwrap_or(0) == 7);
/// ```
fn first_ok<T, E>(Vec<unit -> Result<T, E>> bodies) -> Result<T, Vec<E>> {
    let r = scope(fn (Scope s) use (bodies) {
        let g: Group<Result<T, E>> = Group::new(s);
        let errs: Vec<Option<E>> = Vec::new();
        for b in bodies {
            errs.push(Option::None);
            g.spawn(b);
        }
        while let Option::Some(i) = g.next_index() {
            match g.task(i).join() {
                Result::Ok(Result::Ok(v)) => {
                    g.cancel_all();
                    return Result::Ok(v);
                },
                Result::Ok(Result::Err(e)) => {
                    errs[i] = Option::Some(e);
                },
                Result::Err(e) => {
                    g.cancel_all();
                    __repanic(e);
                },
            }
        }
        let out: Vec<E> = Vec::new();
        for slot in errs {
            match slot {
                Option::Some(e) => {
                    out.push(e);
                },
                Option::None => {},
            }
        }
        return Result::Err(out);
    });
    return match r {
        Result::Ok(x) => x,
        Result::Err(e) => {
            __repanic(e);
            panic "unreachable";
        },
    };
}

// A child that did not produce a value inside a combinator whose result type
// has no room for it: a panic stays a panic, anything else names the cause.
fn __repanic(TaskError e) {
    match e {
        TaskError::Panicked(m) => {
            panic m;
        },
        TaskError::Cancelled => {
            panic "future: a body was cancelled";
        },
        TaskError::TimedOut => {
            panic "future: a body timed out";
        },
    }
}
