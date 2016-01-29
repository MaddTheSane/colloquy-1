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
	static let standardKeychain = CQKeychain()
	
	func setPassword(password: String, forServer server: String, area: String?) {
		setPassword(password, forServer: server, area: area, displayValue: nil)
	}
	
	func setPassword(password: String, forServer server: String, area: String?, displayValue: String?) {
		guard password.characters.count != 0 else {
			removePasswordForServer(server, area: area)
			return;
		}
		
		let passwordData = password.dataUsingEncoding(NSUTF8StringEncoding)!
		
		setData(passwordData, forServer: server, area: area)
	}
	
	func passwordForServer(server: String, area: String?) -> String? {
		if let data = dataForServer(server, area: area) {
			return String(data: data, encoding: NSUTF8StringEncoding)
		}
		return nil
	}
	
	func removePasswordForServer(server: String, area: String?) {
		removeDataForServer(server, area: area)
	}
	
	//MARK: -
	
	func setData(passwordData: NSData, forServer server: String, area: String?) {
		setData(passwordData, forServer: server, area: area, displayValue: nil)
	}
	
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
	
	func removeDataForServer(server: String, area: String?) {
		let passwordQuery = createBaseDictionary(server, account: area)
		SecItemDelete(passwordQuery)
	}
}

