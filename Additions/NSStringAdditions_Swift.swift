//
//  NSStringAdditions_Swift.swift
//  Chat Core
//
//  Created by C.W. Betts on 1/24/16.
//
//

import Foundation

extension NSString {
	/// - parameter regex: The regular expression to search for.
	/// - parameter options: The regular expression options.<br>
	/// Default is `[.useUnicodeWordBoundaries]`.
	/// - parameter range: The range to search for the regex.
	/// - parameter capture: Which capture to use.<br>
	/// Default is `0`.
	@nonobjc public func range(ofRegex regex: String, options: NSRegularExpression.Options = [.useUnicodeWordBoundaries], in range: NSRange, capture: Int = 0) throws -> NSRange {
		var errPtr: NSError? = nil
		let regRange = self.__range(ofRegex: regex, options: options, in: range, capture: capture, error: &errPtr)
		if regRange.location == NSNotFound {
			throw errPtr ?? CocoaError(.formatting)
		}
		return regRange
	}
}

extension StringProtocol where Self.Index == String.Index {
	/// - parameter regex: The regular expression to search for.
	/// - parameter options: The regular expression options.<br>
	/// Default is `[.useUnicodeWordBoundaries]`.
	/// - parameter range1: The range to search for the regex. If `nil`,
	/// searches the whole string.<br>
	/// Default is `nil`
	/// - parameter replacement: What to replace the matched regex with.
	public func replacingOccurences<T, X>(ofRegex regex: T, with replacement: X, options: NSRegularExpression.Options = [.useUnicodeWordBoundaries], in range1: Range<Self.Index>? = nil) throws -> String where T : StringProtocol, X : StringProtocol {
		let range = range1 ?? startIndex ..< endIndex
		var toRet = String(self)
		//TODO: convert Self range to created string ranges. Is this needed?
		try toRet.replaceOccurrences(ofRegex: regex, with: replacement, options: options, in: range)
		return toRet
	}
}

extension String {
	/// - parameter regex: The regular expression to search for.
	/// - parameter options: The regular expression options.<br>
	/// Default is `[.useUnicodeWordBoundaries]`.
	/// - parameter range1: The range to search for the regex. If `nil`, 
	/// searches the whole string.<br>
	/// Default is `nil`
	/// - parameter capture: Which capture to use.<br>
	/// Default is `0`.
	public func range<T>(ofRegex regex: T, options: NSRegularExpression.Options = [.useUnicodeWordBoundaries], in range1: Range<String.Index>? = nil, capture: Int = 0) throws -> Range<String.Index> where T : StringProtocol {
		let range = range1 ?? startIndex ..< endIndex
		let regularExpression = try NSRegularExpression.cachedRegularExpression(withPattern: String(regex), options: options)
		guard let result = regularExpression.firstMatch(in: self, options: [.reportCompletion], range: NSRange(range, in: self)),
			let foundRange = Range(result.range(at: capture), in: self) else {
			throw CocoaError(.formatting)
		}
		
		return foundRange
	}
	
	/// - parameter regex: The regular expression to search for.
	/// - parameter options: The regular expression options.<br>
	/// Default is `[.useUnicodeWordBoundaries]`.
	/// - parameter range1: The range to search for the regex. If `nil`,
	/// searches the whole string.<br>
	/// Default is `nil`
	/// - parameter capture: Which capture to use.<br>
	/// Default is `0`.
	public func match<T>(regex: T, options: NSRegularExpression.Options = [.useUnicodeWordBoundaries], in range1: Range<String.Index>? = nil, capture: Int = 0) throws -> Substring where T : StringProtocol {
		let newRange = try range(ofRegex: regex, options: options, in: range1, capture: capture)
		let subStr = self[newRange]
		return subStr
	}
	
	/// - parameter regex: The regular expression to search for.
	/// - parameter options: The regular expression options.<br>
	/// Default is `[.useUnicodeWordBoundaries]`.
	/// - parameter range1: The range to search for the regex. If `nil`,
	/// searches the whole string.<br>
	/// Default is `nil`
	public func isMatched<T>(byRegex regex: T, options: NSRegularExpression.Options = [.useUnicodeWordBoundaries], in range1: Range<String.Index>? = nil) throws -> Bool where T : StringProtocol {
		let range = range1 ?? startIndex ..< endIndex
		let regularExpression = try NSRegularExpression.cachedRegularExpression(withPattern: String(regex), options: options)
		let foundRange = regularExpression.rangeOfFirstMatch(in: self, options: [.reportCompletion], range: NSRange(range, in: self))
		return foundRange.location != NSNotFound
	}

	
	public func captureComponents<T>(matchedByRegex regex: T, options: NSRegularExpression.Options = [.useUnicodeWordBoundaries], in range1: Range<String.Index>? = nil) throws -> [Substring] where T : StringProtocol {
		let range = range1 ?? startIndex ..< endIndex
		let regularExpression = try NSRegularExpression.cachedRegularExpression(withPattern: String(regex), options: options)
		guard let result = regularExpression.firstMatch(in: self, options: [.reportCompletion], range: NSRange(range, in: self)) else {
			return []
		}
		var results = [Substring]()
		results.reserveCapacity(result.numberOfRanges)
		
		for i in 1 ..< result.numberOfRanges {
			let range = result.range(at: i)
			guard let trueRange = Range(range, in: self) else {
				throw CocoaError(.formatting)
			}
			results.append(self[trueRange])
		}
		
		return results
	}
	
	/// - parameter regex: The regular expression to search for.
	/// - parameter options: The regular expression options.<br>
	/// Default is `[.useUnicodeWordBoundaries]`.
	/// - parameter range1: The range to search for the regex. If `nil`,
	/// searches the whole string.<br>
	/// Default is `nil`
	/// - parameter replacement: What to replace the matched regex with.
	public func replacingOccurences<T, X>(ofRegex regex: T, with replacement: X, options: NSRegularExpression.Options = [.useUnicodeWordBoundaries], in range1: Range<String.Index>? = nil) throws -> String where T : StringProtocol, X : StringProtocol {
		let range = range1 ?? startIndex ..< endIndex
		var toRet = self
		try toRet.replaceOccurrences(ofRegex: regex, with: replacement, options: options, in: range)
		return toRet
	}
	
	/// - parameter regex: The regular expression to search for.
	/// - parameter options: The regular expression options.<br>
	/// Default is `[.useUnicodeWordBoundaries]`.
	/// - parameter range1: The range to search for the regex. If `nil`,
	/// searches the whole string.<br>
	/// Default is `nil`
	/// - parameter replacement: What to replace the matched regex with.
	@discardableResult
	public mutating func replaceOccurrences<T, X>(ofRegex regex: T, with replacement: X, options: NSRegularExpression.Options = [.useUnicodeWordBoundaries], in range1: Range<String.Index>? = nil) throws -> Bool where T : StringProtocol, X : StringProtocol {
		let range = range1 ?? startIndex ..< endIndex
		
		let regularExpression = try NSRegularExpression.cachedRegularExpression(withPattern: String(regex), options: options)
		
		let toReplace = regularExpression.stringByReplacingMatches(in: self, options: [], range: NSRange(range, in: self), withTemplate: String(replacement))
		if toReplace == self {
			return false
		}
		self = toReplace
		return true
	}
	
	public mutating func decodeXMLSpecialCharacterEntities() {
		guard let _ = range(of: "&") else {
			return
		}
		
		while let rangeOfStr = range(of: "&lt;", options: [.literal]) {
			replaceSubrange(rangeOfStr, with: "<")
		}
		while let rangeOfStr = range(of: "&gt;", options: [.literal]) {
			replaceSubrange(rangeOfStr, with: ">")
		}
		while let rangeOfStr = range(of: "&quot;", options: [.literal]) {
			replaceSubrange(rangeOfStr, with: "\"")
		}
		while let rangeOfStr = range(of: "&amp;", options: [.literal]) {
			replaceSubrange(rangeOfStr, with: "&")
		}
	}
	
	public mutating func replaceCharacters<T>(in set: CharacterSet, with string: T) where T : StringProtocol {
		var range = startIndex ..< endIndex
		let stringLength = string.count
		
		while let replaceRange = rangeOfCharacter(from: set, options: [.literal], range: range) {
			replaceSubrange(replaceRange, with: string)
			guard let startLocation = index(replaceRange.lowerBound, offsetBy: stringLength, limitedBy: endIndex) else {
				break
			}
			range = startLocation ..< endIndex
		}
	}
	
	public mutating func stripIllegalXMLCharacters() {
		let illegalSet = NSCharacterSet.illegalXML
		while let range = rangeOfCharacter(from: illegalSet) {
			removeSubrange(range)
		}
	}
	
	public mutating func stripXMLTags() {
		var searchRange = startIndex ..< endIndex
		while true {
			guard let tagStartRange = range(of: "<", options: [.literal], range: searchRange),
				let tagEndRange = range(of: ">", options: [.literal], range: tagStartRange.lowerBound ..< endIndex) else {
					break
			}
			removeSubrange(tagStartRange.lowerBound ..< tagEndRange.upperBound)
			// TODO: is this safe?
			searchRange = tagStartRange.lowerBound ..< endIndex
		}
	}
}
