use tests::{assert, matches};

enum Shape {
    Circle(int),
    Square(int),
    Dot,
}

test("matches! on Option") {
    let some: Option<int> = Option::Some(1);
    let none: Option<int> = Option::None;
    assert!(matches!(Option::Some(_), some));
    assert!(!matches!(Option::Some(_), none));
    assert!(matches!(Option::None, none));
}

test("matches! on a user enum") {
    let s = Shape::Square(3);
    assert!(matches!(Shape::Square(_), s));
    assert!(!matches!(Shape::Circle(_), s));
    assert!(!matches!(Shape::Dot, s));
}

test("matches! on a Result") {
    let r: Result<int, string> = Result::Err("no");
    assert!(matches!(Result::Err(_), r));
    assert!(!matches!(Result::Ok(_), r));
}
