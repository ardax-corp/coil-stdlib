// Dense bit set of non-negative integer indices over `Vec<int>` words.
//
// Coil `int` is a signed 64-bit two's complement value. Each word stores
// 63 bits (the sign bit is unused) so words stay non-negative and masks
// are built by doubling rather than `1 << 63`.
//
// `with_capacity(bits)` and `capacity()` are measured in bits.

const WORD_BITS = 63;

/// Mask for bit `b` in `0..WORD_BITS` (`1` doubled `b` times).
fn word_mask(int b) -> int {
    let m = 1;
    let i = 0;
    while i < b {
        m = m + m;
        i = i + 1;
    }
    return m;
}

/// Bits stored in one `int` word (sign bit unused).
fn bits_per_word() -> int {
    return WORD_BITS;
}

/// A set of non-negative `int`s stored as bits.
///
/// Much smaller than a `HashSet<int>` when the values are dense, such as indices
/// or flags. Storage grows to fit the largest value inserted; capacities are
/// counted in bits. Each `int` word holds 63 bits.
///
/// # Examples
///
/// ```
/// use collections::bitset::{BitSet};
/// # use tests::assert;
/// let seen = BitSet::new();
/// seen.insert(3);
/// seen.insert(200);
/// assert!(seen.contains(200));
/// assert!(!seen.contains(4));
/// assert!(seen.len() == 2);
/// ```
class BitSet
    invariant self.count >= 0 && self.count <= self.words.len() * WORD_BITS
{
    words: Vec<int>,
    count: int,
}

impl BitSet {
    /// Empty set with storage for at least `bits` indices (`0` → no words).
    pub static fn with_capacity(int bits) -> BitSet
        ensures result.len() == 0
        ensures result.capacity() >= bits
    {
        let words: Vec<int> = Vec::new();
        if bits > 0 {
            let n = (bits + WORD_BITS - 1) / WORD_BITS;
            let i = 0;
            while i < n {
                words.push(0);
                i = i + 1;
            }
        }
        return new BitSet(words, 0);
    }

    /// Empty set with no word storage (grows on insert).
    pub static fn new() -> BitSet {
        return BitSet::with_capacity(0);
    }

    /// Number of set bits (cardinality).
    pub fn len() -> int {
        return self.count;
    }

    /// Returns `true` when no bit is set.
    pub fn is_empty() -> bool {
        return self.count == 0;
    }

    /// Current bit capacity (`words.len() * 63`); grows when inserting past it.
    pub fn capacity() -> int {
        return self.words.len() * WORD_BITS;
    }

    fn grow_to_word(int wi) {
        let n = self.words.len();
        if wi < n {
            return;
        }
        let target = n;
        if target == 0 {
            target = 1;
        }
        while target <= wi {
            target = target + target;
        }
        while n < target {
            self.words.push(0);
            n = n + 1;
        }
    }

    /// Insert index `i`; returns `true` when newly set. `i < 0` is ignored.
    pub fn insert(int i) -> bool
        ensures i < 0 || self.contains(i)
        ensures !result || self.count == old(self.count) + 1
        ensures result || self.count == old(self.count)
    {
        if i < 0 {
            return false;
        }
        let wi = i / WORD_BITS;
        self.grow_to_word(wi);
        let mask = word_mask(i % WORD_BITS);
        let w = self.words[wi];
        if (w & mask) != 0 {
            return false;
        }
        self.words[wi] = w | mask;
        self.count = self.count + 1;
        return true;
    }

    /// True when index `i` is set.
    pub fn contains(int i) -> bool {
        if i < 0 {
            return false;
        }
        let wi = i / WORD_BITS;
        if wi >= self.words.len() {
            return false;
        }
        let mask = word_mask(i % WORD_BITS);
        return (self.words[wi] & mask) != 0;
    }

    /// Clear index `i`; returns `true` when a bit was unset.
    pub fn remove(int i) -> bool
        ensures !self.contains(i)
        ensures !result || self.count == old(self.count) - 1
        ensures result || self.count == old(self.count)
    {
        if i < 0 {
            return false;
        }
        let wi = i / WORD_BITS;
        if wi >= self.words.len() {
            return false;
        }
        let mask = word_mask(i % WORD_BITS);
        let w = self.words[wi];
        if (w & mask) == 0 {
            return false;
        }
        self.words[wi] = w & ~mask;
        self.count = self.count - 1;
        return true;
    }

    /// Unset every bit; keeps allocated word capacity.
    pub fn clear()
        ensures self.count == 0
    {
        let n = self.words.len();
        let i = 0;
        while i < n {
            self.words[i] = 0;
            i = i + 1;
        }
        self.count = 0;
    }
}
