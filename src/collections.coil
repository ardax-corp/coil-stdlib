// Collection helpers (userland): sort, reverse, range materialize.

// Merge `buf[lo..mid)` and `buf[mid..hi)` via `tmp` scratch (stable).
fn merge_range<T: Ord>(Vec<T> buf, Vec<T> tmp, int lo, int mid, int hi) -> int {
    let i = lo;
    while i < hi {
        tmp[i] = buf[i];
        i = i + 1;
    }
    let a = lo;
    let b = mid;
    let k = lo;
    while a < mid {
        if b < hi {
            if tmp[b] < tmp[a] {
                buf[k] = tmp[b];
                b = b + 1;
            } else {
                buf[k] = tmp[a];
                a = a + 1;
            }
            k = k + 1;
        } else {
            break;
        }
    }
    while a < mid {
        buf[k] = tmp[a];
        a = a + 1;
        k = k + 1;
    }
    while b < hi {
        buf[k] = tmp[b];
        b = b + 1;
        k = k + 1;
    }
    return 0;
}

fn min_int(int a, int b) -> int
    ensures result <= a && result <= b
    ensures result == a || result == b
{
    if a < b {
        return a;
    }
    return b;
}

/// Returns a sorted copy of `arr`, in ascending order.
///
/// The sort is stable (equal elements keep their order) and takes `O(n log n)`
/// time. `arr` itself is not changed. Elements need `Ord`; strings compare by
/// their UTF-8 bytes, so `"B"` sorts before `"a"`.
///
/// # Examples
///
/// ```
/// use collections::{sort};
/// # use tests::assert;
/// let xs: Vec<int> = [3, 1, 2];
/// let s = sort(xs);
/// assert!(s[0] == 1 && s[2] == 3);
/// assert!(xs[0] == 3);
/// let words: Vec<string> = ["pear", "Apple", "fig"];
/// assert!(sort(words)[0] == "Apple");
/// ```
fn sort<T: Ord>(Vec<T> arr) -> Vec<T>
    ensures result.len() == arr.len()
{
    let n = arr.len();
    let out: Vec<T> = Vec::new();
    let tmp: Vec<T> = Vec::new();
    let copy_i = 0;
    while copy_i < n {
        out.push(arr[copy_i]);
        tmp.push(arr[copy_i]);
        copy_i = copy_i + 1;
    }
    let width = 1;
    while width < n {
        let pos = 0;
        while pos < n {
            let lo = pos;
            let mid = min_int(pos + width, n);
            let hi = min_int(pos + width + width, n);
            if mid < hi {
                merge_range(out, tmp, lo, mid, hi);
            }
            pos = pos + width + width;
        }
        width = width + width;
    }
    return out;
}

// Stable mergesort by `key` (`K: Ord`). Input unchanged; equal keys keep order.
fn merge_range_by<T, K: Ord>(Vec<T> buf, Vec<T> tmp, int lo, int mid, int hi, T -> K key) -> int {
    let i = lo;
    while i < hi {
        tmp[i] = buf[i];
        i = i + 1;
    }
    let a = lo;
    let b = mid;
    let k = lo;
    while a < mid {
        if b < hi {
            if key(tmp[b]) < key(tmp[a]) {
                buf[k] = tmp[b];
                b = b + 1;
            } else {
                buf[k] = tmp[a];
                a = a + 1;
            }
            k = k + 1;
        } else {
            break;
        }
    }
    while a < mid {
        buf[k] = tmp[a];
        a = a + 1;
        k = k + 1;
    }
    while b < hi {
        buf[k] = tmp[b];
        b = b + 1;
        k = k + 1;
    }
    return 0;
}

/// Returns a copy of `arr` sorted by the value `key` gives each element, in ascending order.
///
/// Stable: elements with equal keys keep their order. `key` is called for each
/// comparison, so keep it cheap.
///
/// # Examples
///
/// ```
/// use collections::{sort_by};
/// # use tests::assert;
/// let words: Vec<string> = ["kiwi", "fig", "banana"];
/// let by_len = sort_by(words, fn (string w) => w.len());
/// assert!(by_len[0] == "fig");
/// assert!(by_len[2] == "banana");
/// ```
fn sort_by<T, K: Ord>(Vec<T> arr, T -> K key) -> Vec<T> {
    let n = arr.len();
    let out: Vec<T> = Vec::new();
    let tmp: Vec<T> = Vec::new();
    let copy_i = 0;
    while copy_i < n {
        out.push(arr[copy_i]);
        tmp.push(arr[copy_i]);
        copy_i = copy_i + 1;
    }
    let width = 1;
    while width < n {
        let pos = 0;
        while pos < n {
            let lo = pos;
            let mid = min_int(pos + width, n);
            let hi = min_int(pos + width + width, n);
            if mid < hi {
                merge_range_by(out, tmp, lo, mid, hi, key);
            }
            pos = pos + width + width;
        }
        width = width + width;
    }
    return out;
}

/// Returns a copy of `arr` in reverse order.
///
/// # Examples
///
/// ```
/// use collections::{reverse};
/// # use tests::assert;
/// let xs: Vec<int> = [1, 2, 3];
/// assert!(reverse(xs)[0] == 3);
/// ```
fn reverse<T>(Vec<T> arr) -> Vec<T>
    ensures result.len() == arr.len()
{
    let n = arr.len();
    let out: Vec<T> = Vec::new();
    let i = n;
    while i > 0 {
        i = i - 1;
        out.push(arr[i]);
    }
    return out;
}

/// Returns the values of the range `a..b` as a `Vec<int>`.
///
/// `(a..b).to_vec()` does the same.
///
/// # Examples
///
/// ```
/// use collections::{collect_ints};
/// # use tests::assert;
/// let v = collect_ints(2..5);
/// assert!(v.len() == 3 && v[0] == 2);
/// ```
fn collect_ints(Range<int> r) -> Vec<int> {
    let out: Vec<int> = Vec::new();
    for x in r {
        out.push(x);
    }
    return out;
}

/// Returns the values of the inclusive range `a..=b` as a `Vec<int>`.
fn collect_ints_inclusive(RangeInclusive<int> r) -> Vec<int> {
    let out: Vec<int> = Vec::new();
    for x in r {
        out.push(x);
    }
    return out;
}
