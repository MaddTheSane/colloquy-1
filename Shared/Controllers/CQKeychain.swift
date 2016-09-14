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
	query[kSecAttrServer as String] = server as NSString
	if let account = account {
		query[kSecAttrAccount as String] = account as NSString
	}
	
	return query;
}

final class CQKeychain : NSObject {
	private override init() {
		super.init()
	}
	@objc(standardKeychain)
	static let standard = CQKeychain()
	
	@objc(setPassword:forServer:area:)
	func set(password: String, for server: String, area: String?) {
		set(password: password, for: server, area: area, displayValue: nil)
	}
	
	@objc(setPassword:forServer:area:displayValue:)
	func set(password: String, for server: String, area: String?, displayValue: String?) {
		guard password.characters.count != 0 else {
			removePassword(for: server, area: area)
			return;
		}
		
		let passwordData = password.data(using: String.Encoding.utf8)!
		
		set(passwordData, for: server, area: area)
	}
	
	@objc(passwordForServer:area:)
	func password(for server: String, area: String?) -> String? {
		if let data = data(for: server, area: area) {
			return String(data: data, encoding: String.Encoding.utf8)
		}
		return nil
	}
	
	@objc(removePasswordForServer:area:)
	func removePassword(for server: String, area: String?) {
		removeData(for: server, area: area)
	}
	
	//MARK: -
	
	@objc(setData:forServer:area:)
	func set(_ passwordData: Data, for server: String, area: String? = nil) {
		set(passwordData, for: server, area: area, displayValue: nil)
	}
	
	@objc(setData:forServer:area:displayValue:)
	func set(_ passwordData: Data, for server: String, area: String?, displayValue: String?) {
		guard passwordData.count != 0 else {
			removeData(for: server, area: area)
			return
		}
		
		var passwordEntry = createBaseDictionary(server, account: area);
		
		passwordEntry[kSecValueData as String] = passwordData as NSData
		if let displayValue = displayValue {
			passwordEntry[kSecAttrLabel as String] = displayValue as NSString
		}
		
		let status = SecItemAdd(passwordEntry as NSDictionary, nil);
		if status == errSecDuplicateItem {
			passwordEntry.removeValue(forKey: kSecValueData as String)
			
			let attributesToUpdate = [kSecValueData as String: passwordData]
			
			SecItemUpdate(passwordEntry as NSDictionary, attributesToUpdate as NSDictionary);
		}
	}
	
	@objc(dataForServer:area:)
	func data(for server: String, area: String?) -> Data? {
		var passwordQuery = createBaseDictionary(server, account: area);
		
		passwordQuery[kSecReturnData as String] = true as NSNumber;
		passwordQuery[kSecMatchLimit as String] = kSecMatchLimitOne;
		
		var resultDataRef: AnyObject? = nil
		let status = SecItemCopyMatching(passwordQuery as NSDictionary, &resultDataRef)
		if status == noErr && resultDataRef != nil {
			return resultDataRef as? Data
		}
		
		return nil
	}
	
	@objc(removeDataForServer:area:)
	func removeData(for server: String, area: String?) {
		let passwordQuery = createBaseDictionary(server, account: area)
		SecItemDelete(passwordQuery as NSDictionary)
	}
}

