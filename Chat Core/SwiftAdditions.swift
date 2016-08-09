//
//  SwiftAdditions.swift
//  Chat Core
//
//  Created by C.W. Betts on 8/9/16.
//
//

import Foundation

extension MVChatConnectionError: Error {
	public var _domain: String {
		return MVChatConnectionErrorDomain
	}
	
	public var _code: Int {
		return rawValue
	}
}

extension MVFileTransferError: Error {
	public var _domain: String {
		return MVFileTransferErrorDomain
	}
	
	public var _code: Int {
		return rawValue
	}
}
