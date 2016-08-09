//
//  CQKeychain.swift
//  Colloquy (Old)
//
//  Created by C.W. Betts on 1/28/16.
//
//

import Foundation
import Security

private func createBaseDictionary(server: String, account: String?) -> [String: NSObject] {
	var query = [String: NSObject]()
	
	query[kSecClass as String] = kSecClassInternetPassword;
	query[kSecAttrServer as String] = server
	if let account = account {
		query[kSecAttrAccount as String] = account
	}
	
	return query;
}

final class CQKeychain : NSObject {
	private override init() {
		super.init()
	}
	@objc(standardKeychain)
	static let standardKeychain = CQKeychain()
	
	@objc(setPassword:forServer:area:)
	func setPassword(password: String, forServer server: String, area: String?) {
		setPassword(password, forServer: server, area: area, displayValue: nil)
	}
	
	@objc(setPassword:forServer:area:displayValue:)
	func setPassword(password: String, forServer server: String, area: String?, displayValue: String?) {
		guard password.characters.count != 0 else {
			removePasswordForServer(server, area: area)
			return;
		}
		
		let passwordData = password.dataUsingEncoding(NSUTF8StringEncoding)!
		
		setData(passwordData, forServer: server, area: area)
	}
	
	@objc(passwordForServer:area:)
	func passwordForServer(server: String, area: String?) -> String? {
		if let data = dataForServer(server, area: area) {
			return String(data: data, encoding: NSUTF8StringEncoding)
		}
		return nil
	}
	
	@objc(removePasswordForServer:area:)
	func removePasswordForServer(server: String, area: String?) {
		removeDataForServer(server, area: area)
	}
	
	//MARK: -
	
	@objc(setData:forServer:area:)
	func setData(passwordData: NSData, forServer server: String, area: String?) {
		setData(passwordData, forServer: server, area: area, displayValue: nil)
	}
	
	@objc(setData:forServer:area:displayValue:)
	func setData(passwordData: NSData, forServer server: String, area: String?, displayValue: String?) {
		guard passwordData.length != 0 else {
			removeDataForServer(server, area: area)
			return
		}
		
		var passwordEntry = createBaseDictionary(server, account: area);
		
		passwordEntry[kSecValueData as String] = passwordData;
		if let displayValue = displayValue {
			passwordEntry[kSecAttrLabel as String] = displayValue
		}
		
		let status = SecItemAdd(passwordEntry, nil);
		if status == errSecDuplicateItem {
			passwordEntry.removeValueForKey(kSecValueData as String)
			
			let attributesToUpdate = [kSecValueData as String: passwordData]
			
			SecItemUpdate(passwordEntry, attributesToUpdate);
		}
	}
	
	@objc(dataForServer:area:)
	func dataForServer(server: String, area: String?) -> NSData? {
		var passwordQuery = createBaseDictionary(server, account: area);
		
		passwordQuery[kSecReturnData as String] = true;
		passwordQuery[kSecMatchLimit as String] = kSecMatchLimitOne;
		
		var resultDataRef: AnyObject? = nil
		let status = SecItemCopyMatching(passwordQuery, &resultDataRef)
		if status == noErr && resultDataRef != nil {
			return resultDataRef as? NSData
		}
		
		return nil
	}
	
	@objc(removeDataForServer:area:)
	func removeDataForServer(server: String, area: String?) {
		let passwordQuery = createBaseDictionary(server, account: area)
		SecItemDelete(passwordQuery)
	}
}

