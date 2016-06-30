//
//  NSStringAdditions_Swift.swift
//  Chat Core
//
//  Created by C.W. Betts on 1/24/16.
//
//

import Foundation

extension NSString {
	@nonobjc public func rangeOfRegex(_ regex: String, options: RegularExpression.Options, inRange range: NSRange, capture: Int) throws -> NSRange {
		var errPtr: NSError? = nil
		let regRange = self.range(ofRegex: regex, options: options, in: range, capture: capture, error: &errPtr)
		if regRange.location == NSNotFound {
			//TODO better fallback
			throw errPtr ?? NSError(domain: NSCocoaErrorDomain, code: -1, userInfo: nil)
		}
		return regRange
	}
}
