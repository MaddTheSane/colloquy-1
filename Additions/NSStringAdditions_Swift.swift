//
//  NSStringAdditions_Swift.swift
//  Chat Core
//
//  Created by C.W. Betts on 1/24/16.
//
//

import Foundation

extension NSString {
	@nonobjc public func range(ofRegex regex: String, options: NSRegularExpression.Options = [.useUnicodeWordBoundaries], in range: NSRange, capture: Int = 0) throws -> NSRange {
		var errPtr: NSError? = nil
		let regRange = self.__range(ofRegex: regex, options: options, in: range, capture: capture, error: &errPtr)
		if regRange.location == NSNotFound {
			throw errPtr ?? CocoaError(.formatting)
		}
		return regRange
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
		let regRange = try (self as NSString).range(ofRegex: String(regex), options: options, in: NSRange(range, in: self), capture: capture)
		
		guard let convRange = Range(regRange, in: self) else {
			throw CocoaError(.formatting)
		}
		return convRange
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
	/// - parameter replacement: What to replace the matched regex with.
	public mutating func replaceOccurrences<T>(ofRegex regex: T, with replacement: String, options: NSRegularExpression.Options = [.useUnicodeWordBoundaries], in range1: Range<String.Index>? = nil) throws where T : StringProtocol {
		let newRange = try range(ofRegex: regex, options: options, in: range1)
		self.replaceSubrange(newRange, with: replacement)
	}
}
