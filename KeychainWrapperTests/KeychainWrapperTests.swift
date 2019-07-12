//
//  KeychainWrapperTests.swift
//  KeychainWrapperTests
//
//  Created by Mars on 2019/7/9.
//  Copyright © 2019 Mars. All rights reserved.
//

import XCTest
@testable import KeychainWrapper

class KeychainWrapperTests: XCTestCase {
  let stringValue = "test value"
  let stringKey = "testSetString.keychain.wrapper"
  let intValue = 11
  let intKey = "testSetInt.keychain.wrapper"
  let arrayValue = [1, 2, 3, 4]
  let arrayKey = "testSetArray.keychain.wrapper"
  
  var kcWrapper: KeychainWrapper!
  
  override func setUp() {
    super.setUp()
    kcWrapper = KeychainWrapper(serviceName: "test.keychain.wrapper")
  }

  override func tearDown() {
    kcWrapper.removeAllKeys()
    super.tearDown()
  }

  // Test setting and reading string (a specific type).
  func testSetString() {
    guard kcWrapper.set(stringValue, forKey: stringKey) else {
      XCTFail("Set value of: \(stringValue) for key: \(stringKey) failed.")
      return
    }
  }
  
  // Test setting and reading Int (a type conforms to Numeric and Codable)
  func testReadString() {
    kcWrapper.set(stringValue, forKey: stringKey)
    let result = kcWrapper.string(forKey: stringKey)
    
    if result != stringValue {
      XCTFail("Fetch the wrong string value of key:\(stringKey).\n\(stringValue) is expected.")
    }
  }
  
  func testReadInvalidString() {
    let result = kcWrapper.string(forKey: stringKey)
    
    if result != nil {
      XCTFail("Fetch string value of key:\(stringKey) should be nil.")
    }
  }
  
  func testSetInt() {
    do {
      guard try kcWrapper.set(intValue, forKey: intKey) else {
        XCTFail("Set value of: \(intValue) for key: \(intKey) failed.")
        return
      }
    }
    catch (let e) {
      XCTFail("Set value of: \(intValue) for key: \(intKey) failed.\nReason: \(e.localizedDescription)")
    }
  }
  
  func testReadInt() {
    do {
      try kcWrapper.set(intValue, forKey: intKey)
      let result = try kcWrapper.object(of: Int.self, forKey: intKey)
      
      if result != intValue {
        XCTFail("Fetch the wrong int value of key:\(intKey).\n\(intValue) is expected.")
      }
    }
    catch (let e) {
      XCTFail("Fetch int value of key:\(intKey) failed.\nReason: \(e.localizedDescription)")
    }
  }
  
  func testReadInvalidInt() {
    let result = try? kcWrapper.object(of: Int.self, forKey: intKey)
    XCTAssertEqual(result, nil)
  }
  
  func testUpdateExistingInt() {
    do {
      try! kcWrapper.set(intValue, forKey: intKey)
      try! kcWrapper.set(4, forKey: intKey)
      let four = try kcWrapper.object(of: Int.self, forKey: intKey)
      
      XCTAssert(four == 4, "Update value of: \(4) for key: \(intKey) failed.")
    }
    catch (let e) {
      XCTFail("Update value of: \(4) for key: \(intKey) failed.\nReason: \(e.localizedDescription)")
    }
  }
  
  // Test setting and reading Array (a type conforms to Codable only)
  func testSetArray() {
    do {
      guard try kcWrapper.set(arrayValue, forKey: arrayKey) else {
        XCTFail("Set value of: \(arrayValue) for key: \(arrayKey) failed.")
        return
      }
    }
    catch (let e) {
      XCTFail("Set value of: \(arrayValue) for key: \(arrayKey) failed.\nReason: \(e.localizedDescription)")
    }
  }
  
  func testReadArray() {
    do {
      try kcWrapper.set(arrayValue, forKey: arrayKey)
      let result = try kcWrapper.object(of: Array<Int>.self, forKey: arrayKey)
      
      if result != arrayValue {
        XCTFail("Fetch the wrong array value of key:\(arrayKey).\n\(arrayValue) is expected.")
      }
    }
    catch (let e) {
      XCTFail("Fetch int value of key:\(arrayKey) failed.\nReason: \(e.localizedDescription)")
    }
  }
  
  func testReadInvalidArray() {
    let result = try? kcWrapper.object(of: Array<Int>.self, forKey: arrayKey)
    XCTAssertEqual(result, nil)
  }
  
  func testDoesNotHaveValue() {
    let result = kcWrapper.hasValue(forKey: stringKey)
    XCTAssert(result == false, "\(stringKey) should not exist.")
  }
  
  func testHasValue() {
    do {
      try kcWrapper.set(intValue, forKey: intKey)
      let result = kcWrapper.hasValue(forKey: intKey)
      
      XCTAssert(result, "\(intKey) should exists.")
    }
    catch (let e) {
      XCTFail("Set value of: \(intValue) for key: \(intKey) failed.\nReason: \(e.localizedDescription)")
    }
  }
  
  func testGetDefaultAccessibilityOfKey() {
    do {
      try kcWrapper.set(intValue, forKey: intKey)
      let accessibility = kcWrapper.accessibilityOfKey(intKey)
      
      if accessibility == nil {
        XCTFail("Get accessibility of key:\(intKey) failed.")
      }
      else if accessibility != KeychainItemAccessibility.whenUnlocked {
        XCTFail("Wrong accessibility of key:\(intKey) failed. whenUnlocked was expected.")
      }
    }
    catch (let e) {
      XCTFail("Set value of: \(intValue) for key: \(intKey) failed.\nReason: \(e.localizedDescription)")
    }
  }
  
  func testGetAccessibilityOfKey() {
    do {
      try kcWrapper.set(intValue, forKey: intKey, withAccessibility: .afterFirstUnlock)
      let accessibility = kcWrapper.accessibilityOfKey(intKey)
      
      if accessibility == nil {
        XCTFail("Get accessibility of key:\(intKey) failed.")
      }
      else if accessibility != KeychainItemAccessibility.afterFirstUnlock {
        XCTFail("Wrong accessibility of key:\(intKey) failed. afterFirstUnlock was expected.")
      }
    }
    catch (let e) {
      XCTFail("Set value of: \(intValue) for key: \(intKey) failed.\nReason: \(e.localizedDescription)")
    }
  }
  
  func testGetAccessibilityOfKeyFailed() {
    let accessibility = kcWrapper.accessibilityOfKey(intKey)
    XCTAssertEqual(accessibility, nil)
  }
  
  func testGetAllKeys() {
    do {
      try kcWrapper.set(intValue, forKey: intKey)
      kcWrapper.set(stringValue, forKey: stringKey)
      try kcWrapper.set(arrayValue, forKey: arrayKey)
      let keySet = kcWrapper.allKeys()
      let expected: Set<String> = [intKey, stringKey, arrayKey]
      
      XCTAssertEqual(keySet, expected)
    }
    catch (let e) {
      XCTFail("Set value of key failed.\nReason: \(e.localizedDescription)")
    }
  }
  
  func testEmptyKeys() {
    let keySet = kcWrapper.allKeys()
    XCTAssertEqual(keySet, [])
  }
  
  func testRemoveObject() {
    do {
      try kcWrapper.set(intValue, forKey: intKey)
      let isRemoved = kcWrapper.removeObject(forKey: intKey)
      
      XCTAssert(isRemoved, "Remove item for key:\(intKey) failed.")
      
    }
    catch (let e) {
      XCTFail("Set value of key failed.\nReason: \(e.localizedDescription)")
    }
  }
  
  func testRemoveAllKeys() {
    do {
      kcWrapper.set(stringValue, forKey: stringKey)
      try kcWrapper.set(intValue, forKey: intKey)
      try kcWrapper.set(arrayValue, forKey: arrayKey)
      
      let isRemoved = kcWrapper.removeAllKeys()
      let noIntValue = !kcWrapper.hasValue(forKey: intKey)
      let noStringValue = !kcWrapper.hasValue(forKey: stringKey)
      let noArrayValue = !kcWrapper.hasValue(forKey: arrayKey)
      let result = isRemoved && noIntValue && noStringValue && noArrayValue
      
      XCTAssert(result, "Some keys still have values.")
    }
    catch (let e) {
      XCTFail("Set value of keychain item failed.\nReason: \(e.localizedDescription)")
    }
  }
  
  func testWipeKeychain() {
    let keychainSecClass = [
      kSecClassGenericPassword,
      kSecClassInternetPassword,
      kSecClassCertificate,
      kSecClassKey,
      kSecClassIdentity
    ]
    
    KeychainWrapper.wipeKeychain()
    
    var queryDictionary: [String: Any] = [:]
    
    keychainSecClass.forEach {
      queryDictionary = [kSecClass as String: $0]
      let status = SecItemCopyMatching(queryDictionary as CFDictionary, nil)
      XCTAssert(status == errSecItemNotFound, "keychain items of class:\($0) does not wipe out.")
    }
  }
}
