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
import PromiseKit
import LocalAuthentication

enum ViewError: ErrorType {
	case TouchIDNoId
	case TouchIDCancelled
}

struct UserAuthKeyChain {
	let userName: String
	let password: String
}

private let keychainItemKey = "com.vetsfirstchoice.theOfficeKegAccount"


func saveUserNameAndPassword(userAuth: UserAuthKeyChain) -> Promise<Void> {
	return addTouchIDItem(userAuth.password, userName: userAuth.userName)
}

func retrieveUserAuth() -> Promise<UserAuthKeyChain> {
	return getTouchIDItem()
}

private func touchIDAvailable() -> Bool {

	let context = LAContext()
	let error: NSErrorPointer = nil
	return context.canEvaluatePolicy(LAPolicy.DeviceOwnerAuthenticationWithBiometrics, error: error)
}

func showTouchID() -> Bool {
	if #available(iOS 9.0, *) {
		return touchIDAvailable() && !hideTouchIDPref()
	} else {
		// Fallback on earlier versions
		return false
	}
}

func getTouchIDItem() -> Promise<UserAuthKeyChain> {

	var query = Dictionary<String, AnyObject>()

	query[String(kSecClass)] = kSecClassGenericPassword
	query[String(kSecAttrService)] = keychainItemKey
	query[String(kSecReturnData)] = true
	query[String(kSecReturnAttributes)] = true
	query[String(kSecUseOperationPrompt)] = "Access your saved theOfficeKeg login information."


	var returnValue: AnyObject?


	let errStatus = SecItemCopyMatching(query, &returnValue)

	guard errStatus != errSecUserCanceled else {
		return Promise(error:ViewError.TouchIDCancelled)
	}

	guard let data = returnValue as? NSDictionary,
		let username = data[String(kSecAttrAccount)] as? String,
		let passwordData = data[String(kSecValueData)] as? NSData,
		let password = NSString(data:passwordData, encoding:NSUTF8StringEncoding) as? String else {
			return Promise(error:ViewError.TouchIDNoId)
	}

	return Promise(UserAuthKeyChain(userName:username, password: password))
}


func addTouchIDItem(value: String, userName: String) -> Promise<Void> {


	// Should be the secret invalidated when passcode is removed? If not then use kSecAttrAccessibleWhenUnlocked
	var error: Unmanaged<CFError>?

	//let error: UnsafeMutablePointer<Unmanaged<CFError>?> = UnsafeMutablePointer<Unmanaged<CFError>?>()

	var flags: SecAccessControlCreateFlags
	if #available(iOS 9.0, *) {
		flags = SecAccessControlCreateFlags.TouchIDAny
	} else {
		// Fallback on earlier versions
		flags = SecAccessControlCreateFlags.UserPresence
	}

	guard let sacObject = SecAccessControlCreateWithFlags(kCFAllocatorDefault,
	                                                      kSecAttrAccessibleWhenPasscodeSetThisDeviceOnly,
	                                                      flags, &error) else {
															if let optionalError = error?.takeRetainedValue() as NSError? {
																return Promise(error:optionalError)
															}
															return Promise(error:NSError(domain: "No SAC Object", code: -1, userInfo: nil))
	}
	let passWordData = value.dataUsingEncoding(NSUTF8StringEncoding)
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

	return Promise()
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
	return NSUserDefaults.standardUserDefaults().boolForKey("hideTouchID")
}

func saveTouchIDPref(hideTouchId: Bool) {
	NSUserDefaults.standardUserDefaults().setBool(hideTouchId, forKey: "hideTouchID")
}

