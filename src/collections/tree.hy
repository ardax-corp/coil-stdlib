// Mutable BST over Ord+Eq keys, index-linked nodes.

class Entry<K, V> {
    key: K,
    value: V,
}

class TreeMap<K, V> {
    keys: Vec<K>,
    vals: Vec<V>,
    left: Vec<int>,
    right: Vec<int>,
    root: int,
    len: int,
}

class TreeMapIter<K, V> {
    map: TreeMap<K, V>,
    stack: Vec<int>,
    phase: int,
}

impl TreeMap<K, V> {
    static fn new() -> TreeMap<K, V> {
        let keys: Vec<K> = Vec::new();
        let vals: Vec<V> = Vec::new();
        let left: Vec<int> = Vec::new();
        let right: Vec<int> = Vec::new();
        return new TreeMap(keys, vals, left, right, 0 - 1, 0);
    }

    static fn empty() -> TreeMap<K, V> {
        return TreeMap::new();
    }

    fn size() -> int {
        return self.len;
    }

    fn is_empty() -> bool {
        return self.len == 0;
    }

    fn clear() {
        self.keys = Vec::new();
        self.vals = Vec::new();
        self.left = Vec::new();
        self.right = Vec::new();
        self.root = 0 - 1;
        self.len = 0;
    }

    fn iter() -> TreeMapIter<K, V> {
        let stack: Vec<int> = Vec::new();
        return new TreeMapIter(self, stack, 0);
    }
}

impl TreeMap<K: Ord + Eq, V> {
    fn insert(K k, V v) -> bool {
        if self.root < 0 {
            let slot = self.keys.len();
            self.keys.push(k);
            self.vals.push(v);
            self.left.push(0 - 1);
            self.right.push(0 - 1);
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
                    self.left.push(0 - 1);
                    self.right.push(0 - 1);
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
                    self.left.push(0 - 1);
                    self.right.push(0 - 1);
                    self.right[cur] = slot;
                    self.len = self.len + 1;
                    return true;
                }
                cur = child;
            }
        }
    }

    fn contains(K k) -> bool {
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

    fn get(K k, V fallback) -> V {
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

    fn find_parent(int idx) -> int {
        let p = 0 - 1;
        let cur = self.root;
        let target_key = self.keys[idx];
        while cur >= 0 {
            if cur == idx {
                return p;
            }
            // Walk by key order — node indices are allocation slots, not BST keys.
            if target_key < self.keys[cur] {
                p = cur;
                cur = self.left[cur];
            } else {
                p = cur;
                cur = self.right[cur];
            }
        }
        return 0 - 1;
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

    fn remove(K k) -> bool {
        let cur = self.root;
        let target = 0 - 1;
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
                self.set_child_of(parent, target, 0 - 1);
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

    fn min_key(K fallback) -> K {
        if self.root < 0 {
            return fallback;
        }
        let n = self.min_node(self.root);
        return self.keys[n];
    }

    fn max_key(K fallback) -> K {
        if self.root < 0 {
            return fallback;
        }
        let n = self.max_node(self.root);
        return self.keys[n];
    }
}

impl IntoIterator<TreeMap<K, V>> {
    type Item = Entry<K, V>;
    type IntoIter = TreeMapIter<K, V>;
    fn into_iter(TreeMap<K, V> m) -> TreeMapIter<K, V> {
        let stack: Vec<int> = Vec::new();
        return new TreeMapIter(m, stack, 0);
    }
}

impl Iterator<TreeMapIter<K, V>> {
    type Item = Entry<K, V>;
    fn next(TreeMapIter<K, V> it) -> Option<Entry<K, V>> {
        if it.phase == 0 {
            let cur = it.map.root;
            while cur >= 0 {
                it.stack.push(cur);
                cur = it.map.left[cur];
            }
            it.phase = 1;
        }
        return match it.stack.pop() {
            Option::None => Option::None,
            Option::Some(node) => {
                let right = it.map.right[node];
                let cur = right;
                while cur >= 0 {
                    it.stack.push(cur);
                    cur = it.map.left[cur];
                }
                let e = new Entry(it.map.keys[node], it.map.vals[node]);
                return Option::Some(e);
            },
        };
    }
}
