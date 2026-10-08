func sortBy<T, V: Comparable>(
    _ items: [T],
    keyPath: KeyPath<T, V>,
    ascending: Bool = true
) -> [T] {

    items.sorted {
        ascending
        ? $0[keyPath: keyPath] < $1[keyPath: keyPath]
        : $0[keyPath: keyPath] > $1[keyPath: keyPath]
    }
}
