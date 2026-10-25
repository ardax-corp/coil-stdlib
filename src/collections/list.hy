// Mutable singly-linked list with O(1) push/pop at the front.

/// One cell of a `List`: a value and the rest of the list.
class Node<T> {
    /// The value held in this cell.
    pub value: T,
    /// The following cell, or `None` at the end.
    pub next: Option<Node<T>>,
}

/// A singly-linked list with constant-time push and pop at the front.
///
/// `push_back` and `pop_back` walk the whole list, so use
/// `collections::deque::VecDeque` when you need both ends to be fast.
/// `for x in list` visits the values front to back.
///
/// # Examples
///
/// ```
/// use collections::list::{List};
/// # use tests::assert;
/// let xs: List<int> = List::new();
/// xs.push_front(2);
/// xs.push_front(1);
/// xs.push_back(3);
/// assert!(xs.len() == 3);
/// let sum = 0;
/// for x in xs {
///     sum = sum * 10 + x;
/// }
/// assert!(sum == 123);
/// assert!((xs.pop_front() ?? 0) == 1);
/// ```
class List<T>
    invariant self.len >= 0
{
    head: Option<Node<T>>,
    len: int,
}

/// An iterator over a `List`, front to back, from `List::iter`.
class ListIter<T> {
    node: Option<Node<T>>,
}

impl List<T> {
    /// Creates an empty list.
    pub static fn new() -> List<T> {
        return new List(Option::None, 0);
    }

    /// Returns the number of values.
    pub fn len() -> int {
        return self.len;
    }

    /// Returns `true` when the list has no values.
    pub fn is_empty() -> bool {
        return self.len == 0;
    }

    /// Adds `v` at the front. Constant time.
    ///
    /// # Examples
    ///
    /// ```
    /// use collections::list::{List};
    /// # use tests::assert;
    /// let xs: List<string> = List::new();
    /// xs.push_front("b");
    /// xs.push_front("a");
    /// assert!((xs.peek_front() ?? "") == "a");
    /// ```
    pub fn push_front(T v)
        ensures self.len == old(self.len) + 1
    {
        let n = new Node(v, self.head);
        self.head = Option::Some(n);
        self.len = self.len + 1;
    }

    /// Adds `v` at the back. Walks the list, so it takes time proportional to its length.
    ///
    /// # Examples
    ///
    /// ```
    /// use collections::list::{List};
    /// # use tests::assert;
    /// let xs: List<int> = List::new();
    /// xs.push_back(1);
    /// xs.push_back(2);
    /// let v = xs.to_vec();
    /// assert!(v[1] == 2);
    /// ```
    pub fn push_back(T v)
        ensures self.len == old(self.len) + 1
    {
        let n = new Node(v, Option::None);
        if self.is_empty() {
            self.head = Option::Some(n);
        } else {
            let cur = self.head;
            let done = false;
            while !done {
                match cur {
                    Option::None => {
                        done = true;
                    },
                    Option::Some(node) => {
                        match node.next {
                            Option::None => {
                                node.next = Option::Some(n);
                                done = true;
                            },
                            Option::Some(next) => {
                                cur = Option::Some(next);
                            },
                        }
                    },
                }
            }
        }
        self.len = self.len + 1;
    }

    /// Returns the front value without removing it, or `None` when the list is empty.
    pub fn peek_front() -> Option<T> {
        return match self.head {
            Option::None => Option::None,
            Option::Some(n) => Option::Some(n.value),
        };
    }

    /// Removes and returns the front value, or `None` when the list is empty. Constant time.
    ///
    /// # Examples
    ///
    /// ```
    /// use collections::list::{List};
    /// # use tests::assert;
    /// let xs: List<int> = List::new();
    /// xs.push_front(7);
    /// assert!((xs.pop_front() ?? 0) == 7);
    /// assert!(xs.pop_front().is_none());
    /// ```
    pub fn pop_front() -> Option<T>
        ensures self.len == old(self.len) - 1 || (old(self.len) == 0 && self.len == 0)
    {
        return match self.head {
            Option::None => Option::None,
            Option::Some(n) => {
                let v = n.value;
                self.head = n.next;
                self.len = self.len - 1;
                return Option::Some(v);
            },
        };
    }

    /// Removes and returns the back value, or `None` when the list is empty.
    ///
    /// Walks the list, so it takes time proportional to its length.
    pub fn pop_back() -> Option<T>
        ensures self.len == old(self.len) - 1 || (old(self.len) == 0 && self.len == 0)
    {
        if self.is_empty() {
            return Option::None;
        }
        if self.len == 1 {
            return self.pop_front();
        }
        let cur = self.head;
        let prev = Option::None;
        let done = false;
        while !done {
            match cur {
                Option::None => {
                    done = true;
                },
                Option::Some(node) => {
                    match node.next {
                        Option::None => {
                            done = true;
                        },
                        Option::Some(next) => {
                            prev = cur;
                            cur = Option::Some(next);
                        },
                    }
                },
            }
        }
        return match cur {
            Option::None => Option::None,
            Option::Some(last) => {
                let v = last.value;
                match prev {
                    Option::None => {
                        self.head = Option::None;
                    },
                    Option::Some(p) => {
                        p.next = Option::None;
                    },
                }
                self.len = self.len - 1;
                return Option::Some(v);
            },
        };
    }

    /// Removes every value.
    pub fn clear()
        ensures self.len == 0
    {
        self.head = Option::None;
        self.len = 0;
    }

    /// Returns the values front to back as a new `Vec`.
    pub fn to_vec() -> Vec<T>
        ensures result.len() == self.len
    {
        let out: Vec<T> = Vec::new();
        let cur = self.head;
        let done = false;
        while !done {
            match cur {
                Option::None => {
                    done = true;
                },
                Option::Some(n) => {
                    out.push(n.value);
                    cur = n.next;
                },
            }
        }
        return out;
    }

    /// Returns an iterator over the values, front to back.
    pub fn iter() -> ListIter<T> {
        return new ListIter(self.head);
    }
}

impl ListIter<T> {
    /// Returns the next value, or `None` at the end.
    pub fn next() -> Option<T> {
        return match self.node {
            Option::None => Option::None,
            Option::Some(n) => {
                let v = n.value;
                self.node = n.next;
                return Option::Some(v);
            },
        };
    }
}

impl IntoIterator for List<T> {
    type Item = T;
    type IntoIter = ListIter<T>;
    pub fn into_iter(List<T> xs) -> ListIter<T> {
        return xs.iter();
    }
}

impl Iterator for ListIter<T> {
    type Item = T;
    pub fn next(ListIter<T> it) -> Option<T> {
        return it.next();
    }
}
