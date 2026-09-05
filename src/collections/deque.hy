// Ring-buffer double-ended queue over a growable Vec (power-of-two cap).

class VecDeque<T> {
    buf: Vec<Option<T>>,
    head: int,
    len: int,
    cap: int,
}

impl VecDeque<T> {
    /// Empty deque with ring capacity rounded up to the next power of two (min 8).
    static fn with_capacity(int cap) -> VecDeque<T> {
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
    static fn new() -> VecDeque<T> {
        return VecDeque::with_capacity(8);
    }

    fn size() -> int {
        return self.len;
    }

    fn is_empty() -> bool {
        return self.len == 0;
    }

    fn capacity() -> int {
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

    fn push_back(T v) {
        if self.len == self.cap {
            self.grow();
        }
        self.buf[self.slot(self.len)] = Option::Some(v);
        self.len = self.len + 1;
    }

    fn push_front(T v) {
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

    fn peek_front() -> Option<T> {
        if self.len == 0 {
            return Option::None;
        }
        return self.buf[self.head];
    }

    fn peek_back() -> Option<T> {
        if self.len == 0 {
            return Option::None;
        }
        return self.buf[self.slot(self.len - 1)];
    }

    fn pop_front() -> Option<T> {
        if self.len == 0 {
            return Option::None;
        }
        let v = self.buf[self.head];
        self.buf[self.head] = Option::None;
        self.head = self.slot(1);
        self.len = self.len - 1;
        return v;
    }

    fn pop_back() -> Option<T> {
        if self.len == 0 {
            return Option::None;
        }
        let i = self.slot(self.len - 1);
        let v = self.buf[i];
        self.buf[i] = Option::None;
        self.len = self.len - 1;
        return v;
    }

    fn clear() {
        let i = 0;
        while i < self.len {
            self.buf[self.slot(i)] = Option::None;
            i = i + 1;
        }
        self.head = 0;
        self.len = 0;
    }

    fn to_vec() -> Vec<T> {
        let out: Vec<T> = Vec::new();
        let i = 0;
        while i < self.len {
            match self.buf[self.slot(i)] {
                Option::None => {},
                Option::Some(v) => {
                    out.push(v);
                },
            };
            i = i + 1;
        }
        return out;
    }
}
