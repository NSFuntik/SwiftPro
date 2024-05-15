//
//  Collection+Extension.swift
//
//
//  Created by Ahmed Shendy on 24/11/2022.
//

import Foundation

public extension RangeReplaceableCollection {
    private func distance(from startIndex: Index) -> Int {
        distance(from: startIndex, to: self.endIndex)
    }

    private func distance(to endIndex: Index) -> Int {
        distance(from: self.startIndex, to: endIndex)
    }

    public subscript(safe index: Index) -> Iterator.Element? {
        get {
            if distance(to: index) >= 0 && distance(from: index) > 0 {
                return self[index]
            }
            return nil
        }
        set {
            if let newValue {
                self[safe: index] = newValue
            } else { self.remove(at: index) }
        }
    }

    public subscript(safe bounds: Range<Index>) -> SubSequence? {
        if distance(to: bounds.lowerBound) >= 0 && distance(from: bounds.upperBound) >= 0 {
            return self[bounds]
        }
        return nil
    }

    public subscript(safe bounds: ClosedRange<Index>) -> SubSequence? {
        if distance(to: bounds.lowerBound) >= 0 && distance(from: bounds.upperBound) > 0 {
            return self[bounds]
        }
        return nil
    }
}

public extension StaticString {
    var lastPathComponent: String {
        guard let url = URL(string: self.description) else { return self.description }
        return url.lastPathComponent
    }
}
