use tests::assert;
use collections::map::HashMap;
use collections::tree::TreeMap;

class Point {
    pub x: int,
}

test("hashmap get returns Option") {
    let m: HashMap<string, int> = HashMap::new();
    m.insert("a", 1);
    assert!(m.get("a") == Some(1));
    assert!(m.get("b") == None);
    assert!((m.get("b") ?? 7) == 7);
}

test("hashmap get of heap and niche values") {
    let s: HashMap<string, string> = HashMap::new();
    s.insert("a", "x");
    assert!(s.get("a") == Some("x"));
    assert!(s.get("b").is_none());

    let p: HashMap<string, Point> = HashMap::new();
    p.insert("a", new Point(5));
    assert!((p.get("a") ?? new Point(0)).x == 5);
    assert!(p.get("b").is_none());

    let o: HashMap<string, Option<string>> = HashMap::new();
    o.insert("set", Some("v"));
    o.insert("unset", None);
    assert!(o.get("set") == Some(Some("v")));
    assert!(o.get("unset") == Some(None));
    assert!(o.get("missing") == None);

    let r: HashMap<string, Result<string, string>> = HashMap::new();
    r.insert("ok", Ok("y"));
    r.insert("err", Err("e"));
    assert!(r.get("ok") == Some(Ok("y")));
    assert!(r.get("err") == Some(Err("e")));

    let i: HashMap<string, Option<int>> = HashMap::new();
    i.insert("n", None);
    i.insert("s", Some(3));
    assert!(i.get("n") == Some(None));
    assert!(i.get("s") == Some(Some(3)));
    assert!(i.get("x") == None);
}

test("treemap get returns Option") {
    let m: TreeMap<int, string> = TreeMap::new();
    m.insert(2, "b");
    m.insert(1, "a");
    assert!(m.get(1) == Some("a"));
    assert!(m.get(3) == None);

    let o: TreeMap<int, Option<string>> = TreeMap::new();
    o.insert(1, None);
    assert!(o.get(1) == Some(None));
    assert!(o.get(2) == None);
}
