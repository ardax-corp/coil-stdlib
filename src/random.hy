// Seeded PRNG (`Rng`) and crypto-backed helpers (virtual `crypto` / `time`).
use crypto::{random_u64, random_bytes};
use time::{epoch, timestamp};

class Rng {
    state: int,
}

impl Rng {
    static fn seeded(int seed) -> Rng {
        let s = seed;
        if s == 0 {
            s = 1;
        }
        return new Rng(s);
    }

    static fn from_time() -> Rng {
        let a = match epoch() {
            Result::Ok(v) => v,
            Result::Err(_) => 0,
        };
        let b = match timestamp() {
            Result::Ok(v) => v,
            Result::Err(_) => 0,
        };
        return Rng::seeded(a ^ b ^ (b << 1));
    }

    fn next_u64() -> int {
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

    fn range(int lo, int hi) -> int {
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

    fn float() -> float {
        let x = self.u64_abs();
        let r = x % 9007199254740992;
        return (r as float) / (9007199254740992 as float);
    }

    fn bytes(int n) -> Vec<byte> {
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

/// Uniform `u64` from the host CSPRNG.
fn crypto_u64() -> Result<int, CryptoError> {
    return random_u64()?;
}

/// Fill a new buffer of `n` random bytes (`n <= 0` → empty).
fn crypto_bytes(int n) -> Result<Vec<byte>, CryptoError> {
    if n <= 0 {
        let empty: Vec<byte> = Vec::new();
        return empty;
    }
    return random_bytes(n)?;
}
