// Shared mutable cell.
//
// Lambda, `defer` and task `use (x)` captures are snapshots: assigning to a
// captured local changes only the copy. A `Ref<T>` is a heap object, so every
// holder of the same `Ref` sees each `set`.

class Ref<T> {
    value: T,
}

impl Ref<T> {
    /// New cell holding `value`.
    pub static fn new(T value) -> Ref<T> {
        return new Ref(value);
    }

    /// Current value.
    pub fn get() -> T {
        return self.value;
    }

    /// Store `value`.
    pub fn set(T value) {
        self.value = value;
    }

    /// Store `value` and return the previous one.
    pub fn replace(T value) -> T {
        let old = self.value;
        self.value = value;
        return old;
    }

    /// Store `f(current)` and return the new value.
    pub fn update(T -> T f) -> T {
        let next = f(self.value);
        self.value = next;
        return next;
    }
}
