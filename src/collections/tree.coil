// Mutable BST over Ord+Eq keys, index-linked nodes.

/// One key-value pair, as `TreeMap` iteration yields it.
class Entry<K, V> {
    /// The key.
    pub key: K,
    /// The value stored under `key`.
    pub value: V,
}

/// An ordered map from keys of type `K` to values of type `V`.
///
/// Keys need `Ord` and `Eq`. Iteration visits entries in ascending key order,
/// and `min_key` / `max_key` give the ends. The tree is not rebalanced: inserting
/// keys that are already sorted makes lookups linear, so prefer `HashMap` when you
/// do not need the order.
///
/// # Examples
///
/// ```
/// use collections::tree::{TreeMap};
/// # use tests::assert;
/// let m: TreeMap<int, string> = TreeMap::new();
/// m.insert(30, "c");
/// m.insert(10, "a");
/// m.insert(20, "b");
/// let order = "";
/// for e in m {
///     order = order + e.value;
/// }
/// assert!(order == "abc");
/// assert!(m.min_key(0) == 10);
/// ```
class TreeMap<K, V>
    invariant self.len >= 0 && self.len <= self.keys.len()
    invariant self.vals.len() == self.keys.len()
    invariant self.left.len() == self.keys.len() && self.right.len() == self.keys.len()
    invariant (self.root < 0) == (self.len == 0)
{
    /// Node keys, including removed nodes. Prefer iteration.
    pub keys: Vec<K>,
    /// Node values parallel to `keys`.
    pub vals: Vec<V>,
    /// Index of each node's left child, or `-1`.
    pub left: Vec<int>,
    /// Index of each node's right child, or `-1`.
    pub right: Vec<int>,
    /// Index of the root node, or `-1` when the map is empty.
    pub root: int,
    len: int,
}

/// An in-order iterator over a `TreeMap`, from `TreeMap::iter`.
class TreeMapIter<K, V> {
    map: TreeMap<K, V>,
    stack: Vec<int>,
    phase: int,
}

impl TreeMap<K, V> {
    /// Creates an empty map.
    ///
    /// # Examples
    ///
    /// ```
    /// use collections::tree::{TreeMap};
    /// # use tests::assert;
    /// let m: TreeMap<string, int> = TreeMap::new();
    /// assert!(m.is_empty());
    /// ```
    pub static fn new() -> TreeMap<K, V> {
        let keys: Vec<K> = Vec::new();
        let vals: Vec<V> = Vec::new();
        let left: Vec<int> = Vec::new();
        let right: Vec<int> = Vec::new();
        return new TreeMap(keys, vals, left, right, -1, 0);
    }

    /// Creates an empty map; the same as `TreeMap::new`.
    pub static fn empty() -> TreeMap<K, V> {
        return TreeMap::new();
    }

    /// Returns the number of entries.
    pub fn len() -> int {
        return self.len;
    }

    /// Returns `true` when the map has no entries.
    pub fn is_empty() -> bool {
        return self.len == 0;
    }

    /// Removes every entry.
    pub fn clear()
        ensures self.len == 0
    {
        self.keys = Vec::new();
        self.vals = Vec::new();
        self.left = Vec::new();
        self.right = Vec::new();
        self.root = -1;
        self.len = 0;
    }

    /// Returns an iterator over the entries in ascending key order.
    ///
    /// `for e in m` does the same; each item is an `Entry` with `key` and `value`.
    pub fn iter() -> TreeMapIter<K, V> {
        let stack: Vec<int> = Vec::new();
        return new TreeMapIter(self, stack, 0);
    }
}

impl TreeMap<K: Ord + Eq, V> {
    /// Stores `v` under `k`, replacing any value already there.
    ///
    /// Returns `true` when `k` is new and `false` when an existing value was replaced.
    ///
    /// # Examples
    ///
    /// ```
    /// use collections::tree::{TreeMap};
    /// # use tests::assert;
    /// let m: TreeMap<string, int> = TreeMap::new();
    /// assert!(m.insert("a", 1));
    /// assert!(!m.insert("a", 2));
    /// assert!(m.get_or("a", 0) == 2);
    /// assert!(m.len() == 1);
    /// ```
    pub fn insert(K k, V v) -> bool
        ensures !result || self.len == old(self.len) + 1
        ensures result || self.len == old(self.len)
    {
        if self.root < 0 {
            let slot = self.keys.len();
            self.keys.push(k);
            self.vals.push(v);
            self.left.push(-1);
            self.right.push(-1);
            self.root = slot;
            self.len = 1;
            return true;
        }
        let cur = self.root;
        while true {
            if k == self.keys[cur] {
                self.vals[cur] = v;
                return false;
            }
            if k < self.keys[cur] {
                let child = self.left[cur];
                if child < 0 {
                    let slot = self.keys.len();
                    self.keys.push(k);
                    self.vals.push(v);
                    self.left.push(-1);
                    self.right.push(-1);
                    self.left[cur] = slot;
                    self.len = self.len + 1;
                    return true;
                }
                cur = child;
            } else {
                let child = self.right[cur];
                if child < 0 {
                    let slot = self.keys.len();
                    self.keys.push(k);
                    self.vals.push(v);
                    self.left.push(-1);
                    self.right.push(-1);
                    self.right[cur] = slot;
                    self.len = self.len + 1;
                    return true;
                }
                cur = child;
            }
        }
    }

    /// Returns `true` when the map has an entry for `k`.
    pub fn contains(K k) -> bool {
        let cur = self.root;
        while cur >= 0 {
            if k == self.keys[cur] {
                return true;
            }
            if k < self.keys[cur] {
                cur = self.left[cur];
            } else {
                cur = self.right[cur];
            }
        }
        return false;
    }

    /// Returns the value stored under `k`, or `fallback` when there is none.
    ///
    /// # Examples
    ///
    /// ```
    /// use collections::tree::{TreeMap};
    /// # use tests::assert;
    /// let m: TreeMap<int, string> = TreeMap::new();
    /// m.insert(1, "one");
    /// assert!(m.get_or(1, "?") == "one");
    /// assert!(m.get_or(2, "?") == "?");
    /// ```
    pub fn get_or(K k, V fallback) -> V {
        let cur = self.root;
        while cur >= 0 {
            if k == self.keys[cur] {
                return self.vals[cur];
            }
            if k < self.keys[cur] {
                cur = self.left[cur];
            } else {
                cur = self.right[cur];
            }
        }
        return fallback;
    }

    /// Returns the value stored under `k`, or `None` when there is none.
    ///
    /// # Examples
    ///
    /// ```
    /// use collections::tree::{TreeMap};
    /// # use tests::assert;
    /// let m: TreeMap<string, int> = TreeMap::new();
    /// m.insert("a", 1);
    /// assert!((m.get("a") ?? 0) == 1);
    /// assert!(m.get("b").is_none());
    /// ```
    pub fn get(K k) -> Option<V> {
        let cur = self.root;
        while cur >= 0 {
            if k == self.keys[cur] {
                return Some(self.vals[cur]);
            }
            if k < self.keys[cur] {
                cur = self.left[cur];
            } else {
                cur = self.right[cur];
            }
        }
        return None;
    }

    fn find_parent(int idx) -> int {
        let p = -1;
        let cur = self.root;
        while cur >= 0 {
            if cur == idx {
                return p;
            }
            if self.keys[idx] < self.keys[cur] {
                p = cur;
                cur = self.left[cur];
            } else {
                p = cur;
                cur = self.right[cur];
            }
        }
        return -1;
    }

    fn set_child_of(int parent, int old_c, int new_c) {
        if parent < 0 {
            self.root = new_c;
            return;
        }
        if self.left[parent] == old_c {
            self.left[parent] = new_c;
            return;
        }
        self.right[parent] = new_c;
    }

    fn min_node(int start) -> int {
        let cur = start;
        while self.left[cur] >= 0 {
            cur = self.left[cur];
        }
        return cur;
    }

    fn max_node(int start) -> int {
        let cur = start;
        while self.right[cur] >= 0 {
            cur = self.right[cur];
        }
        return cur;
    }

    /// Removes the entry for `k`.
    ///
    /// Returns `true` when there was one.
    ///
    /// # Examples
    ///
    /// ```
    /// use collections::tree::{TreeMap};
    /// # use tests::assert;
    /// let m: TreeMap<int, int> = TreeMap::new();
    /// m.insert(5, 50);
    /// m.insert(3, 30);
    /// assert!(m.remove(5));
    /// assert!(!m.contains(5));
    /// assert!(m.min_key(-1) == 3);
    /// ```
    pub fn remove(K k) -> bool
        ensures !result || self.len == old(self.len) - 1
        ensures result || self.len == old(self.len)
    {
        let cur = self.root;
        let target = -1;
        while cur >= 0 {
            if k == self.keys[cur] {
                target = cur;
                break;
            }
            if k < self.keys[cur] {
                cur = self.left[cur];
            } else {
                cur = self.right[cur];
            }
        }
        if target < 0 {
            return false;
        }
        let parent = self.find_parent(target);
        if self.left[target] < 0 {
            if self.right[target] < 0 {
                self.set_child_of(parent, target, -1);
            } else {
                self.set_child_of(parent, target, self.right[target]);
            }
            self.len = self.len - 1;
            return true;
        }
        if self.right[target] < 0 {
            self.set_child_of(parent, target, self.left[target]);
            self.len = self.len - 1;
            return true;
        }
        let succ = self.min_node(self.right[target]);
        self.keys[target] = self.keys[succ];
        self.vals[target] = self.vals[succ];
        let sp = self.find_parent(succ);
        let repl = self.right[succ];
        self.set_child_of(sp, succ, repl);
        self.len = self.len - 1;
        return true;
    }

    /// Returns the smallest key, or `fallback` when the map is empty.
    ///
    /// # Examples
    ///
    /// ```
    /// use collections::tree::{TreeMap};
    /// # use tests::assert;
    /// let m: TreeMap<int, bool> = TreeMap::new();
    /// assert!(m.min_key(-1) == -1);
    /// m.insert(4, true);
    /// m.insert(2, true);
    /// assert!(m.min_key(-1) == 2);
    /// ```
    pub fn min_key(K fallback) -> K {
        if self.root < 0 {
            return fallback;
        }
        let n = self.min_node(self.root);
        return self.keys[n];
    }

    /// Returns the largest key, or `fallback` when the map is empty.
    ///
    /// # Examples
    ///
    /// ```
    /// use collections::tree::{TreeMap};
    /// # use tests::assert;
    /// let m: TreeMap<int, bool> = TreeMap::new();
    /// m.insert(4, true);
    /// m.insert(9, true);
    /// assert!(m.max_key(-1) == 9);
    /// ```
    pub fn max_key(K fallback) -> K {
        if self.root < 0 {
            return fallback;
        }
        let n = self.max_node(self.root);
        return self.keys[n];
    }
}

impl TreeMapIter<K, V> {
    /// Returns the entry with the next larger key, or `None` after the last one.
    pub fn next() -> Option<Entry<K, V>> {
        if self.phase == 0 {
            let cur = self.map.root;
            while cur >= 0 {
                self.stack.push(cur);
                cur = self.map.left[cur];
            }
            self.phase = 1;
        }
        return match self.stack.pop() {
            Option::None => Option::None,
            Option::Some(node) => {
                let right = self.map.right[node];
                let cur = right;
                while cur >= 0 {
                    self.stack.push(cur);
                    cur = self.map.left[cur];
                }
                let e = new Entry(self.map.keys[node], self.map.vals[node]);
                return Option::Some(e);
            },
        };
    }
}

impl IntoIterator for TreeMap<K, V> {
    type Item = Entry<K, V>;
    type IntoIter = TreeMapIter<K, V>;
    pub fn into_iter(TreeMap<K, V> m) -> TreeMapIter<K, V> {
        return m.iter();
    }
}

impl Iterator for TreeMapIter<K, V> {
    type Item = Entry<K, V>;
    pub fn next(TreeMapIter<K, V> it) -> Option<Entry<K, V>> {
        return it.next();
    }
}
