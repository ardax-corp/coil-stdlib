use macro::{Code, Expr, lit};

/// Expands to `!expression`.
///
/// # Examples
///
/// ```
/// use tests::{assert, not};
/// assert!(not!(1 > 2));
/// ```
macro not(Expr expression) -> Code {
    return quote expr {
        !${expression}
    };
}

/// Expands to `lhs == rhs`.
///
/// # Examples
///
/// ```
/// use tests::{assert, eq};
/// assert!(eq!(2 + 2, 4));
/// ```
macro eq(Expr lhs, Expr rhs) -> Code {
    return quote expr {
        ${lhs} == ${rhs}
    };
}

/// Returns whether `expr` matches the pattern `ty`, as a `bool`.
///
/// Expands to a `match` with one arm for the pattern and a `default` arm.
///
/// # Examples
///
/// ```
/// use tests::{assert, matches};
/// let r: Result<int, string> = Result::Ok(3);
/// assert!(matches!(Result::Ok(_), r));
/// assert!(!matches!(Option::Some(_), Option::None));
/// ```
macro matches(Expr ty, Expr expr) -> Code {
    return quote expr {
        match ${expr} {
            ${ty} => true,
            default => false,
        }
    };
}

/// Expands to `typeof ty`: the type of an expression, as a value that can be compared.
macro type(Expr ty) -> Code {
    return quote expr {
        typeof ${ty}
    };
}

/// Expands to `lhs && rhs`.
macro and(Expr lhs, Expr rhs) -> Code {
    return quote expr {
        ${lhs} && ${rhs}
    };
}

/// Fails the enclosing function with an error when `condition` is false.
///
/// `assert!(cond)` raises the string `Assertion: 'cond' failed`;
/// `assert!(cond, message)` raises `message` instead. Because it raises rather
/// than panics, the function it is used in must return a `Result` (or be a
/// `test` block or `main`, where a raised error fails the test or the program).
///
/// # Examples
///
/// ```
/// use tests::{assert};
/// fn check(int n) -> Result<int, string> {
///     assert!(n >= 0, "negative input");
///     return n * 2;
/// }
///
/// fn main() {
///     assert!(check(4)? == 8);
///     let failed = match check(-1) {
///         Result::Err(msg) => msg == "negative input",
///         Result::Ok(_) => false,
///     };
///     assert!(failed);
/// }
/// ```
macro assert(Expr condition) -> Code {
    return quote stmts {
        if true != ${condition} {
            raise ${lit("Assertion: '" + condition.str() + "' failed")};
        }
    };
}

macro assert(Expr condition, Expr message) -> Code {
    return quote stmts {
        if true != ${condition} {
            raise ${message};
        }
    };
}
