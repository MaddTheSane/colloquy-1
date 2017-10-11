//
//  CQKeychain.swift
//  Colloquy (Old)
//
//  Created by C.W. Betts on 1/28/16.
//
//

import Foundation
import Security

private func createBaseDictionary(_ server: String, account: String?) -> [String: Any] {
	var query = [String: Any]()
	
	query[kSecClass as String] = kSecClassInternetPassword
	query[kSecAttrServer as String] = server
	if let account = account {
		query[kSecAttrAccount as String] = account
	}
	
	return query;
}

@objc(CQKeychain)
final public class CQKeychain : NSObject {
	private override init() {
		super.init()
	}
	@objc(standardKeychain)
	public static let standard = CQKeychain()
	
	@objc(setPassword:forServer:area:)
	public func setPassword(_ password: String, forServer server: String, area: String? = nil) {
		setPassword(password, forServer: server, area: area, displayValue: nil)
	}
	
	@objc(setPassword:forServer:area:displayValue:)
	public func setPassword(_ password: String, forServer server: String, area: String? = nil, displayValue: String?) {
		guard password.characters.count != 0 else {
			removePassword(forServer: server, area: area)
			return
		}
		
		let passwordData = Data(bytes: Array(password.utf8))
		
		setData(passwordData, forServer: server, area: area, displayValue: displayValue)
	}
	
	@objc(passwordForServer:area:)
	public func password(forServer server: String, area: String? = nil) -> String? {
		if let data = data(forServer: server, area: area) {
			return String(data: data, encoding: .utf8)
		}
		return nil
	}
	
	@objc(removePasswordForServer:area:)
	public func removePassword(forServer server: String, area: String? = nil) {
		removeData(forServer: server, area: area)
	}
	
	//MARK: -
	
	@objc(setData:forServer:area:)
	public func setData(_ passwordData: Data, forServer server: String, area: String? = nil) {
		setData(passwordData, forServer: server, area: area, displayValue: nil)
	}
	
	@objc(setData:forServer:area:displayValue:)
	public func setData(_ passwordData: Data, forServer server: String, area: String? = nil, displayValue: String?) {
		guard passwordData.count != 0 else {
			removeData(forServer: server, area: area)
			return
		}
		
		var passwordEntry = createBaseDictionary(server, account: area);
		
		passwordEntry[kSecValueData as String] = passwordData
		if let displayValue = displayValue {
			passwordEntry[kSecAttrLabel as String] = displayValue
		}
		
		let status = SecItemAdd(passwordEntry as NSDictionary, nil);
		if status == errSecDuplicateItem {
			passwordEntry.removeValue(forKey: kSecValueData as String)
			
			let attributesToUpdate = [kSecValueData as String: passwordData]
			
			SecItemUpdate(passwordEntry as NSDictionary, attributesToUpdate as NSDictionary);
		}
	}
	
	@objc(dataForServer:area:)
	public func data(forServer server: String, area: String? = nil) -> Data? {
		var passwordQuery = createBaseDictionary(server, account: area);
		
		passwordQuery[kSecReturnData as String] = true
		passwordQuery[kSecMatchLimit as String] = kSecMatchLimitOne
		
		var resultDataRef: AnyObject? = nil
		let status = SecItemCopyMatching(passwordQuery as NSDictionary, &resultDataRef)
		if status == noErr, let resultDataRef = resultDataRef as? Data {
			return resultDataRef
		}
		
		return nil
	}
	
	@objc(removeDataForServer:area:)
	public func removeData(forServer server: String, area: String? = nil) {
		let passwordQuery = createBaseDictionary(server, account: area)
		SecItemDelete(passwordQuery as NSDictionary)
	}
}

