use tests::assert;
use collections::map::HashMap;
use collections::tree::TreeMap;

test("for loop over hashmap iter") {
    let m: HashMap<string, int> = HashMap::new();
    m.insert("a", 1);
    m.insert("b", 2);
    m.insert("c", 3);
    let sum = 0;
    let count = 0;
    for e in m.iter() {
        sum = sum + e.value;
        count = count + 1;
        assert!(m.get(e.key) == Some(e.value));
    }
    assert!(sum == 6);
    assert!(count == 3);
}

test("for loop over treemap iter is ordered") {
    let t: TreeMap<int, string> = TreeMap::new();
    t.insert(3, "c");
    t.insert(1, "a");
    t.insert(2, "b");
    let keys = "";
    let last = 0;
    for e in t.iter() {
        assert!(e.key > last);
        last = e.key;
        keys = keys + e.value;
    }
    assert!(keys == "abc");
}
