//
//  TouchIDHelper.swift
//  theOfficeKeg
//
//  Created by Shawn Campbell on 6/2/16.
//  Copyright © 2016 Vet's First Choice. All rights reserved.
//  Originally FROM:

//
//  TouchIDHelper.swift
//  RxMobile
//
//  Created by Kyle Kilgour on 3/18/16.
//  Copyright © 2016 Vets First Choice. All rights reserved.
//

import Foundation
import LocalAuthentication

enum ViewError: ErrorProtocol {
	case touchIDNoId
	case touchIDCancelled
}

struct UserAuthKeyChain {
	let userName: String
	let password: String
}

private let keychainItemKey = "com.vetsfirstchoice.theOfficeKegAccount"


func saveUserNameAndPassword(_ userAuth: UserAuthKeyChain) throws -> Void {
	return try addTouchIDItem(userAuth.password, userName: userAuth.userName)
}

func retrieveUserAuth() throws -> UserAuthKeyChain {
	return try getTouchIDItem()
}

private func touchIDAvailable() -> Bool {

	let context = LAContext()
	let error: NSErrorPointer? = nil
	return context.canEvaluatePolicy(LAPolicy.deviceOwnerAuthenticationWithBiometrics, error: error!)
}

func showTouchID() -> Bool {
	return touchIDAvailable() && !hideTouchIDPref()
}

func getTouchIDItem() throws -> UserAuthKeyChain  {

	var query = Dictionary<String, AnyObject>()

	query[String(kSecClass)] = kSecClassGenericPassword
	query[String(kSecAttrService)] = keychainItemKey
	query[String(kSecReturnData)] = true
	query[String(kSecReturnAttributes)] = true
	query[String(kSecUseOperationPrompt)] = "Access your saved theOfficeKeg login information."


	var returnValue: AnyObject?


	let errStatus = SecItemCopyMatching(query, &returnValue)

	guard errStatus != errSecUserCanceled else {
		throw ViewError.touchIDCancelled
	}

	guard let data = returnValue as? NSDictionary,
		let username = data[String(kSecAttrAccount)] as? String,
		let passwordData = data[String(kSecValueData)] as? Data,
		let password = NSString(data:passwordData, encoding:String.Encoding.utf8.rawValue) as? String else {
			throw ViewError.touchIDNoId
	}

	return UserAuthKeyChain(userName:username, password: password)
}


func addTouchIDItem(_ value: String, userName: String) throws -> Void {


	// Should be the secret invalidated when passcode is removed? If not then use kSecAttrAccessibleWhenUnlocked
	var error: Unmanaged<CFError>?

	//let error: UnsafeMutablePointer<Unmanaged<CFError>?> = UnsafeMutablePointer<Unmanaged<CFError>?>()

	var flags: SecAccessControlCreateFlags
	flags = SecAccessControlCreateFlags.touchIDAny

	guard let sacObject = SecAccessControlCreateWithFlags(kCFAllocatorDefault,
	                                                      kSecAttrAccessibleWhenPasscodeSetThisDeviceOnly,
	                                                      flags, &error) else {
															if let optionalError = error?.takeRetainedValue() as NSError? {
																throw optionalError
															}
															throw NSError(domain: "No SAC Object", code: -1, userInfo: nil)
	}
	let passWordData = value.data(using: String.Encoding.utf8)
	var attributes = Dictionary<String, AnyObject>()
	attributes[String(kSecClass)] = kSecClassGenericPassword
	attributes[String(kSecAttrService)] = keychainItemKey
	attributes[String(kSecValueData)] = passWordData
	attributes[String(kSecAttrAccount)] = userName
	attributes[String(kSecAttrAccessControl)] = sacObject


	let status = SecItemAdd(attributes, nil)
	if status == errSecDuplicateItem {
		var query = Dictionary<String, AnyObject>()
		query[String(kSecClass)] = kSecClassGenericPassword
		query[String(kSecAttrService)] = keychainItemKey
		query[String(kSecUseOperationPrompt)] = "Update your saved theOfficeKeg login information."
		var updates = Dictionary<String, AnyObject>()
		updates[String(kSecValueData)] = passWordData
		updates[String(kSecAttrAccount)] = userName

		let updateStatus = SecItemUpdate(query, updates)
		print("Update Item OSStatus \(updateStatus)")
	}
	print("OSStatus \(status)")

	return
}

func deleteTouchIDItem() -> Void {
	var query = Dictionary<String, AnyObject>()
	query[String(kSecClass)] = kSecClassGenericPassword
	query[String(kSecAttrService)] = keychainItemKey
	let _ = SecItemDelete(query)
}

func resetTouchID() -> Void {
	deleteTouchIDItem()
	saveTouchIDPref(false)
}

func hideTouchIDPref() -> Bool {
	return UserDefaults.standard().bool(forKey: "hideTouchID")
}

func saveTouchIDPref(_ hideTouchId: Bool) {
	UserDefaults.standard().set(hideTouchId, forKey: "hideTouchID")
}

