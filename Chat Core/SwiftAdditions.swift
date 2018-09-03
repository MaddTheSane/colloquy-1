//
//  SwiftAdditions.swift
//  Chat Core
//
//  Created by C.W. Betts on 8/9/16.
//
//

import Foundation

extension MVChatRoom {
	public var encoding: String.Encoding {
		get {
			return String.Encoding(rawValue: __encoding)
		}
		set {
			__encoding = newValue.rawValue
		}
	}
}

extension MVChatConnection {
	public var encoding: String.Encoding {
		get {
			return String.Encoding(rawValue: __encoding)
		}
		set {
			__encoding = newValue.rawValue
		}
	}
}

extension MVDirectChatConnection {
	public var encoding: String.Encoding {
		get {
			return String.Encoding(rawValue: __encoding)
		}
		set {
			__encoding = newValue.rawValue
		}
	}
}

extension MVMessaging {
	public func sendMessage(_ message: NSAttributedString, encoding: String.Encoding, asAction action: Bool) {
		sendMessage(message, withEncoding: encoding.rawValue, asAction: action)
	}
	
	public func sendMessage(_ message: NSAttributedString, encoding: String.Encoding, attributes: [String: Any]) {
		sendMessage(message, withEncoding: encoding.rawValue, withAttributes: attributes)
	}
}
