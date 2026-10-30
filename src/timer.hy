// Timers as values over `task::sleep` and the monotonic clock.
use clock::{mono_nanos};
use task::{sleep};

fn __ns_per_ms() -> int {
    return 1000000;
}

/// Suspends the current task until the monotonic clock (`clock::mono_nanos`)
/// reaches `deadline`; returns at once when it already has.
///
/// # Examples
///
/// ```
/// use timer::{sleep_until};
/// use clock::{mono_nanos};
/// # use tests::assert;
/// let deadline = mono_nanos() + 2000000;
/// sleep_until(deadline);
/// assert!(mono_nanos() >= deadline);
/// ```
fn sleep_until(int deadline) {
    let ns = __ns_per_ms();
    while true {
        let left = deadline - mono_nanos();
        if left <= 0 {
            return;
        }
        sleep((left + ns - 1) / ns);
    }
}

/// A periodic timer: `tick` suspends until the next period. Periods are
/// counted from the start, so a slow loop body does not make the timer
/// drift; a tick that is already late returns at once and skips the
/// periods it missed.
///
/// # Examples
///
/// ```
/// use timer::{Interval};
/// # use tests::assert;
/// let every = Interval::new(1);
/// let a = every.tick();
/// let b = every.tick();
/// assert!(b > a);
/// ```
shared class Interval {
    pub __period: int,
    pub __start: int,
    pub __count: int,
}

impl Interval {
    /// A timer firing every `ms` milliseconds (at least 1), starting now.
    pub static fn new(int ms) -> Interval {
        let period = ms;
        if period < 1 {
            period = 1;
        }
        return new Interval(period * __ns_per_ms(), mono_nanos(), 0);
    }

    /// Waits for the next period and returns its number: 1 for the first
    /// tick, larger by more than 1 when periods were skipped.
    pub fn tick() -> int {
        let now = mono_nanos();
        let due = (now - self.__start) / self.__period;
        let next = self.__count + 1;
        if due >= next {
            // Late: this tick fires now, at the latest period passed.
            self.__count = due;
            return due;
        }
        sleep_until(self.__start + next * self.__period);
        self.__count = next;
        return next;
    }

    /// The period in milliseconds.
    pub fn period() -> int {
        return self.__period / __ns_per_ms();
    }
}
