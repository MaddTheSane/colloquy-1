//
//  CQKeychain.swift
//  Colloquy (Old)
//
//  Created by C.W. Betts on 1/28/16.
//
//

import Foundation
import Security

private func createBaseDictionary(_ server: String, account: String?) -> [String: NSObject] {
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
	
	func setPassword(_ password: String, forServer server: String, area: String?) {
		setPassword(password, forServer: server, area: area, displayValue: nil)
	}
	
	func setPassword(_ password: String, forServer server: String, area: String?, displayValue: String?) {
		guard password.characters.count != 0 else {
			removePasswordForServer(server, area: area)
			return;
		}
		
		let passwordData = password.data(using: String.Encoding.utf8)!
		
		setData(passwordData, forServer: server, area: area)
	}
	
	func passwordForServer(_ server: String, area: String?) -> String? {
		if let data = dataForServer(server, area: area) {
			return String(data: data, encoding: String.Encoding.utf8)
		}
		return nil
	}
	
	func removePasswordForServer(_ server: String, area: String?) {
		removeDataForServer(server, area: area)
	}
	
	//MARK: -
	
	func setData(_ passwordData: Data, forServer server: String, area: String?) {
		setData(passwordData, forServer: server, area: area, displayValue: nil)
	}
	
	func setData(_ passwordData: Data, forServer server: String, area: String?, displayValue: String?) {
		guard passwordData.count != 0 else {
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
			passwordEntry.removeValue(forKey: kSecValueData as String)
			
			let attributesToUpdate = [kSecValueData as String: passwordData]
			
			SecItemUpdate(passwordEntry, attributesToUpdate);
		}
	}
	
	func dataForServer(_ server: String, area: String?) -> Data? {
		var passwordQuery = createBaseDictionary(server, account: area);
		
		passwordQuery[kSecReturnData as String] = true;
		passwordQuery[kSecMatchLimit as String] = kSecMatchLimitOne;
		
		var resultDataRef: AnyObject? = nil
		let status = SecItemCopyMatching(passwordQuery, &resultDataRef)
		if status == noErr && resultDataRef != nil {
			return resultDataRef as? Data
		}
		
		return nil
	}
	
	func removeDataForServer(_ server: String, area: String?) {
		let passwordQuery = createBaseDictionary(server, account: area)
		SecItemDelete(passwordQuery)
	}
}

