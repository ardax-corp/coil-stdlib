fn fold_int(Vec<int> xs, int init, int -> int -> int folder) -> int {
    let acc = init;
    let i = 0;
    while i < len(xs) {
        let step = folder(acc);
        acc = step(xs[i]);
        i = i + 1;
    }
    return acc;
}

fn contains(Vec<int> xs, int needle) -> bool {
    let i = 0;
    while i < len(xs) {
        if xs[i] == needle {
            return true;
        }
        i = i + 1;
    }
    return false;
}

fn index_of(Vec<int> xs, int needle) -> int {
    let i = 0;
    while i < len(xs) {
        if xs[i] == needle {
            return i;
        }
        i = i + 1;
    }
    return 0 - 1;
}

fn binary_search(Vec<int> xs, int needle) -> Option<int> {
    let lo = 0;
    let hi = len(xs);
    while lo < hi {
        let mid = lo + (hi - lo) / 2;
        if xs[mid] < needle {
            lo = mid + 1;
        } else {
            if needle < xs[mid] {
                hi = mid;
            } else {
                return Option::Some(mid);
            }
        }
    }
    return Option::None;
}

fn dedup(Vec<int> xs) -> Vec<int> {
    if len(xs) == 0 {
        let empty: Vec<int> = Vec::new();
        return empty;
    }
    let out: Vec<int> = Vec::new();
    out.push(xs[0]);
    let i = 1;
    while i < len(xs) {
        if xs[i] != xs[i - 1] {
            out.push(xs[i]);
        }
        i = i + 1;
    }
    return out;
}

fn contains(Vec<string> xs, string needle) -> bool {
    let i = 0;
    while i < len(xs) {
        if xs[i] == needle {
            return true;
        }
        i = i + 1;
    }
    return false;
}

fn index_of(Vec<string> xs, string needle) -> int {
    let i = 0;
    while i < len(xs) {
        if xs[i] == needle {
            return i;
        }
        i = i + 1;
    }
    return 0 - 1;
}

fn dedup(Vec<string> xs) -> Vec<string> {
    if len(xs) == 0 {
        let empty: Vec<string> = Vec::new();
        return empty;
    }
    let out: Vec<string> = Vec::new();
    out.push(xs[0]);
    let i = 1;
    while i < len(xs) {
        if xs[i] != xs[i - 1] {
            out.push(xs[i]);
        }
        i = i + 1;
    }
    return out;
}

fn map<T, U>(Vec<T> xs, T -> U mapper) -> Vec<U> {
    let out: Vec<U> = Vec::new();
    let i = 0;
    while i < len(xs) {
        out.push(mapper(xs[i]));
        i = i + 1;
    }
    return out;
}

fn filter<T>(Vec<T> xs, T -> bool pred) -> Vec<T> {
    let out: Vec<T> = Vec::new();
    let i = 0;
    while i < len(xs) {
        if pred(xs[i]) {
            out.push(xs[i]);
        }
        i = i + 1;
    }
    return out;
}

fn first<T>(Vec<T> xs) -> Option<T> {
    if len(xs) == 0 {
        return Option::None;
    }
    return Option::Some(xs[0]);
}

fn last<T>(Vec<T> xs) -> Option<T> {
    let n = len(xs);
    if n == 0 {
        return Option::None;
    }
    return Option::Some(xs[n - 1]);
}

fn concat<T>(Vec<T> a, Vec<T> b) -> Vec<T> {
    let out: Vec<T> = Vec::new();
    let i = 0;
    while i < len(a) {
        out.push(a[i]);
        i = i + 1;
    }
    let j = 0;
    while j < len(b) {
        out.push(b[j]);
        j = j + 1;
    }
    return out;
}

/// Consecutive non-overlapping slices of `size` (last slice may be short).
/// Empty when `size <= 0`. Name is `chunks` (no `chunk` alias).
fn chunks<T>(Vec<T> xs, int size) -> Vec<Vec<T>> {
    let out: Vec<Vec<T>> = Vec::new();
    if size <= 0 {
        return out;
    }
    let i = 0;
    while i < len(xs) {
        let chunk: Vec<T> = Vec::new();
        let j = 0;
        while j < size {
            if i + j < len(xs) {
                chunk.push(xs[i + j]);
            }
            j = j + 1;
        }
        out.push(chunk);
        i = i + size;
    }
    return out;
}

/// Overlapping sliding windows of exact `size`. Empty if `size <= 0` or `size > len`.
fn windows<T>(Vec<T> xs, int size) -> Vec<Vec<T>> {
    let out: Vec<Vec<T>> = Vec::new();
    let n = len(xs);
    if size <= 0 {
        return out;
    }
    if size > n {
        return out;
    }
    let i = 0;
    while i + size <= n {
        let w: Vec<T> = Vec::new();
        let j = 0;
        while j < size {
            w.push(xs[i + j]);
            j = j + 1;
        }
        out.push(w);
        i = i + 1;
    }
    return out;
}

/// Two-bucket result of `partition` (`matched` = pred true, `rest` = pred false).
/// Named pair instead of `Vec<Vec<T>>` so callers do not index `[0]`/`[1]`.
class Partitioned<T> {
    matched: Vec<T>,
    rest: Vec<T>,
}

impl Partitioned<T> {
    fn matched() -> Vec<T> {
        return self.matched;
    }

    fn rest() -> Vec<T> {
        return self.rest;
    }
}

/// Split `xs` into (`matched`, `rest`) by `pred`. Order inside each bucket is preserved.
fn partition<T>(Vec<T> xs, T -> bool pred) -> Partitioned<T> {
    let matched: Vec<T> = Vec::new();
    let rest: Vec<T> = Vec::new();
    let i = 0;
    while i < len(xs) {
        if pred(xs[i]) {
            matched.push(xs[i]);
        } else {
            rest.push(xs[i]);
        }
        i = i + 1;
    }
    return new Partitioned(matched, rest);
}

fn fold(Vec<int> xs, int init, int -> int -> int folder) -> int {
    let acc = init;
    let i = 0;
    while i < len(xs) {
        let step = folder(acc);
        acc = step(xs[i]);
        i = i + 1;
    }
    return acc;
}
