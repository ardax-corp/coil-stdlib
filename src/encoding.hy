// Standard Base64 encode/decode (padding included).
use string::{to_bytes, from_bytes};

fn b64_index(byte c) -> int {
    if c >= "A" && c <= "Z" {
        return (c as int) - ("A" as byte as int);
    }
    if c >= "a" && c <= "z" {
        return (c as int) - ("a" as byte as int) + 26;
    }
    if c >= "0" && c <= "9" {
        return (c as int) - ("0" as byte as int) + 52;
    }
    if c == "+" {
        return 62;
    }
    if c == "/" {
        return 63;
    }
    return -1;
}

fn b64_char(int n) -> byte {
    if n < 26 {
        return (("A" as byte as int) + n) as byte;
    }
    if n < 52 {
        let k = n - 26;
        return (("a" as byte as int) + k) as byte;
    }
    if n < 62 {
        let k = n - 52;
        return (("0" as byte as int) + k) as byte;
    }
    if n == 62 {
        return "+" as byte;
    }
    return "/" as byte;
}

/// Encode bytes as standard Base64.
fn encode(Vec<byte> data) -> string {
    let out: Vec<byte> = Vec::new();
    let i = 0;
    while i < len(data) {
        let b0 = data[i] as int;
        let b1 = 0;
        let rem = len(data) - i;
        if rem > 1 {
            b1 = data[i + 1] as int;
        }
        let b2 = 0;
        if rem > 2 {
            b2 = data[i + 2] as int;
        }
        out.push(b64_char(b0 / 4));
        if rem == 1 {
            out.push(b64_char((b0 % 4) * 16));
            out.push("=" as byte);
            out.push("=" as byte);
        } else {
            if rem == 2 {
                out.push(b64_char(((b0 % 4) * 16) + (b1 / 16)));
                out.push(b64_char((b1 % 16) * 4));
                out.push("=" as byte);
            } else {
                out.push(b64_char(((b0 % 4) * 16) + (b1 / 16)));
                out.push(b64_char(((b1 % 16) * 4) + (b2 / 64)));
                out.push(b64_char(b2 % 64));
            }
        }
        i = i + 3;
    }
    return match from_bytes(out) {
        Result::Ok(s) => s,
        Result::Err(_) => "",
    };
}

/// Decode standard Base64 into bytes.
fn decode(string s) -> Result<Vec<byte>, string> {
    let b = to_bytes(s);
    let out: Vec<byte> = Vec::new();
    let q0 = -1;
    let q1 = -1;
    let q2 = -1;
    let q3 = -1;
    let qi = 0;
    let i = 0;
    while i < len(b) {
        let c = b[i];
        i = i + 1;
        if c == "=" {
            break;
        }
        if c == " " || c == "\n" || c == "\r" || c == "\t" {
            continue;
        }
        let v = b64_index(c);
        if v < 0 {
            raise "invalid base64";
        }
        if qi == 0 {
            q0 = v;
        }
        if qi == 1 {
            q1 = v;
        }
        if qi == 2 {
            q2 = v;
        }
        if qi == 3 {
            q3 = v;
        }
        qi = qi + 1;
        if qi == 4 {
            let n = q0 * 262144 + q1 * 4096 + q2 * 64 + q3;
            let b0 = n / 65536;
            out.push(b0 as byte);
            let b1 = (n / 256) % 256;
            out.push(b1 as byte);
            let b2 = n % 256;
            out.push(b2 as byte);
            qi = 0;
        }
    }
    // Padding (`=`) or trailing partial quartet still yields the remaining bytes.
    if qi == 2 {
        let n = q0 * 262144 + q1 * 4096;
        let b0 = n / 65536;
        out.push(b0 as byte);
    }
    if qi == 3 {
        let n = q0 * 262144 + q1 * 4096 + q2 * 64;
        let b0 = n / 65536;
        out.push(b0 as byte);
        let b1 = (n / 256) % 256;
        out.push(b1 as byte);
    }
    if qi == 1 {
        raise "invalid base64";
    }
    return out;
}
