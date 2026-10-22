/// The same as `fold`; kept for older code.
fn fold_int(Vec<int> xs, int init, int -> int -> int folder) -> int {
    let acc = init;
    let i = 0;
    while i < xs.len() {
        let step = folder(acc);
        acc = step(xs[i]);
        i = i + 1;
    }
    return acc;
}

/// Returns `true` when `needle` is in `xs`. There is an `int` and a `string` version.
///
/// # Examples
///
/// ```
/// use collections::vec::{contains};
/// # use tests::assert;
/// let xs: Vec<int> = [3, 1, 4];
/// assert!(contains(xs, 4));
/// let names: Vec<string> = ["ada", "alan"];
/// assert!(!contains(names, "grace"));
/// ```
fn contains(Vec<int> xs, int needle) -> bool
    ensures !result || xs.len() > 0
{
    let i = 0;
    while i < xs.len() {
        if xs[i] == needle {
            return true;
        }
        i = i + 1;
    }
    return false;
}

/// Returns the index of the first `needle` in `xs`, or `-1`. There is an `int` and a `string` version.
///
/// # Examples
///
/// ```
/// use collections::vec::{index_of};
/// # use tests::assert;
/// let xs: Vec<int> = [3, 1, 4, 1];
/// assert!(index_of(xs, 1) == 1);
/// assert!(index_of(xs, 9) == -1);
/// ```
fn index_of(Vec<int> xs, int needle) -> int
    ensures result >= -1 && result < xs.len()
    ensures result < 0 || xs[result] == needle
{
    let i = 0;
    while i < xs.len() {
        if xs[i] == needle {
            return i;
        }
        i = i + 1;
    }
    return 0 - 1;
}

/// Finds `needle` in the ascending vector `xs` by halving, and returns an index holding it.
///
/// `xs` must be sorted (`collections::sort` does that); on an unsorted vector the
/// result is unreliable. With duplicates, any matching index may be returned.
///
/// # Examples
///
/// ```
/// use collections::vec::{binary_search};
/// # use tests::assert;
/// let xs: Vec<int> = [1, 3, 5, 7, 9];
/// assert!((binary_search(xs, 7) ?? -1) == 3);
/// assert!(binary_search(xs, 4).is_none());
/// ```
fn binary_search(Vec<int> xs, int needle) -> Option<int>
    ensures found_at(xs, needle, result)
{
    let lo = 0;
    let hi = xs.len();
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

// `found` is `None` or an index of `needle` in `xs` (for contracts).
fn found_at(Vec<int> xs, int needle, Option<int> found) -> bool {
    return match found {
        Option::None => true,
        Option::Some(i) => i >= 0 && i < xs.len() && xs[i] == needle,
    };
}

/// Returns `xs` with runs of equal neighbours collapsed to one value. There is an `int` and a `string` version.
///
/// Only adjacent duplicates are removed; sort first to remove all of them.
///
/// # Examples
///
/// ```
/// use collections::vec::{dedup};
/// # use tests::assert;
/// let xs: Vec<int> = [1, 1, 2, 2, 2, 1];
/// let d = dedup(xs);
/// assert!(d.len() == 3);
/// ```
fn dedup(Vec<int> xs) -> Vec<int>
    ensures result.len() <= xs.len()
    ensures xs.len() == 0 || result.len() > 0
{
    if xs.len() == 0 {
        let empty: Vec<int> = Vec::new();
        return empty;
    }
    let out: Vec<int> = Vec::new();
    out.push(xs[0]);
    let i = 1;
    while i < xs.len() {
        if xs[i] != xs[i - 1] {
            out.push(xs[i]);
        }
        i = i + 1;
    }
    return out;
}

/// Returns `true` when `needle` is in `xs`.
fn contains(Vec<string> xs, string needle) -> bool
    ensures !result || xs.len() > 0
{
    let i = 0;
    while i < xs.len() {
        if xs[i] == needle {
            return true;
        }
        i = i + 1;
    }
    return false;
}

/// Returns the index of the first `needle` in `xs`, or `-1`.
fn index_of(Vec<string> xs, string needle) -> int
    ensures result >= -1 && result < xs.len()
    ensures result < 0 || xs[result] == needle
{
    let i = 0;
    while i < xs.len() {
        if xs[i] == needle {
            return i;
        }
        i = i + 1;
    }
    return 0 - 1;
}

/// Returns `xs` with runs of equal neighbours collapsed to one value.
fn dedup(Vec<string> xs) -> Vec<string>
    ensures result.len() <= xs.len()
    ensures xs.len() == 0 || result.len() > 0
{
    if xs.len() == 0 {
        let empty: Vec<string> = Vec::new();
        return empty;
    }
    let out: Vec<string> = Vec::new();
    out.push(xs[0]);
    let i = 1;
    while i < xs.len() {
        if xs[i] != xs[i - 1] {
            out.push(xs[i]);
        }
        i = i + 1;
    }
    return out;
}

/// Returns a new vector with `mapper` applied to each element, in order.
///
/// # Examples
///
/// ```
/// use collections::vec::{map};
/// use string::{format};
/// # use tests::assert;
/// let xs: Vec<int> = [1, 2, 3];
/// let squares = map(xs, fn (int x) => x * x);
/// assert!(squares[2] == 9);
/// let labels = map(xs, fn (int x) => format("#%i", x));
/// assert!(labels[0] == "#1");
/// ```
fn map<T, U>(Vec<T> xs, T -> U mapper) -> Vec<U> {
    let out: Vec<U> = Vec::new();
    let i = 0;
    while i < xs.len() {
        out.push(mapper(xs[i]));
        i = i + 1;
    }
    return out;
}

/// Returns the elements for which `pred` is `true`, in order.
///
/// # Examples
///
/// ```
/// use collections::vec::{filter};
/// # use tests::assert;
/// let xs: Vec<int> = [1, 2, 3, 4];
/// let even = filter(xs, fn (int x) => x % 2 == 0);
/// assert!(even.len() == 2 && even[0] == 2);
/// ```
fn filter<T>(Vec<T> xs, T -> bool pred) -> Vec<T> {
    let out: Vec<T> = Vec::new();
    let i = 0;
    while i < xs.len() {
        if pred(xs[i]) {
            out.push(xs[i]);
        }
        i = i + 1;
    }
    return out;
}

/// Returns the first element, or `None` when `xs` is empty.
///
/// # Examples
///
/// ```
/// use collections::vec::{first};
/// # use tests::assert;
/// let xs: Vec<string> = ["a", "b"];
/// assert!((first(xs) ?? "") == "a");
/// let none: Vec<int> = Vec::new();
/// assert!(first(none).is_none());
/// ```
fn first<T>(Vec<T> xs) -> Option<T> {
    if xs.len() == 0 {
        return Option::None;
    }
    return Option::Some(xs[0]);
}

/// Returns the last element, or `None` when `xs` is empty.
fn last<T>(Vec<T> xs) -> Option<T> {
    let n = xs.len();
    if n == 0 {
        return Option::None;
    }
    return Option::Some(xs[n - 1]);
}

/// Returns a new vector holding the elements of `a` followed by those of `b`.
fn concat<T>(Vec<T> a, Vec<T> b) -> Vec<T>
    ensures result.len() == a.len() + b.len()
{
    let out: Vec<T> = Vec::new();
    let i = 0;
    while i < a.len() {
        out.push(a[i]);
        i = i + 1;
    }
    let j = 0;
    while j < b.len() {
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
    while i < xs.len() {
        let chunk: Vec<T> = Vec::new();
        let j = 0;
        while j < size {
            if i + j < xs.len() {
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
    let n = xs.len();
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
/// The elements for which the predicate was `true`.
    pub fn matched() -> Vec<T> {
        return self.matched;
    }

/// The elements for which the predicate was `false`.
    pub fn rest() -> Vec<T> {
        return self.rest;
    }
}

/// Split `xs` into (`matched`, `rest`) by `pred`. Order inside each bucket is preserved.
fn partition<T>(Vec<T> xs, T -> bool pred) -> Partitioned<T> {
    let matched: Vec<T> = Vec::new();
    let rest: Vec<T> = Vec::new();
    let i = 0;
    while i < xs.len() {
        if pred(xs[i]) {
            matched.push(xs[i]);
        } else {
            rest.push(xs[i]);
        }
        i = i + 1;
    }
    return new Partitioned(matched, rest);
}

/// Combines the elements left to right: starts from `init` and replaces the accumulator with `folder(acc)(x)` for each `x`.
///
/// `folder` is curried: it takes the accumulator and returns a function of the
/// element. Only `Vec<int>` is supported for now.
///
/// # Examples
///
/// ```
/// use collections::vec::{fold};
/// # use tests::assert;
/// let xs: Vec<int> = [1, 2, 3, 4];
/// let total = fold(xs, 0, fn (int acc) => fn (int x) use (acc) => acc + x);
/// assert!(total == 10);
/// ```
fn fold(Vec<int> xs, int init, int -> int -> int folder) -> int {
    let acc = init;
    let i = 0;
    while i < xs.len() {
        let step = folder(acc);
        acc = step(xs[i]);
        i = i + 1;
    }
    return acc;
}
