//
//  File.swift
//
//
//  Created by Dmitry Mikhaylov on 27.02.2024.
//

import Foundation
import RegexBuilder
import UIKit

public extension String {
    subscript(value: Int) -> Character {
        self[index(at: value)]
    }
}

public extension String {
    var date: Date? {
        ISO8601DateFormatter.full.date(from: self)
    }

    var lastPathComponent: String {
        guard let url = URL(string: self) else { return self }
        return url.lastPathComponent
    }

    var pathExtension: String {
        guard let url = URL(string: self) else {
            debugPrint("Invalid URL: \(self)")
            return self.components(separatedBy: ".").last ?? ""
        }
        return url.pathExtension
    }

    subscript(value: NSRange) -> Substring {
        self[value.lowerBound ..< value.upperBound]
    }
}

public extension String {
    static var none: String { "" }

    subscript(value: CountableClosedRange<Int>) -> Substring {
        self[index(at: value.lowerBound) ... index(at: value.upperBound)]
    }

    subscript(value: CountableRange<Int>) -> Substring {
        self[index(at: value.lowerBound) ..< index(at: value.upperBound)]
    }

    subscript(value: PartialRangeUpTo<Int>) -> Substring {
        self[..<index(at: value.upperBound)]
    }

    subscript(value: PartialRangeThrough<Int>) -> Substring {
        self[...index(at: value.upperBound)]
    }

    subscript(value: PartialRangeFrom<Int>) -> Substring {
        self[index(at: value.lowerBound)...]
    }
}

private extension String {
    func index(at offset: Int) -> String.Index {
        index(startIndex, offsetBy: offset)
    }
}

public extension Optional<String> {
    func matches(regex: String?) -> Bool {
        guard let self = self, !self.isEmpty, self.endIndex.utf16Offset(in: self) > 2 else { return false }
        guard let regex, !regex.isEmpty else { return true }
        guard let regex = try? NSRegularExpression(pattern: regex, options: .caseInsensitive) else { return false }
        let range = NSRange(location: 0, length: self.utf16.underestimatedCount)
        return regex.firstMatch(in: self, options: [], range: range) != nil
    }
}

public extension String {
    func matches(regex: String) -> Bool {
        guard !isEmpty, endIndex.utf16Offset(in: self) > 2 else { return false }
        guard !regex.isEmpty else { return true }
        guard let regex = try? NSRegularExpression(pattern: regex, options: .caseInsensitive) else { return false }
        let range = NSRange(location: 0, length: utf16.underestimatedCount)
        return regex.firstMatch(in: self, options: [], range: range) != nil
    }

    func mask(with regex: String) -> String {
        let regularex = try? NSRegularExpression(pattern: regex, options: [.caseInsensitive, .ignoreMetacharacters])
        let output = regularex?.stringByReplacingMatches(
            in: self,
            options: [.reportCompletion],
            range: NSRange(location: 0, length: self.utf16.count),
            withTemplate:
            NSRegularExpression.escapedTemplate(for: regex).capitalized) ?? self
        debugPrint("escapedTemplate: \(NSRegularExpression.escapedTemplate(for: regex))")
        debugPrint("\(output)")
        return output
    }

    func format(with mask: String = "+X (XXX) XXX XX XX", symbol: Character = "X") -> String {
        let cleanNumber = components(separatedBy: CharacterSet.decimalDigits.inverted).joined()

        var result = ""
        var startIndex = cleanNumber.startIndex
        let endIndex = cleanNumber.endIndex

        for char in mask where startIndex < endIndex {
            if char == symbol {
                result.append(cleanNumber[startIndex])
                startIndex = cleanNumber.index(after: startIndex)
            } else {
                result.append(char)
            }
        }

        return result
    }

    func width(withConstrainedWidth width: CGFloat, font: UIFont, messageUseMarkdown: Bool) -> CGFloat {
        let constraintRect = CGSize(width: width, height: .greatestFiniteMagnitude)
        let boundingBox = toAttrString(font: font, messageUseMarkdown: messageUseMarkdown)
            .boundingRect(with: constraintRect,
                          options: .usesLineFragmentOrigin,
                          context: nil)
        return ceil(boundingBox.width)
    }

    func toAttrString(
        font: UIFont = .preferredFont(forTextStyle: .body),
        messageUseMarkdown: Bool = true
    ) -> NSAttributedString {
        var str = messageUseMarkdown ? (try? AttributedString(markdown: self, options: AttributedString.MarkdownParsingOptions(
            allowsExtendedAttributes: true,
            interpretedSyntax: .inlineOnlyPreservingWhitespace,
            failurePolicy: .returnPartiallyParsedIfPossible,
            languageCode: nil
        ))) ?? AttributedString(self) : AttributedString(self)
        str.setAttributes(AttributeContainer([.font: font]))
        return NSAttributedString(str)
    }

    func lastLineWidth(labelWidth: CGFloat, font: UIFont, messageUseMarkdown: Bool) -> CGFloat {
        // Create instances of NSLayoutManager, NSTextContainer and NSTextStorage
        let attrString = toAttrString(font: font, messageUseMarkdown: messageUseMarkdown)
        let availableSize = CGSize(width: labelWidth, height: .infinity)
        let layoutManager = NSLayoutManager()
        let textContainer = NSTextContainer(size: availableSize)
        let textStorage = NSTextStorage(attributedString: attrString)

        // Configure layoutManager and textStorage
        layoutManager.addTextContainer(textContainer)
        textStorage.addLayoutManager(layoutManager)

        // Configure textContainer
        textContainer.lineFragmentPadding = 0.0
        textContainer.lineBreakMode = .byWordWrapping
        textContainer.maximumNumberOfLines = 0

        let lastGlyphIndex = layoutManager.glyphIndexForCharacter(at: attrString.length - 1)
        let lastLineFragmentRect = layoutManager.lineFragmentUsedRect(
            forGlyphAt: lastGlyphIndex,
            effectiveRange: nil)

        return lastLineFragmentRect.maxX
    }

    func numberOfLines(labelWidth: CGFloat, font: UIFont, messageUseMarkdown: Bool) -> Int {
        let attrString = toAttrString(font: font, messageUseMarkdown: messageUseMarkdown)
        let availableSize = CGSize(width: labelWidth, height: .infinity)
        let textSize = attrString.boundingRect(with: availableSize, options: .usesLineFragmentOrigin, context: nil)
        let lineHeight = font.lineHeight
        return Int(ceil(textSize.height / lineHeight))
    }
}
