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
    
    @inlinable var lastIndex: Int { endIndex - 1 }
}

public extension RandomAccessCollection where Element: Equatable {
    subscript(safe index: Index?) -> Element? {
        get {
            guard let index else { return nil }
            return indices.contains(index) ? self[index] : nil
        }
        
        set {
            if let newValue, let index, indices.contains(index) {
                self[safe: index] = newValue
            }
        }
    }
}

public extension Sequence where Iterator.Element: (Hashable & Comparable) {
    func unique() -> [Iterator.Element] {
        var seen: Set<Iterator.Element> = []
        return filter { seen.insert($0).inserted }
    }
    
    func unique(by areInIncreasingOrder: (Iterator.Element, Iterator.Element) -> Bool) -> [Iterator.Element] {
        var uniqueElements: Set<Iterator.Element> = []
        forEach { element in
            if !uniqueElements.contains(where: { areInIncreasingOrder($0, element) }) {
                uniqueElements.insert(element)
            }
        }
        return uniqueElements.sorted()
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

public  extension Dictionary where Value == Value {
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

public extension Dictionary where Value == Optional<Any> {
}
