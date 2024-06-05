//
//  File.swift
//
//
//  Created by Dmitry Mikhaylov on 27.02.2024.
//

import Foundation
import RegexBuilder
#if canImport(UIKit)
	import UIKit
#else
	import AppKit
#endif
public extension String {
	subscript(value: Int) -> Character {
		self[index(at: value)]
	}
}

// MARK: - Set + StorageCodable

extension Set: RawRepresentable where Set.Element == String {
	
}

extension Set<String>: StorageCodable {
	public var rawValue: String {
		joined(separator: " && ")
	}

	public init?(rawValue: String) {
		self.init(rawValue.components(separatedBy: " && "))
	}

	public func encode(to encoder: Encoder) throws {
		var container = encoder.singleValueContainer()
		try container.encode(rawValue)
	}

	public init(from decoder: Decoder) throws {
		let container = try decoder.singleValueContainer()
		let rawValue = try container.decode(String.self)
		self = Set(rawValue.components(separatedBy: " && "))
	}
}

public extension String {
	@available(*, deprecated, message: "Use the new options-based version instead.")
	func replacing(
		_ string: String,
		with: String,
		caseSensitive: Bool
	) -> String {
		caseSensitive
			? replacingOccurrences(of: string, with: with)
			: replacingOccurrences(of: string, with: with, options: .caseInsensitive)
	}

	/// Replace a certain string with another one.
	func replacing(
		_ string: String,
		with other: String,
		_ options: NSString.CompareOptions? = nil
	) -> String {
		if let options {
			replacingOccurrences(of: string, with: other, options: options)
		} else {
			replacingOccurrences(of: string, with: other)
		}
	}

	/// Replace a certain string with another one.
	mutating func replace(
		_ string: String,
		with other: String,
		_ options: NSString.CompareOptions? = nil
	) {
		self = replacing(string, with: other, options)
	}

	/// This is a shorthand for `trimmingCharacters(in:)`.
	func trimmed(
		for set: CharacterSet = .whitespacesAndNewlines
	) -> String {
		trimmingCharacters(in: set)
	}

	/// Check if this string has any content.
	var hasContent: Bool {
		!isEmpty
	}

	var nilOrEmpty: String? {
		hasTrimmedContent ? self : nil
	}

	/// Check if this string has any content after trimming.
	var hasTrimmedContent: Bool {
		!trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
	}

	/// Check if this string contains another string.
	func contains(_ string: String, caseSensitive: Bool = false) -> Bool {
		caseSensitive
			? localizedStandardContains(string)
			: range(of: string, options: .caseInsensitive) != nil
	}
}

public extension String {
	var date: Date? {
		ISO8601DateFormatter.full.date(from: self)
	}

	var lastPathComponent: String {
		guard let url = URL(string: self) else {
			return self
		}
		return url.lastPathComponent
	}

	var pathExtension: String {
		guard let url = URL(string: self) else {
			debugPrint("Invalid URL: \(self)")
			return components(separatedBy: ".").last ?? ""
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

public extension String? {
	func matches(regex: String?) -> Bool {
		guard let self, !self.isEmpty, self.endIndex.utf16Offset(in: self) > 2 else {
			return false
		}
		guard let regex, !regex.isEmpty else {
			return true
		}
		guard let regex = try? NSRegularExpression(pattern: regex, options: .caseInsensitive) else {
			return false
		}
		let range = NSRange(location: 0, length: self.utf16.underestimatedCount)
		return regex.firstMatch(in: self, options: [], range: range) != nil
	}
}

public extension String {
	func matches(regex: String) -> Bool {
		guard !isEmpty, endIndex.utf16Offset(in: self) > 2 else {
			return false
		}
		guard !regex.isEmpty else {
			return true
		}
		guard let regex = try? NSRegularExpression(pattern: regex, options: .caseInsensitive) else {
			return false
		}
		let range = NSRange(location: 0, length: utf16.underestimatedCount)
		return regex.firstMatch(in: self, options: [], range: range) != nil
	}

	func mask(with regex: String) -> String {
		let regularex = try? NSRegularExpression(pattern: regex, options: [.caseInsensitive, .ignoreMetacharacters])
		let output = regularex?.stringByReplacingMatches(
			in: self,
			options: [.reportCompletion],
			range: NSRange(location: 0, length: utf16.count),
			withTemplate:
			NSRegularExpression.escapedTemplate(for: regex).capitalized
		) ?? self
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

	func width(
		withConstrainedWidth width: CGFloat,
		font: UIFont,
		messageUseMarkdown: Bool
	) -> CGFloat {
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

	func lastLineWidth(
		labelWidth: CGFloat,
		font: UIFont,
		messageUseMarkdown: Bool
	) -> CGFloat {
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
			effectiveRange: nil
		)

		return lastLineFragmentRect.maxX
	}

	func numberOfLines(
		labelWidth: CGFloat,
		font: UIFont,
		messageUseMarkdown: Bool
	) -> Int {
		let attrString = toAttrString(font: font, messageUseMarkdown: messageUseMarkdown)
		let availableSize = CGSize(width: labelWidth, height: .infinity)
		let textSize = attrString.boundingRect(with: availableSize, options: .usesLineFragmentOrigin, context: nil)
		let lineHeight = font.lineHeight
		return Int(ceil(textSize.height / lineHeight))
	}
}

public extension String {
	func levenshteinDistanceScore(
		to string: String,
		caseSensitive: Bool = false,
		trimWhiteSpacesAndNewLines: Bool = true
	) -> Double {
		var firstString = self
		var secondString = string

		if !caseSensitive {
			firstString = firstString.lowercased()
			secondString = secondString.lowercased()
		}
		if trimWhiteSpacesAndNewLines {
			firstString = firstString.trimmingCharacters(in: .whitespacesAndNewlines)
			secondString = secondString.trimmingCharacters(in: .whitespacesAndNewlines)
		}

		let empty = [Int](repeating: 0, count: secondString.count)
		var last = [Int](0 ... secondString.count)

		for (i, tLett) in firstString.enumerated() {
			var cur = [i + 1] + empty
			for (j, sLett) in secondString.enumerated() {
				cur[j + 1] = tLett == sLett ? last[j] : Swift.min(last[j], last[j + 1], cur[j]) + 1
			}
			last = cur
		}

		// maximum string length between the two
		let lowestScore = max(firstString.count, secondString.count)

		if let validDistance = last.last {
			return 1 - (Double(validDistance) / Double(lowestScore))
		}

		return 0.0
	}
}

public extension [String] {
	func mostSimilar(to string: String) -> String? {
		guard !isEmpty else {
			return nil
		}
		return lazy.sorted { $0.levenshteinDistanceScore(to: string) < $1.levenshteinDistanceScore(to: string) }.first
	}
}
