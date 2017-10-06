//
//  NSStringAdditions_Swift.swift
//  Chat Core
//
//  Created by C.W. Betts on 1/24/16.
//
//

import Foundation

extension NSString {
	@nonobjc public func range(ofRegex regex: String, options: NSRegularExpression.Options, in range: NSRange, capture: Int) throws -> NSRange {
		var errPtr: NSError? = nil
		let regRange = self.range(ofRegex: regex, options: options, in: range, capture: capture, error: &errPtr)
		if regRange.location == NSNotFound {
			//TODO better fallback
			throw errPtr ?? NSError(domain: NSCocoaErrorDomain, code: -1, userInfo: nil)
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
	public func range(ofRegex regex: String, options: NSRegularExpression.Options = [.useUnicodeWordBoundaries], in range1: Range<String.Index>? = nil, capture: Int = 0) throws -> Range<String.Index> {
		let range = range1 ?? startIndex ..< endIndex
		let regRange = try (self as NSString).range(ofRegex: regex, options: options, in: NSRange(range, in: self), capture: capture)
		if regRange.location == NSNotFound {
			//TODO better fallback
			throw NSError(domain: NSCocoaErrorDomain, code: -1, userInfo: nil)
		}
		
		guard let convRange = Range(regRange, in: self) else {
			throw NSError(domain: NSCocoaErrorDomain, code: NSFormattingError, userInfo: nil)
		}
		return convRange
	}
}
