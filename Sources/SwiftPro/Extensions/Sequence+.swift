//
//  File.swift
//
//
//  Created by Dmitry Mikhaylov on 28.02.2024.
//

import Foundation

public extension Optional where Wrapped: Collection {
    var isEmpty: Bool {
        self?.endIndex == self?.startIndex
    }

    var nonEmpty: Bool {
        self?.endIndex != self?.startIndex
    }
}

public extension Array {
    @inlinable
    func appending(contentsOf other: [Element]) -> [Element] {
        var result = self
        result.append(contentsOf: other)
        return result
    }
    @inlinable var lastIndex: Int { endIndex - 1 }
}

public extension Collection {
    func indexed() -> Array<(offset: Int, element: Element)> {
         Array(enumerated())
     }
    func asyncMap<T>(
        _ transform: (Element) async throws -> T
    ) async rethrows -> [T] {
        var values = [T]()

        for element in self {
            try await values.append(transform(element))
        }

        return values
    }

    func asyncCompactMap<T>(
        _ transform: (Element) async throws -> T?
    ) async rethrows -> [T] {
        var values = [T]()

        for element in self {
            if let el = try await transform(element) {
                values.append(el)
            }
        }

        return values
    }

   
}

public extension Array where Element: Identifiable & Equatable, Index == Int {
    subscript(safe index: Int) -> Element? {
        get {
            return  indices.contains(index) ? self[index] : nil
        }

        set {
            guard indices.contains(index) else { debugPrint("There is NO value for index: \(index)")
                if self.underestimatedCount > index { }
                return
            }
            if let newValue {
                self[safe: index] = newValue
            } else { self.remove(at: index) }
        }
    }
}

public extension RangeReplaceableCollection where Element: Identifiable & Equatable, Index == Int {
    subscript(safe index: Int) -> Element? {
        get {
            return self.indices.contains(index) ? self[index] : nil
        }

        set {
            guard indices.contains(index) else { debugPrint("There is NO value for index: \(index)")
                if self.underestimatedCount > index { }
                return
            }
            if let newValue {
                self[safe: index] = newValue
            } else { self.remove(at: index) }
        }
    }
}

public extension RangeReplaceableCollection where Index: Hashable {
    /// Check if this string has any content.
    var hasContent: Bool {
        !isEmpty
    }

    mutating func removeAll<C>(at collection: C) -> Self where
        C: Collection,
        C.Element == Index {
        let indices = Set(collection)
        // Trap if number of elements in the set is different from the collection.
        // Trap if an index is out of range.
        precondition(
            indices.count == collection.count &&
                indices.allSatisfy(self.indices.contains)
        )
        return indices
            .lazy
            .sorted()
            .enumerated()
            .reduce(into: .init()) { result, value in
                let (offset, index) = value
                if offset == 0 {
                    result.reserveCapacity(indices.count)
                }
                let shiftedIndex = self.index(index, offsetBy: -offset)
                let element = remove(at: shiftedIndex)
                result.append(element)
            }
    }
}

public extension Sequence where Iterator.Element: Hashable & Comparable {
    /// Group the sequence into a dictionary.
    ///
    /// The operation can use any property from the items as
    /// the dictionary key.
    func grouped<T>(by grouper: (Element) -> T) -> [T: [Element]] {
        Dictionary(grouping: self, by: grouper)
    }

    func unique() -> [Iterator.Element] {
        let reduced = reduce(into: Set<Iterator.Element>()) { partialResult, element in
            partialResult.update(with: element)
        }
        return Array(reduced)
    }

    func unique(by areInIncreasingOrder: (Iterator.Element, Iterator.Element) -> Bool) -> [Iterator.Element] {
        var uniqueElements: Set<Iterator.Element> = []
        forEach { element in
            if !uniqueElements.contains(where: { areInIncreasingOrder($0, element) }) {
                uniqueElements.insert(element)
            }
        }
        return Array(uniqueElements)
    }
}

public extension Dictionary where Value == Optional<Any> {
    func removingNilValues() -> [Key: Any] {
        self.compactMapValues {
            guard let value = $0 else { return nil }
            return value
        }
    }

    func removingEmptyValues() -> [Key: Any] {
        self.removingNilValues().compactMapValues {
            if let value = $0 as? [Any] {
                guard !value.isEmpty else { return "Empty" }
                if let value = $0 as? [String] { return value.joined(separator: ", ") }
                return value
            } else if let value = $0 as? JSON {
                return value.dictionary.removingEmptyValues()
            }
            return $0
        }
    }
}

public extension Dictionary where Value == Value {
    var keyValuePairs: [(key: String, value: String)] {
        self.jsonElements.compactMap({ ("\($0.key)", "\(String(describing: $0.value))") })
    }

    func removingEmptyValues() -> [Key: Any] {
        self.compactMapValues {
            if let value = $0 as? [Any] {
                guard !value.isEmpty else { return "Empty" }
                if let value = $0 as? [String] { return value.joined(separator: ", ") }
                return value
            } else if let value = $0 as? [String: Any] {
                return value.jsonElements.removingEmptyValues().keyValuePairs
            }
            return $0
        }
    }
}

public extension Dictionary where Value == Optional<Any> {}

public extension ComparisonResult {
    /// This is a shorthand for `.ordered Ascending`.
    static var ascending: ComparisonResult {
        .orderedAscending
    }

    /// This is a shorthand for `.orderedDescending`.
    static var descending: ComparisonResult {
        .orderedDescending
    }
}
