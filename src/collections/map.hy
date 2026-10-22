// HashMap — separate chaining over parallel Vecs (no Default on K/V).

/// One key-value pair, as `HashMap` iteration yields it.
class Entry<K, V> {
    /// The key.
    pub key: K,
    /// The value stored under `key`.
    pub value: V,
}

/// A hash map from keys of type `K` to values of type `V`.
///
/// Keys need `Eq` and `Hash` (the primitive types have both; `#[derive(Eq, Hash)]`
/// adds them to your own types). Inserting an existing key replaces its value.
/// Iteration (`for e in m`, `m.keys()`, `m.values()`) visits entries in
/// insertion order, skipping removed ones.
///
/// `get` takes a fallback instead of returning an `Option`; use `contains` first
/// when the fallback could be a real value.
///
/// # Examples
///
/// ```
/// use collections::map::{HashMap};
/// # use tests::assert;
/// let ages: HashMap<string, int> = HashMap::new();
/// ages.insert("ada", 36);
/// ages.insert("alan", 41);
/// ages.insert("ada", 37);
/// assert!(ages.size() == 2);
/// assert!(ages.get_or("ada", 0) == 37);
/// assert!(ages.get_or("grace", -1) == -1);
///
/// let total = 0;
/// for e in ages {
///     total = total + e.value;
/// }
/// assert!(total == 78);
/// ```
class HashMap<K, V>
    invariant self.len >= 0 && self.len <= self.keys.len()
    invariant self.cap >= 8 && self.heads.len() == self.cap
    invariant self.vals.len() == self.keys.len() && self.next.len() == self.keys.len()
    invariant self.live.len() == self.keys.len()
{
    heads: Vec<int>,
    /// Key slots, including removed ones (see `live`). Prefer `keys()`.
    pub keys: Vec<K>,
    /// Value slots parallel to `keys`. Prefer `values()`.
    pub vals: Vec<V>,
    next: Vec<int>,
    /// `1` where the slot holds an entry, `0` where it was removed.
    pub live: Vec<int>,
    len: int,
    cap: int,
}

/// An iterator over the entries of a `HashMap`, from `HashMap::iter`.
class HashMapIter<K, V> {
    map: HashMap<K, V>,
    slot: int,
}

impl HashMap<K, V> {
    /// Creates an empty map with room for about `cap` buckets before it grows.
    ///
    /// The bucket count is rounded up to a power of two, at least 8.
    ///
    /// # Examples
    ///
    /// ```
    /// use collections::map::{HashMap};
    /// # use tests::assert;
    /// let m: HashMap<int, string> = HashMap::with_capacity(100);
    /// assert!(m.is_empty());
    /// assert!(m.capacity() >= 100);
    /// ```
    pub static fn with_capacity(int cap) -> HashMap<K, V> {
        let n = 1;
        while n < cap {
            n = n + n;
        }
        if n < 8 {
            n = 8;
        }
        let heads: Vec<int> = Vec::new();
        let i = 0;
        while i < n {
            heads.push(0 - 1);
            i = i + 1;
        }
        let keys: Vec<K> = Vec::new();
        let vals: Vec<V> = Vec::new();
        let next: Vec<int> = Vec::new();
        let live: Vec<int> = Vec::new();
        return new HashMap(heads, keys, vals, next, live, 0, n);
    }

    /// Creates an empty map.
    ///
    /// # Examples
    ///
    /// ```
    /// use collections::map::{HashMap};
    /// # use tests::assert;
    /// let m: HashMap<string, int> = HashMap::new();
    /// assert!(m.size() == 0);
    /// ```
    pub static fn new() -> HashMap<K, V> {
        return HashMap::with_capacity(8);
    }

    /// Returns the number of entries.
    ///
    /// # Examples
    ///
    /// ```
    /// use collections::map::{HashMap};
    /// # use tests::assert;
    /// let m: HashMap<string, int> = HashMap::new();
    /// m.insert("a", 1);
    /// m.insert("b", 2);
    /// m.remove("a");
    /// assert!(m.size() == 1);
    /// ```
    pub fn size() -> int {
        return self.len;
    }

    /// Returns `true` when the map has no entries.
    pub fn is_empty() -> bool {
        return self.len == 0;
    }

    /// Returns the number of buckets.
    ///
    /// The map doubles it when it is half full.
    pub fn capacity() -> int {
        return self.cap;
    }

    /// Removes every entry, keeping the bucket count.
    ///
    /// # Examples
    ///
    /// ```
    /// use collections::map::{HashMap};
    /// # use tests::assert;
    /// let m: HashMap<int, int> = HashMap::new();
    /// m.insert(1, 10);
    /// m.clear();
    /// assert!(m.is_empty());
    /// assert!(!m.contains(1));
    /// ```
    pub fn clear()
        ensures self.len == 0
    {
        let i = 0;
        while i < self.cap {
            self.heads[i] = 0 - 1;
            i = i + 1;
        }
        let n = self.live.len();
        let j = 0;
        while j < n {
            self.live[j] = 0;
            j = j + 1;
        }
        self.len = 0;
    }

    /// Returns the keys, in insertion order.
    ///
    /// # Examples
    ///
    /// ```
    /// use collections::map::{HashMap};
    /// # use tests::assert;
    /// let m: HashMap<string, int> = HashMap::new();
    /// m.insert("x", 1);
    /// m.insert("y", 2);
    /// let ks = m.keys();
    /// assert!(ks.len() == 2);
    /// assert!(ks[0] == "x");
    /// ```
    pub fn keys() -> Vec<K>
        ensures result.len() == self.len
    {
        let out: Vec<K> = Vec::new();
        let i = 0;
        while i < self.keys.len() {
            if self.live[i] == 1 {
                out.push(self.keys[i]);
            }
            i = i + 1;
        }
        return out;
    }

    /// Returns the values, in the insertion order of their keys.
    ///
    /// # Examples
    ///
    /// ```
    /// use collections::map::{HashMap};
    /// # use tests::assert;
    /// let m: HashMap<string, int> = HashMap::new();
    /// m.insert("x", 1);
    /// m.insert("y", 2);
    /// let vs = m.values();
    /// assert!(vs[0] + vs[1] == 3);
    /// ```
    pub fn values() -> Vec<V>
        ensures result.len() == self.len
    {
        let out: Vec<V> = Vec::new();
        let i = 0;
        while i < self.vals.len() {
            if self.live[i] == 1 {
                out.push(self.vals[i]);
            }
            i = i + 1;
        }
        return out;
    }

    /// Returns an iterator over the entries, in insertion order.
    ///
    /// `for e in m` does the same; each item is an `Entry` with `key` and `value`.
    ///
    /// # Examples
    ///
    /// ```
    /// use collections::map::{HashMap};
    /// # use tests::assert;
    /// let m: HashMap<string, int> = HashMap::new();
    /// m.insert("a", 1);
    /// let it = m.iter();
    /// let first = match it.next() {
    ///     Option::Some(e) => e.key,
    ///     Option::None => "",
    /// };
    /// assert!(first == "a");
    /// ```
    pub fn iter() -> HashMapIter<K, V> {
        return new HashMapIter(self, 0);
    }
}

impl HashMap<K: Eq + Hash, V> {
    fn hash_of(K k) -> int {
        return k.hash();
    }

    fn bucket(K k) -> int {
        return self.hash_of(k) & (self.cap - 1);
    }

    fn find(K k) -> int {
        let h = self.bucket(k);
        let idx = self.heads[h];
        while idx >= 0 {
            if self.live[idx] == 1 {
                if self.keys[idx] == k {
                    return idx;
                }
            }
            idx = self.next[idx];
        }
        return 0 - 1;
    }

    fn grow() {
        let new_cap = self.cap + self.cap;
        if new_cap < 8 {
            new_cap = 8;
        }
        let heads: Vec<int> = Vec::new();
        let i = 0;
        while i < new_cap {
            heads.push(0 - 1);
            i = i + 1;
        }
        let keys: Vec<K> = Vec::new();
        let vals: Vec<V> = Vec::new();
        let next: Vec<int> = Vec::new();
        let live: Vec<int> = Vec::new();
        let old_n = self.keys.len();
        let j = 0;
        while j < old_n {
            if self.live[j] == 1 {
                let k = self.keys[j];
                let v = self.vals[j];
                let h = self.hash_of(k) & (new_cap - 1);
                let slot = keys.len();
                keys.push(k);
                vals.push(v);
                next.push(heads[h]);
                live.push(1);
                heads[h] = slot;
            }
            j = j + 1;
        }
        self.heads = heads;
        self.keys = keys;
        self.vals = vals;
        self.next = next;
        self.live = live;
        self.cap = new_cap;
    }

    /// Stores `v` under `k`, replacing any value already there.
    ///
    /// Returns `true` when `k` is new and `false` when an existing value was replaced.
    ///
    /// # Examples
    ///
    /// ```
    /// use collections::map::{HashMap};
    /// # use tests::assert;
    /// let m: HashMap<string, int> = HashMap::new();
    /// assert!(m.insert("a", 1));
    /// assert!(!m.insert("a", 2));
    /// assert!(m.get_or("a", 0) == 2);
    /// ```
    pub fn insert(K k, V v) -> bool
        ensures !result || self.len == old(self.len) + 1
        ensures result || self.len == old(self.len)
    {
        let found = self.find(k);
        if found >= 0 {
            self.vals[found] = v;
            return false;
        }
        if (self.len + self.len) >= self.cap {
            self.grow();
        }
        let h = self.bucket(k);
        let slot = self.keys.len();
        self.keys.push(k);
        self.vals.push(v);
        self.next.push(self.heads[h]);
        self.live.push(1);
        self.heads[h] = slot;
        self.len = self.len + 1;
        return true;
    }

    /// Returns `true` when the map has an entry for `k`.
    ///
    /// # Examples
    ///
    /// ```
    /// use collections::map::{HashMap};
    /// # use tests::assert;
    /// let m: HashMap<int, bool> = HashMap::new();
    /// m.insert(7, false);
    /// assert!(m.contains(7));
    /// assert!(!m.contains(8));
    /// ```
    pub fn contains(K k) -> bool {
        return self.find(k) >= 0;
    }

    /// Returns the value stored under `k`, or `fallback` when there is none.
    ///
    /// # Examples
    ///
    /// ```
    /// use collections::map::{HashMap};
    /// # use tests::assert;
    /// let m: HashMap<string, int> = HashMap::new();
    /// m.insert("a", 1);
    /// assert!(m.get_or("a", 0) == 1);
    /// assert!(m.get_or("b", 0) == 0);
    /// ```
    pub fn get_or(K k, V fallback) -> V {
        let found = self.find(k);
        if found >= 0 {
            return self.vals[found];
        }
        return fallback;
    }

    /// Returns the value stored under `k`, or `None` when there is none.
    ///
    /// # Examples
    ///
    /// ```
    /// use collections::map::{HashMap};
    /// # use tests::assert;
    /// let m: HashMap<string, int> = HashMap::new();
    /// m.insert("a", 1);
    /// assert!((m.get("a") ?? 0) == 1);
    /// assert!(m.get("b").is_none());
    /// ```
    pub fn get(K k) -> Option<V> {
        let found = self.find(k);
        if found >= 0 {
            return Some(self.vals[found]);
        }
        return None;
    }

    /// Removes the entry for `k`.
    ///
    /// Returns `true` when there was one.
    ///
    /// # Examples
    ///
    /// ```
    /// use collections::map::{HashMap};
    /// # use tests::assert;
    /// let m: HashMap<string, int> = HashMap::new();
    /// m.insert("a", 1);
    /// assert!(m.remove("a"));
    /// assert!(!m.remove("a"));
    /// assert!(m.is_empty());
    /// ```
    pub fn remove(K k) -> bool
        ensures !result || self.len == old(self.len) - 1
        ensures result || self.len == old(self.len)
    {
        let h = self.bucket(k);
        let idx = self.heads[h];
        let prev = 0 - 1;
        while idx >= 0 {
            if self.live[idx] == 1 {
                if self.keys[idx] == k {
                    if prev < 0 {
                        self.heads[h] = self.next[idx];
                    } else {
                        self.next[prev] = self.next[idx];
                    }
                    self.live[idx] = 0;
                    self.len = self.len - 1;
                    return true;
                }
            }
            prev = idx;
            idx = self.next[idx];
        }
        return false;
    }
}

impl HashMapIter<K, V> {
    /// Returns the next entry, or `None` after the last one.
    pub fn next() -> Option<Entry<K, V>> {
        let n = self.map.keys.len();
        while self.slot < n {
            let s = self.slot;
            self.slot = self.slot + 1;
            if self.map.live[s] == 1 {
                let e = new Entry(self.map.keys[s], self.map.vals[s]);
                return Option::Some(e);
            }
        }
        return Option::None;
    }
}

impl IntoIterator for HashMap<K, V> {
    type Item = Entry<K, V>;
    type IntoIter = HashMapIter<K, V>;
    pub fn into_iter(HashMap<K, V> m) -> HashMapIter<K, V> {
        return m.iter();
    }
}

impl Iterator for HashMapIter<K, V> {
    type Item = Entry<K, V>;
    pub fn next(HashMapIter<K, V> it) -> Option<Entry<K, V>> {
        return it.next();
    }
}
