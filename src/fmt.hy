// Incremental string builder (userland). `string::format` remains a compiler intrinsic.
use conv::{int_to_dec, int_to_hex};

class Buf {
    text: string,
}

impl Buf {
    pub static fn new() -> Buf {
        return new Buf("");
    }

    pub fn push_str(string s) {
        self.text = self.text + s;
    }

    pub fn push_int(int n) {
        self.text = self.text + int_to_dec(n);
    }

    pub fn push_hex(int n) {
        self.text = self.text + int_to_hex(n);
    }

    pub fn to_string() -> string {
        return self.text;
    }

    pub fn pad_left(int width, string fill) -> Buf {
        let need = width - len(self.text);
        let pad = "";
        let i = 0;
        while i < need {
            pad = pad + fill;
            i = i + 1;
        }
        self.text = pad + self.text;
        return self;
    }

    pub fn pad_right(int width, string fill) -> Buf {
        let need = width - len(self.text);
        let i = 0;
        while i < need {
            self.text = self.text + fill;
            i = i + 1;
        }
        return self;
    }
}
