// Incremental string builder (userland). `string::format` remains a compiler intrinsic.
use conv::{int_to_dec, int_to_hex};

/// A string builder: append pieces, then take the text with `to_string`.
///
/// # Examples
///
/// ```
/// use fmt::{Buf};
/// # use tests::assert;
/// let b = Buf::new();
/// b.push_str("id=");
/// b.push_int(42);
/// b.push_str(" mask=0x");
/// b.push_hex(255);
/// assert!(b.to_string() == "id=42 mask=0xff");
/// ```
class Buf {
    text: string,
}

impl Buf {
    /// Creates an empty builder.
    pub static fn new() -> Buf {
        return new Buf("");
    }

    /// Appends `s`.
    pub fn push_str(string s) {
        self.text = self.text + s;
    }

    /// Appends `n` in decimal.
    ///
    /// # Examples
    ///
    /// ```
    /// use fmt::{Buf};
    /// # use tests::assert;
    /// let b = Buf::new();
    /// b.push_int(-7);
    /// assert!(b.to_string() == "-7");
    /// ```
    pub fn push_int(int n) {
        self.text = self.text + int_to_dec(n);
    }

    /// Appends `n` in lowercase hexadecimal, without a `0x` prefix.
    pub fn push_hex(int n) {
        self.text = self.text + int_to_hex(n);
    }

    /// Returns the text built so far.
    pub fn to_string() -> string {
        return self.text;
    }

    /// Pads the text on the left with `fill` until it is at least `width` bytes long, and returns the builder.
    ///
    /// `fill` is repeated whole, so a multi-byte `fill` can overshoot `width`. Text
    /// already at least `width` long is unchanged.
    ///
    /// # Examples
    ///
    /// ```
    /// use fmt::{Buf};
    /// # use tests::assert;
    /// let b = Buf::new();
    /// b.push_int(7);
    /// assert!(b.pad_left(3, "0").to_string() == "007");
    /// ```
    pub fn pad_left(int width, string fill) -> Buf {
        let need = width - self.text.len();
        let pad = "";
        let i = 0;
        while i < need {
            pad = pad + fill;
            i = i + 1;
        }
        self.text = pad + self.text;
        return self;
    }

    /// Pads the text on the right with `fill` until it is at least `width` bytes long, and returns the builder.
    ///
    /// # Examples
    ///
    /// ```
    /// use fmt::{Buf};
    /// # use tests::assert;
    /// let b = Buf::new();
    /// b.push_str("ab");
    /// assert!(b.pad_right(4, ".").to_string() == "ab..");
    /// ```
    pub fn pad_right(int width, string fill) -> Buf {
        let need = width - self.text.len();
        let i = 0;
        while i < need {
            self.text = self.text + fill;
            i = i + 1;
        }
        return self;
    }
}
