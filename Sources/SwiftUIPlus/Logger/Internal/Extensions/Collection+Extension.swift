//
//  Collection+Extension.swift
//  
//
//  Created by Ahmed Shendy on 24/11/2022.
//

import Foundation

extension Collection {
    subscript(safe index: Index) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}
extension StaticString {
    var lastPathComponent: String {
        guard let url = URL(string: self.description) else { return self.description }
        return url.lastPathComponent
    }
}
