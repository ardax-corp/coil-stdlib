// Seeded PRNG (`Rng`). `from_time` mixes coil-time timestamps as ints.
use time::{epoch, timestamp};
use arith::{Wrapping, INT_MAX};

// `x` shifted right by `n` (1..63) with zeros shifted in; `>>` keeps the sign.
fn shr_logical(int x, int n) -> int {
    return (x >> n) & (INT_MAX >> (n - 1));
}

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

    /// Returns the next 64 raw bits from the generator as an `int`, so about
    /// half the values are negative (splitmix64).
    pub fn next_u64() -> int {
        self.state = self.state.wrapping_add(-7046029254386353131);
        let z = self.state;
        z = (z ^ shr_logical(z, 30)).wrapping_mul(-4658895280553007687);
        z = (z ^ shr_logical(z, 27)).wrapping_mul(-7723592293110705685);
        return z ^ shr_logical(z, 31);
    }

    // The next 63 bits, a non-negative `int`.
    fn next_63() -> int {
        return self.next_u64() & INT_MAX;
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
        let limit = INT_MAX - (INT_MAX % span);
        while true {
            let x = self.next_63();
            if x < limit {
                return lo + (x % span);
            }
        }
    }

    /// Returns a `float` in `0.0..1.0`.
    pub fn float() -> float {
        // The top 53 bits, the precision a `float` holds exactly.
        let r = shr_logical(self.next_u64(), 11);
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
