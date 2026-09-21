// Mutable singly-linked list with O(1) push/pop at the front.

class Node<T> {
    pub value: T,
    pub next: Option<Node<T>>,
}

class List<T> {
    head: Option<Node<T>>,
    len: int,
}

class ListIter<T> {
    pub node: Option<Node<T>>,
}

impl List<T> {
    pub static fn new() -> List<T> {
        return new List(Option::None, 0);
    }

    pub fn size() -> int {
        return self.len;
    }

    pub fn is_empty() -> bool {
        return self.len == 0;
    }

    pub fn push_front(T v) {
        let n = new Node(v, self.head);
        self.head = Option::Some(n);
        self.len = self.len + 1;
    }

    pub fn push_back(T v) {
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
                        };
                    },
                };
            }
        }
        self.len = self.len + 1;
    }

    pub fn peek_front() -> Option<T> {
        return match self.head {
            Option::None => Option::None,
            Option::Some(n) => Option::Some(n.value),
        };
    }

    pub fn pop_front() -> Option<T> {
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

    pub fn pop_back() -> Option<T> {
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
                    };
                },
            };
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
                };
                self.len = self.len - 1;
                return Option::Some(v);
            },
        };
    }

    pub fn clear() {
        self.head = Option::None;
        self.len = 0;
    }

    pub fn to_vec() -> Vec<T> {
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
            };
        }
        return out;
    }

    pub fn iter() -> ListIter<T> {
        return new ListIter(self.head);
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
        return match it.node {
            Option::None => Option::None,
            Option::Some(n) => {
                let v = n.value;
                it.node = n.next;
                return Option::Some(v);
            },
        };
    }
}
