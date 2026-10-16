use macro::{Code, Expr, lit};

macro not(Expr expression) -> Code {
    return quote expr {
        !${expression}
    };
}

macro eq(Expr lhs, Expr rhs) -> Code {
    return quote expr {
        ${lhs} == ${rhs}
    };
}

macro matches(Expr ty, Expr expr) -> Code {
    return quote expr {
        match ${expr} {
            ${ty} => true,
            _ => false,
        }
    };
}

macro type(Expr ty) -> Code {
    return quote expr {
        typeof ${ty}
    };
}

macro and(Expr lhs, Expr rhs) -> Code {
    return quote expr {
        ${lhs} && ${rhs}
    };
}

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
