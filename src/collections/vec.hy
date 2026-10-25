// `Vec<T>` methods (userland). Each trait is implemented for `Vec<T>`, so
// `xs.map(f).filter(g)` reads left to right: `VecOps` for any element,
// `VecEq` / `VecOrd` where the element is `Eq` / `Ord`, `VecSum` for
// `Vec<int>` and `Vec<float>`. Every method returns a new vector or value
// and leaves `xs` as it was.

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

/// Methods on any `Vec<T>`.
///
/// # Examples
///
/// ```
/// use collections::vec::{VecOps};
/// # use tests::assert;
/// let xs: Vec<int> = [1, 2, 3, 4];
/// let big = xs.map(fn (int x) => x * 10).filter(fn (int x) => x > 15);
/// assert!(big.len() == 3 && big[0] == 20);
/// assert!(xs.fold(0, fn (int acc, int x) => acc + x) == 10);
/// for (i, x) in xs.enumerate() {
///     assert!(xs[i] == x);
/// }
/// ```
trait VecOps<V> {
    type Item;

    /// Returns a new vector with `mapper` applied to each element, in order.
    fn map<U>(V xs, Item -> U mapper) -> Vec<U> {}

    /// Returns the elements for which `pred` is `true`, in order.
    fn filter(V xs, Item -> bool pred) -> Vec<Item> {}

    /// Combines the elements left to right: starts from `init` and replaces
    /// the accumulator with `folder(acc, x)` for each `x`.
    fn fold<A>(V xs, A init, A -> Item -> A folder) -> A {}

    /// Returns `(index, element)` pairs, so `for (i, x) in xs.enumerate()` works.
    fn enumerate(V xs) -> Vec<(int, Item)> {}

    /// Returns `(xs[i], ys[i])` pairs up to the shorter of the two vectors.
    fn zip<U>(V xs, Vec<U> ys) -> Vec<(Item, U)> {}

    /// Returns `true` when `pred` holds for some element (`false` when empty).
    fn any(V xs, Item -> bool pred) -> bool {}

    /// Returns `true` when `pred` holds for every element (`true` when empty).
    fn all(V xs, Item -> bool pred) -> bool {}

    /// Returns how many elements `pred` holds for.
    fn count(V xs, Item -> bool pred) -> int {}

    /// Returns the first `n` elements (all of them when `n` is larger, none when `n <= 0`).
    fn take(V xs, int n) -> Vec<Item> {}

    /// Returns the elements after the first `n` (all of them when `n <= 0`).
    fn skip(V xs, int n) -> Vec<Item> {}

    /// Returns the first element, or `None` when `xs` is empty.
    fn first(V xs) -> Option<Item> {}

    /// Returns the last element, or `None` when `xs` is empty.
    fn last(V xs) -> Option<Item> {}

    /// Returns a new vector holding the elements of `xs` followed by those of `ys`.
    fn concat(V xs, Vec<Item> ys) -> Vec<Item> {}

    /// Consecutive non-overlapping slices of `size` (the last one may be short).
    /// Empty when `size <= 0`.
    fn chunks(V xs, int size) -> Vec<Vec<Item>> {}

    /// Overlapping sliding windows of exactly `size`. Empty if `size <= 0` or `size > len`.
    fn windows(V xs, int size) -> Vec<Vec<Item>> {}

    /// Splits `xs` into (`matched`, `rest`) by `pred`. Order inside each bucket is kept.
    fn partition(V xs, Item -> bool pred) -> Partitioned<Item> {}
}

impl VecOps for Vec<T> {
    type Item = T;

    pub fn map<U>(Vec<T> xs, T -> U mapper) -> Vec<U> {
        let out: Vec<U> = Vec::with_capacity(xs.len());
        let i = 0;
        while i < xs.len() {
            out.push(mapper(xs[i]));
            i = i + 1;
        }
        return out;
    }

    pub fn filter(Vec<T> xs, T -> bool pred) -> Vec<T> {
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

    pub fn fold<A>(Vec<T> xs, A init, A -> T -> A folder) -> A {
        let acc = init;
        let i = 0;
        while i < xs.len() {
            acc = folder(acc, xs[i]);
            i = i + 1;
        }
        return acc;
    }

    pub fn enumerate(Vec<T> xs) -> Vec<(int, T)>
        ensures result.len() == xs.len()
    {
        let out: Vec<(int, T)> = Vec::with_capacity(xs.len());
        let i = 0;
        while i < xs.len() {
            out.push((i, xs[i]));
            i = i + 1;
        }
        return out;
    }

    pub fn zip<U>(Vec<T> xs, Vec<U> ys) -> Vec<(T, U)>
        ensures result.len() <= xs.len() && result.len() <= ys.len()
    {
        let out: Vec<(T, U)> = Vec::new();
        let i = 0;
        while i < xs.len() && i < ys.len() {
            out.push((xs[i], ys[i]));
            i = i + 1;
        }
        return out;
    }

    pub fn any(Vec<T> xs, T -> bool pred) -> bool {
        let i = 0;
        while i < xs.len() {
            if pred(xs[i]) {
                return true;
            }
            i = i + 1;
        }
        return false;
    }

    pub fn all(Vec<T> xs, T -> bool pred) -> bool {
        let i = 0;
        while i < xs.len() {
            if !pred(xs[i]) {
                return false;
            }
            i = i + 1;
        }
        return true;
    }

    pub fn count(Vec<T> xs, T -> bool pred) -> int
        ensures result >= 0 && result <= xs.len()
    {
        let n = 0;
        let i = 0;
        while i < xs.len() {
            if pred(xs[i]) {
                n = n + 1;
            }
            i = i + 1;
        }
        return n;
    }

    pub fn take(Vec<T> xs, int n) -> Vec<T>
        ensures result.len() <= xs.len()
    {
        let out: Vec<T> = Vec::new();
        let i = 0;
        while i < n && i < xs.len() {
            out.push(xs[i]);
            i = i + 1;
        }
        return out;
    }

    pub fn skip(Vec<T> xs, int n) -> Vec<T>
        ensures result.len() <= xs.len()
    {
        let out: Vec<T> = Vec::new();
        let i = n;
        if i < 0 {
            i = 0;
        }
        while i < xs.len() {
            out.push(xs[i]);
            i = i + 1;
        }
        return out;
    }

    pub fn first(Vec<T> xs) -> Option<T> {
        if xs.len() == 0 {
            return Option::None;
        }
        return Option::Some(xs[0]);
    }

    pub fn last(Vec<T> xs) -> Option<T> {
        let n = xs.len();
        if n == 0 {
            return Option::None;
        }
        return Option::Some(xs[n - 1]);
    }

    pub fn concat(Vec<T> xs, Vec<T> ys) -> Vec<T>
        ensures result.len() == xs.len() + ys.len()
    {
        let out: Vec<T> = Vec::with_capacity(xs.len() + ys.len());
        let i = 0;
        while i < xs.len() {
            out.push(xs[i]);
            i = i + 1;
        }
        let j = 0;
        while j < ys.len() {
            out.push(ys[j]);
            j = j + 1;
        }
        return out;
    }

    pub fn chunks(Vec<T> xs, int size) -> Vec<Vec<T>> {
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

    pub fn windows(Vec<T> xs, int size) -> Vec<Vec<T>> {
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

    pub fn partition(Vec<T> xs, T -> bool pred) -> Partitioned<T> {
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
}

/// Methods on a `Vec<T>` whose elements are [`Eq`].
///
/// # Examples
///
/// ```
/// use collections::vec::{VecEq};
/// # use tests::assert;
/// let xs: Vec<float> = [1.5, 1.5, 2.5];
/// assert!(xs.contains(2.5));
/// assert!(xs.index_of(2.5) == Option::Some(2));
/// assert!(xs.dedup().len() == 2);
/// ```
trait VecEq<V> {
    type Item;

    /// Returns `true` when `needle` is in `xs`.
    fn contains(V xs, Item needle) -> bool {}

    /// Returns the index of the first `needle` in `xs`, or `None`.
    fn index_of(V xs, Item needle) -> Option<int> {}

    /// Returns `xs` with runs of equal neighbours collapsed to one value.
    ///
    /// Only adjacent duplicates are removed; sort first to remove all of them.
    fn dedup(V xs) -> Vec<Item> {}
}

impl VecEq for Vec<T: Eq> {
    type Item = T;

    pub fn contains(Vec<T> xs, T needle) -> bool
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

    pub fn index_of(Vec<T> xs, T needle) -> Option<int> {
        let i = 0;
        while i < xs.len() {
            if xs[i] == needle {
                return Option::Some(i);
            }
            i = i + 1;
        }
        return Option::None;
    }

    pub fn dedup(Vec<T> xs) -> Vec<T>
        ensures result.len() <= xs.len()
        ensures xs.len() == 0 || result.len() > 0
    {
        let out: Vec<T> = Vec::new();
        let i = 0;
        while i < xs.len() {
            if i == 0 || xs[i] != xs[i - 1] {
                out.push(xs[i]);
            }
            i = i + 1;
        }
        return out;
    }
}

/// Methods on a `Vec<T>` whose elements are [`Ord`].
///
/// # Examples
///
/// ```
/// use collections::vec::{VecOrd};
/// # use tests::assert;
/// let xs: Vec<int> = [1, 3, 5, 7, 9];
/// assert!(xs.min() == Option::Some(1) && xs.max() == Option::Some(9));
/// assert!((xs.binary_search(7) ?? -1) == 3);
/// assert!(xs.binary_search(4).is_none());
/// ```
trait VecOrd<V> {
    type Item;

    /// Returns the smallest element (the first of equal ones), or `None` when `xs` is empty.
    fn min(V xs) -> Option<Item> {}

    /// Returns the largest element (the first of equal ones), or `None` when `xs` is empty.
    fn max(V xs) -> Option<Item> {}

    /// Finds `needle` in the ascending vector `xs` by halving, and returns an index holding it.
    ///
    /// `xs` must be sorted (`collections::sort` does that); on an unsorted vector the
    /// result is unreliable. With duplicates, any matching index may be returned.
    fn binary_search(V xs, Item needle) -> Option<int> {}
}

impl VecOrd for Vec<T: Ord> {
    type Item = T;

    pub fn min(Vec<T> xs) -> Option<T> {
        if xs.len() == 0 {
            return Option::None;
        }
        let best = xs[0];
        let i = 1;
        while i < xs.len() {
            if xs[i] < best {
                best = xs[i];
            }
            i = i + 1;
        }
        return Option::Some(best);
    }

    pub fn max(Vec<T> xs) -> Option<T> {
        if xs.len() == 0 {
            return Option::None;
        }
        let best = xs[0];
        let i = 1;
        while i < xs.len() {
            if xs[i] > best {
                best = xs[i];
            }
            i = i + 1;
        }
        return Option::Some(best);
    }

    pub fn binary_search(Vec<T> xs, T needle) -> Option<int> {
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
}

/// `xs.sum()` on `Vec<int>` and `Vec<float>`; an empty vector sums to zero.
///
/// # Examples
///
/// ```
/// use collections::vec::{VecSum};
/// # use tests::assert;
/// let xs: Vec<int> = [1, 2, 3];
/// let fs: Vec<float> = [0.5, 0.25];
/// assert!(xs.sum() == 6 && fs.sum() == 0.75);
/// ```
trait VecSum<V> {
    type Item;

    /// Returns the sum of the elements (overflow traps, as `+` does).
    fn sum(V xs) -> Item {}
}

impl VecSum for Vec<int> {
    type Item = int;

    pub fn sum(Vec<int> xs) -> int {
        let total = 0;
        let i = 0;
        while i < xs.len() {
            total = total + xs[i];
            i = i + 1;
        }
        return total;
    }
}

impl VecSum for Vec<float> {
    type Item = float;

    pub fn sum(Vec<float> xs) -> float {
        let total = 0.0;
        let i = 0;
        while i < xs.len() {
            total = total + xs[i];
            i = i + 1;
        }
        return total;
    }
}
