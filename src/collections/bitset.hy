// Dense bit set of non-negative integer indices over `Vec<int>` words.
//
// Coil `int` is a signed 64-bit two's complement value. Each word stores
// 63 bits (the sign bit is unused) so words stay non-negative and masks
// are built by doubling rather than `1 << 63`.
//
// `with_capacity(bits)` and `capacity()` are measured in bits.

static const WORD_BITS = 63;

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

class BitSet {
    words: Vec<int>,
    count: int,
}

impl BitSet {
    /// Empty set with storage for at least `bits` indices (`0` → no words).
    pub static fn with_capacity(int bits) -> BitSet {
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
    pub fn size() -> int {
        return self.count;
    }

    pub fn is_empty() -> bool {
        return self.count == 0;
    }

    /// Current bit capacity (`len(words) * 63`); grows when inserting past it.
    pub fn capacity() -> int {
        return len(self.words) * WORD_BITS;
    }

    fn grow_to_word(int wi) {
        let n = len(self.words);
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
    pub fn insert(int i) -> bool {
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
        if wi >= len(self.words) {
            return false;
        }
        let mask = word_mask(i % WORD_BITS);
        return (self.words[wi] & mask) != 0;
    }

    /// Clear index `i`; returns `true` when a bit was unset.
    pub fn remove(int i) -> bool {
        if i < 0 {
            return false;
        }
        let wi = i / WORD_BITS;
        if wi >= len(self.words) {
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
    pub fn clear() {
        let n = len(self.words);
        let i = 0;
        while i < n {
            self.words[i] = 0;
            i = i + 1;
        }
        self.count = 0;
    }
}
