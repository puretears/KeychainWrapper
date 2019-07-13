//
//  KeychainItemAccesssibility.swift
//  KeychainWrapper
//
//  Created by Mars on 2019/7/9.
//  Copyright © 2019 Mars. All rights reserved.
//

import Foundation

protocol KeychainAttrReprentable {
  var keychainAttrValue: CFString { get }
}

public enum KeychainItemAccessibility {
  @available(iOS 4, *)
  case afterFirstUnlock
  
  @available(iOS 4, *)
  case afterFirstUnlockThisDeviceOnly
  
  ///`case always` was deprecated in iOS 12.0
  
  @available(iOS 8, *)
  case whenPasscodeSetThisDeviceOnly
  
  /// `case alwaysThisDeviceOnly` was deprecated in iOS 12.0
  
  /// The default case.
  @available(iOS 4, *)
  case whenUnlocked
  
  @available(iOS 4, *)
  case whenUnlockedThisDeviceOnly
  
  /// CFString -> KeychainItemAccessibility
  static func accessbilityForAttributeValue(_ keychainAttrValue: CFString) -> KeychainItemAccessibility? {
    for (key, value) in keychainAccessibilityLookup {
      if value == keychainAttrValue {
        return key
      }
    }
    
    return nil
  }
}

extension KeychainItemAccessibility: KeychainAttrReprentable {
  /// KeychainItemAccessibility -> CFString
  var keychainAttrValue: CFString {
    return keychainAccessibilityLookup[self]!
  }
}

private let keychainAccessibilityLookup: [KeychainItemAccessibility:CFString] = [
  .afterFirstUnlock              : kSecAttrAccessibleAfterFirstUnlock,
  .afterFirstUnlockThisDeviceOnly: kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly,
  .whenPasscodeSetThisDeviceOnly : kSecAttrAccessibleWhenPasscodeSetThisDeviceOnly,
  .whenUnlocked                  : kSecAttrAccessibleWhenUnlocked,
  .whenUnlockedThisDeviceOnly    : kSecAttrAccessibleWhenUnlockedThisDeviceOnly
]
