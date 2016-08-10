//
//  NSStringAdditions_Swift.swift
//  Chat Core
//
//  Created by C.W. Betts on 1/24/16.
//
//

import Foundation

extension NSString {
	@nonobjc public func rangeOfRegex(regex: String, options: NSRegularExpressionOptions, inRange range: NSRange, capture: Int) throws -> NSRange {
		var errPtr: NSError? = nil
		let regRange = rangeOfRegex(regex, options: options, inRange: range, capture: capture, error: &errPtr)
		if regRange.location == NSNotFound {
			//TODO better fallback
			throw errPtr ?? NSError(domain: NSCocoaErrorDomain, code: -1, userInfo: nil)
		}
		return regRange
	}
}

extension String {
	private func rangeFromNSRange(nsRange : NSRange) -> Range<String.Index>? {
		let from16 = utf16.startIndex.advancedBy(nsRange.location, limit: utf16.endIndex)
		let to16 = from16.advancedBy(nsRange.length, limit: utf16.endIndex)
		if let from = String.Index(from16, within: self),
			let to = String.Index(to16, within: self) {
			return from ..< to
		}
		return nil
	}
	
	private func NSRangeFromRange(range : Range<String.Index>) -> NSRange {
		let utf16view = self.utf16
		let from = String.UTF16View.Index(range.startIndex, within: utf16view)
		let to = String.UTF16View.Index(range.endIndex, within: utf16view)
		return NSMakeRange(Int(utf16view.startIndex.distanceTo(from)), Int(from.distanceTo(to)))
	}
	
	/// - parameter range1: The range to search for the regex. If `nil`, 
	/// searches the whole string.<br>
	/// Default is `nil`
	public func rangeOfRegex(regex: String, options: NSRegularExpressionOptions = [], inRange range1: Range<String.Index>? = nil, capture: Int = 0) throws -> Range<String.Index> {
		let range = range1 ?? startIndex ..< endIndex
		var errPtr: NSError? = nil
		let regRange = (self as NSString).rangeOfRegex(regex, options: options, inRange: NSRangeFromRange(range), capture: capture, error: &errPtr)
		if regRange.location == NSNotFound {
			//TODO better fallback
			throw errPtr ?? NSError(domain: NSCocoaErrorDomain, code: -1, userInfo: nil)
		}
		
		guard let convRange = rangeFromNSRange(regRange) else {
			throw NSError(domain: NSCocoaErrorDomain, code: NSFormattingError, userInfo: nil)
		}
		return convRange
	}
}
