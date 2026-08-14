use ascii::{
    is_space, is_digit, is_alpha, is_alnum, is_print, is_ctrl, to_lower, to_upper,
    digit_val, digit_char, is_hex, hex_val, hex_digit,
};

test("ascii classification") {
    assert(is_space(" "))?;
    assert(is_space("\t"))?;
    assert(is_space("\n"))?;
    assert(!is_space("A"))?;
    assert(is_digit("0"))?;
    assert(is_digit("9"))?;
    assert(!is_digit("/"))?;
    assert(is_alpha("A"))?;
    assert(is_alpha("z"))?;
    assert(!is_alpha("7"))?;
}

test("ascii decimal digits") {
    assert(digit_val("0") == 0)?;
    assert(digit_val("7") == 7)?;
    assert(digit_val("x") == -1)?;
    assert(digit_char(0) == "0")?;
    assert(digit_char(9) == "9")?;
}

test("ascii hex digits") {
    assert(is_hex("a"))?;
    assert(is_hex("F"))?;
    assert(!is_hex("g"))?;
    assert(hex_val("a") == 10)?;
    assert(hex_val("F") == 15)?;
    assert(hex_val("g") == -1)?;
    assert(hex_digit(10) == "a")?;
    assert(hex_digit(0) == "0")?;
}

test("ascii alnum print ctrl case") {
    assert(is_alnum("A"))?;
    assert(is_alnum("7"))?;
    assert(!is_alnum(" "))?;
    assert(is_print(" "))?;
    assert(is_print("~"))?;
    assert(!is_print("\n"))?;
    assert(is_ctrl("\n"))?;
    assert(is_ctrl("\x7f"))?;
    assert(!is_ctrl("A"))?;
    assert(to_lower("A") == "a")?;
    assert(to_lower("a") == "a")?;
    assert(to_upper("a") == "A")?;
    assert(to_upper("A") == "A")?;
}
