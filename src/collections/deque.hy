// Ring-buffer double-ended queue over a growable Vec (power-of-two cap).

/// A double-ended queue: constant-time push and pop at both ends.
///
/// Backed by a ring buffer that doubles when full. Use it as a FIFO queue
/// (`push_back` + `pop_front`) or a stack at either end.
///
/// # Examples
///
/// ```
/// use collections::deque::{VecDeque};
/// # use tests::assert;
/// let q: VecDeque<string> = VecDeque::new();
/// q.push_back("first");
/// q.push_back("second");
/// q.push_front("zeroth");
/// assert!((q.pop_front() ?? "") == "zeroth");
/// assert!((q.pop_back() ?? "") == "second");
/// assert!(q.size() == 1);
/// ```
class VecDeque<T>
    invariant self.len >= 0 && self.len <= self.cap
    invariant self.head >= 0 && self.head < self.cap
    invariant self.buf.len() == self.cap
{
    buf: Vec<Option<T>>,
    head: int,
    len: int,
    cap: int,
}

impl VecDeque<T> {
    /// Empty deque with ring capacity rounded up to the next power of two (min 8).
    pub static fn with_capacity(int cap) -> VecDeque<T> {
        let n = 1;
        while n < cap {
            n = n + n;
        }
        if n < 8 {
            n = 8;
        }
        let buf: Vec<Option<T>> = Vec::new();
        let i = 0;
        while i < n {
            buf.push(Option::None);
            i = i + 1;
        }
        return new VecDeque(buf, 0, 0, n);
    }

    /// Empty deque with default capacity 8.
    pub static fn new() -> VecDeque<T> {
        return VecDeque::with_capacity(8);
    }

/// Returns the number of values.
    pub fn size() -> int {
        return self.len;
    }

/// Returns `true` when the deque has no values.
    pub fn is_empty() -> bool {
        return self.len == 0;
    }

/// Returns how many values fit before the ring buffer grows.
    pub fn capacity() -> int {
        return self.cap;
    }

    fn slot(int offset) -> int {
        return (self.head + offset) & (self.cap - 1);
    }

    fn grow() {
        let new_cap = self.cap + self.cap;
        if new_cap < 8 {
            new_cap = 8;
        }
        let next: Vec<Option<T>> = Vec::new();
        let i = 0;
        while i < self.len {
            next.push(self.buf[self.slot(i)]);
            i = i + 1;
        }
        while i < new_cap {
            next.push(Option::None);
            i = i + 1;
        }
        self.buf = next;
        self.head = 0;
        self.cap = new_cap;
    }

/// Adds `v` at the back.
///
/// # Examples
///
/// ```
/// use collections::deque::{VecDeque};
/// # use tests::assert;
/// let q: VecDeque<int> = VecDeque::new();
/// q.push_back(1);
/// q.push_back(2);
/// assert!((q.peek_back() ?? 0) == 2);
/// ```
    pub fn push_back(T v)
        ensures self.len == old(self.len) + 1
    {
        if self.len == self.cap {
            self.grow();
        }
        self.buf[self.slot(self.len)] = Option::Some(v);
        self.len = self.len + 1;
    }

/// Adds `v` at the front.
///
/// # Examples
///
/// ```
/// use collections::deque::{VecDeque};
/// # use tests::assert;
/// let q: VecDeque<int> = VecDeque::new();
/// q.push_front(1);
/// q.push_front(2);
/// assert!((q.peek_front() ?? 0) == 2);
/// ```
    pub fn push_front(T v)
        ensures self.len == old(self.len) + 1
    {
        if self.len == self.cap {
            self.grow();
        }
        if self.head == 0 {
            self.head = self.cap - 1;
        } else {
            self.head = self.head - 1;
        }
        self.buf[self.head] = Option::Some(v);
        self.len = self.len + 1;
    }

/// Returns the front value without removing it, or `None` when the deque is empty.
    pub fn peek_front() -> Option<T> {
        if self.len == 0 {
            return Option::None;
        }
        return self.buf[self.head];
    }

/// Returns the back value without removing it, or `None` when the deque is empty.
    pub fn peek_back() -> Option<T> {
        if self.len == 0 {
            return Option::None;
        }
        return self.buf[self.slot(self.len - 1)];
    }

/// Removes and returns the front value, or `None` when the deque is empty.
///
/// # Examples
///
/// ```
/// use collections::deque::{VecDeque};
/// # use tests::assert;
/// let q: VecDeque<int> = VecDeque::new();
/// q.push_back(1);
/// q.push_back(2);
/// assert!((q.pop_front() ?? 0) == 1);
/// assert!((q.pop_front() ?? 0) == 2);
/// assert!(q.pop_front().is_none());
/// ```
    pub fn pop_front() -> Option<T>
        ensures self.len == old(self.len) - 1 || (old(self.len) == 0 && self.len == 0)
    {
        if self.len == 0 {
            return Option::None;
        }
        let v = self.buf[self.head];
        self.buf[self.head] = Option::None;
        self.head = self.slot(1);
        self.len = self.len - 1;
        return v;
    }

/// Removes and returns the back value, or `None` when the deque is empty.
    pub fn pop_back() -> Option<T>
        ensures self.len == old(self.len) - 1 || (old(self.len) == 0 && self.len == 0)
    {
        if self.len == 0 {
            return Option::None;
        }
        let i = self.slot(self.len - 1);
        let v = self.buf[i];
        self.buf[i] = Option::None;
        self.len = self.len - 1;
        return v;
    }

/// Removes every value, keeping the capacity.
    pub fn clear()
        ensures self.len == 0
    {
        let i = 0;
        while i < self.len {
            self.buf[self.slot(i)] = Option::None;
            i = i + 1;
        }
        self.head = 0;
        self.len = 0;
    }

/// Returns the values front to back as a new `Vec`.
///
/// # Examples
///
/// ```
/// use collections::deque::{VecDeque};
/// # use tests::assert;
/// let q: VecDeque<int> = VecDeque::new();
/// q.push_back(2);
/// q.push_front(1);
/// let v = q.to_vec();
/// assert!(v[0] == 1 && v[1] == 2);
/// ```
    pub fn to_vec() -> Vec<T>
        ensures result.len() == self.len
    {
        let out: Vec<T> = Vec::new();
        let i = 0;
        while i < self.len {
            match self.buf[self.slot(i)] {
                Option::None => {},
                Option::Some(v) => {
                    out.push(v);
                },
            }
            i = i + 1;
        }
        return out;
    }
}
