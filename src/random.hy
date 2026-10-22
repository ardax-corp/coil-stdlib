// Seeded PRNG (`Rng`). `from_time` mixes coil-time timestamps as ints.
use time::{epoch, timestamp};

/// A seeded pseudo-random number generator.
///
/// The same seed always gives the same sequence, which makes tests repeatable.
/// It is not cryptographically secure: for keys, tokens and nonces use
/// `crypto::random_bytes` from coil-crypto. `from_time` needs the coil-time
/// package on the module roots.
///
/// # Examples
///
/// ```
/// use random::{Rng};
/// # use tests::assert;
/// let a = Rng::seeded(7);
/// let b = Rng::seeded(7);
/// assert!(a.range(0, 100) == b.range(0, 100));
/// let roll = a.range(1, 7);
/// assert!(roll >= 1 && roll < 7);
/// ```
class Rng {
    state: int,
}

impl Rng {
/// Creates a generator from `seed`. A seed of `0` is treated as `1`.
    pub static fn seeded(int seed) -> Rng {
        let s = seed;
        if s == 0 {
            s = 1;
        }
        return new Rng(s);
    }

/// Creates a generator seeded from the current wall-clock and monotonic time (via coil-time).
    pub static fn from_time() -> Rng {
        let a = 0;
        match epoch() {
            Result::Ok(ts) => {
                a = ts.nanos();
            },
            Result::Err(_) => {},
        }
        let b = 0;
        match timestamp() {
            Result::Ok(ts) => {
                b = ts.nanos();
            },
            Result::Err(_) => {},
        }
        return Rng::seeded(a ^ b ^ (b << 1));
    }

/// Returns the next raw value from the generator, a non-negative `int`.
    pub fn next_u64() -> int {
        let s = self.state % 1000000;
        self.state = s * 1009 + 17;
        return self.state;
    }

    fn u64_abs() -> int {
        let x = self.next_u64();
        if x < 0 {
            return 0 - x;
        }
        return x;
    }

/// Returns a value in `lo..hi` (including `lo`, excluding `hi`), or `lo` when `hi <= lo`.
///
/// # Examples
///
/// ```
/// use random::{Rng};
/// # use tests::assert;
/// let r = Rng::seeded(1);
/// let i = 0;
/// while i < 20 {
///     let x = r.range(-5, 5);
///     assert!(x >= -5 && x < 5);
///     i = i + 1;
/// }
/// assert!(r.range(3, 3) == 3);
/// ```
    pub fn range(int lo, int hi) -> int {
        if hi <= lo {
            return lo;
        }
        let span = hi - lo;
        let max = 9223372036854775807;
        let limit = max - (max % span);
        while true {
            let x = self.u64_abs();
            if x < limit {
                return lo + (x % span);
            }
        }
    }

/// Returns a `float` in `0.0..1.0`.
    pub fn float() -> float {
        let x = self.u64_abs();
        let r = x % 9007199254740992;
        return (r as float) / (9007199254740992 as float);
    }

/// Returns `n` pseudo-random bytes (none when `n <= 0`).
///
/// # Examples
///
/// ```
/// use random::{Rng};
/// # use tests::assert;
/// let r = Rng::seeded(9);
/// assert!(r.bytes(16).len() == 16);
/// assert!(r.bytes(-1).len() == 0);
/// ```
    pub fn bytes(int n) -> Vec<byte> {
        let out: Vec<byte> = Vec::new();
        if n <= 0 {
            return out;
        }
        let i = 0;
        while i < n {
            let x = self.next_u64();
            let shift = 0;
            while shift < 64 {
                if i >= n {
                    break;
                }
                let b = (x >> shift) as byte;
                out.push(b);
                i = i + 1;
                shift = shift + 8;
            }
        }
        return out;
    }
}
