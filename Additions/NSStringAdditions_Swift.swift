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
	private func range(from nsRange : NSRange) -> Range<String.Index>? {
		if let from16 = utf16.index(utf16.startIndex, offsetBy: nsRange.location, limitedBy: utf16.endIndex),
			let to16 = utf16.index(from16, offsetBy: nsRange.length, limitedBy: utf16.endIndex),
			let from = String.Index(from16, within: self),
			let to = String.Index(to16, within: self) {
			return from ..< to
		}
		return nil
	}
	
	private func NSRange(from range : Range<String.Index>) -> NSRange {
		let utf16view = self.utf16
		let from = String.UTF16View.Index(range.lowerBound, within: utf16view)
		let to = String.UTF16View.Index(range.upperBound, within: utf16view)
		let fromDistance = utf16view.distance(from: utf16view.startIndex, to: from)
		let toDistance = utf16view.distance(from: from, to: to)
		return NSMakeRange(Int(fromDistance), Int(toDistance))
	}
	
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
		let regRange = try (self as NSString).range(ofRegex: regex, options: options, in: self.NSRange(from: range), capture: capture)
		if regRange.location == NSNotFound {
			//TODO better fallback
			throw NSError(domain: NSCocoaErrorDomain, code: -1, userInfo: nil)
		}
		
		guard let convRange = self.range(from: regRange) else {
			throw NSError(domain: NSCocoaErrorDomain, code: NSFormattingError, userInfo: nil)
		}
		return convRange
	}
}
