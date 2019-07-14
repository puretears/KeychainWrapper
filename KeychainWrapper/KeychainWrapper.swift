//
//  KeychainWrapper.swift
//  KeychainWrapper
//
//  Created by Mars on 2019/7/9.
//  Copyright © 2019 Mars. All rights reserved.
//

import Foundation

/// Keychain service attributes
private let secMatchLimit         : String = kSecMatchLimit          as String
private let secReturnData         : String = kSecReturnData          as String
private let secValueData          : String = kSecValueData           as String
private let secAttrAccessible     : String = kSecAttrAccessible      as String
private let secClass              : String = kSecClass               as String
private let secAttrService        : String = kSecAttrService         as String
private let secAttrGeneric        : String = kSecAttrGeneric         as String
private let secAttrAccount        : String = kSecAttrAccount         as String
private let secAttrAccessGroup    : String = kSecAttrAccessGroup     as String
private let secReturnAttributes   : String = kSecReturnAttributes    as String

open class KeychainWrapper {
  /// Singleton
  public static let `default` = KeychainWrapper()
  
  /// Attributes
  private (set) public var serviceName: String
  private (set) public var accessGroup: String?
  private static let defaultServiceName: String = {
    Bundle.main.bundleIdentifier ?? "SwiftKeychainWrapper"
  }()
  
  /// Initializers
  
  /// Create an instance of `KeychainWrapper` with a custom service name and optional access group.
  ///
  /// - parameter serviceName:
  /// - parameter accessGroup:
  public init(serviceName: String, accessGroup: String? = nil) {
    self.serviceName = serviceName
    self.accessGroup = accessGroup
  }
  
  private convenience init() {
    self.init(serviceName: KeychainWrapper.defaultServiceName)
  }
  
  /// Public methods
  
  /// Check if keychain data exists for a specific key.
  ///
  /// - parameter forKey: The key of data to be looked up.
  /// - parameter withAccessibility: Optional accessibility level to use when looking up the keychain item.
  /// - returns: `true` if the data associated with the key exists, else `false`.
  open func hasValue(
    forKey key: String,
    withAccessibility accessibility: KeychainItemAccessibility? = nil) -> Bool {
    if let _ = data(forKey: key, withAccessibility: accessibility) {
      return true
    }
    
    return false
  }
  
  open func accessibilityOfKey(_ key: String) -> KeychainItemAccessibility? {
    var queryDictionary = setupQueryDictionary(forKey: key)
    queryDictionary[secMatchLimit] = kSecMatchLimitOne
    queryDictionary[secReturnAttributes] = kCFBooleanTrue
    
    var results: AnyObject?
    let status = SecItemCopyMatching(queryDictionary as CFDictionary, &results)
    
    guard status == errSecSuccess,
      let dictionary = results as? [String: AnyObject],
      let accessibility = dictionary[secAttrAccessible] as? String
      else {
        return nil
    }
    
    return KeychainItemAccessibility.accessbilityForAttributeValue(accessibility as CFString)
  }
  
  /// Get the keys of all keychain entries matching the current `serviceName` and `accessGroup`.
  open func allKeys() -> Set<String> {
    var queryDictionary: [String: Any] = [
      secClass: kSecClassGenericPassword,
      secAttrService: serviceName,
      secReturnAttributes: kCFBooleanTrue!,
      secMatchLimit: kSecMatchLimitAll
    ]
    
    if let accessGroup = accessGroup {
      queryDictionary[secAttrAccessGroup] = accessGroup
    }
    
    var results: AnyObject?
    let status = SecItemCopyMatching(queryDictionary as CFDictionary, &results)
    
    guard status == errSecSuccess else { return [] }
    
    var keys = Set<String>()
    
    if let results = results as? [[AnyHashable: Any]] {
      for attributes in results {
        if let accountData = attributes[secAttrAccount] as? Data,
          let key = String(data: accountData, encoding: .utf8) {
          keys.insert(key)
        }
      }
    }
    
    return keys
  }
  
  /// MARK: public getters
  
  /// Returns an object that conforms to `Decodable` for a specified key.
  ///
  /// - parameter forKey: The key of data to be looked up.
  /// - parameter withAccessibility: Optional accessibility level to use when looking up the keychain item.
  /// - returns: The `T` object associated with the key if it exists. If no data exists, returns nil.
  open func object<T>(
    of type: T.Type,
    forKey key: String,
    withAccessibility accessibility: KeychainItemAccessibility? = nil) throws -> T? where T:Decodable {
    guard let data = data(forKey: key, withAccessibility: accessibility) else {
      return nil
    }
    
    return try JSONDecoder().decode(T.self, from: data)
  }
  
  
  /// Returns an object that conforms to `Decodable` for a specified key.
  ///
  /// - parameter forKey: The key of data to be looked up.
  /// - parameter withAccessibility: Optional accessibility level to use when looking up the keychain item.
  /// - returns: The `T` object associated with the key if it exists. If no data exists, returns nil.
  open func object<T>(
    of type: T.Type,
    forKey key: String,
    withAccessibility accessibility: KeychainItemAccessibility? = nil) throws -> T?
    where  T:Numeric, T:Decodable {
    guard let data = data(forKey: key, withAccessibility: accessibility) else {
      return nil
    }
    
    return try JSONDecoder().decode([T].self, from: data)[0]
  }
  
  /// Returns a string for a specified key.
  ///
  /// - parameter forKey: The key of data to be looked up.
  /// - parameter withAccessibility: Optional accessibility level to use when looking up the keychain item.
  /// - returns: The string associated with the key if it exists. If no data exists, returns nil.
  open func string(
    forKey key: String,
    withAccessibility accessibility: KeychainItemAccessibility? = nil) -> String? {
    guard let data = data(forKey: key, withAccessibility: accessibility) else {
      return nil
    }
    
    return String(data: data, encoding: .utf8)
  }
  
  /// Returns a data object for a specified key.
  ///
  /// - parameter forKey: The key of data to be looked up.
  /// - parameter withAccessibility: Optional accessibility level to use when looking up the keychain item.
  /// - returns: The data object associated with the key if it exists. If no data exists, returns nil.
  open func data(
    forKey key: String,
    withAccessibility accessibility: KeychainItemAccessibility? = nil) -> Data? {
    var queryDictionary = setupQueryDictionary(forKey: key, withAccessibility: accessibility)
    
    // Limit result to 1
    queryDictionary[secMatchLimit] = kSecMatchLimitOne
    
    // Specify we want persistant data reference
    queryDictionary[secReturnData] = kCFBooleanTrue
    
    // Search
    var result: AnyObject?
    let status = SecItemCopyMatching(queryDictionary as CFDictionary, &result)
    
    return (status == errSecSuccess) ? (result as? Data) : nil
  }
  
  /// MARK: Public setters
  
  /// Save an `Encodable` compliant object associated with a specific key.
  /// If the key already exists, the data will be overritten.
  ///
  /// - parameter value:
  /// - parameter forKey: The key of data to be set.
  /// - parameter withAccessibility: Optional accessibility level to use when looking up the keychain item.
  /// - returns: `True` if set was successful.
  @discardableResult open func set<T>(
    _ value: T,
    forKey key: String,
    withAccessibility accessibility: KeychainItemAccessibility? = nil) throws -> Bool where T:Encodable {
    let data = try JSONEncoder().encode(value)
    
    return set(data, forKey: key, withAccessibility: accessibility)
  }
  
  /// Save an `Encodable` compliant object associated with a specific key.
  /// If the key already exists, the data will be overritten.
  ///
  /// - parameter value:
  /// - parameter forKey: The key of data to be set.
  /// - parameter withAccessibility: Optional accessibility level to use when looking up the keychain item.
  /// - returns: `True` if set was successful.
  @discardableResult open func set<T>(
    _ value: T,
    forKey key: String,
    withAccessibility accessibility: KeychainItemAccessibility? = nil) throws -> Bool
    where T:Numeric, T:Encodable {
    let data = try JSONEncoder().encode([value])
    
    return set(data, forKey: key, withAccessibility: accessibility)
  }
  
  /// Save a `String` associated with a specific key. If the key already exists, the
  /// data will be overritten.
  ///
  /// - parameter value:
  /// - parameter forKey: The key of data to be set.
  /// - parameter withAccessibility: Optional accessibility level to use when looking up the keychain item.
  /// - returns: `True` if set was successful.
  @discardableResult open func set(
    _ value: String,
    forKey key: String,
    withAccessibility accessibility: KeychainItemAccessibility? = nil) -> Bool {
    if let data = value.data(using: .utf8) {
      return set(data, forKey: key, withAccessibility: accessibility)
    }
    else {
      return false
    }
  }
  
  /// Save a `Data` associated with a specific key. If the key already exists, the
  /// data will be overritten.
  ///
  /// - parameter value:
  /// - parameter forKey: The key of data to be set.
  /// - parameter withAccessibility: Optional accessibility level to use when looking up the keychain item.
  /// - returns: `True` if set was successful.
  @discardableResult open func set(
    _ value: Data,
    forKey key: String,
    withAccessibility accessibility: KeychainItemAccessibility? = nil) -> Bool {
    var queryDictionary: [String: Any] = setupQueryDictionary(forKey: key, withAccessibility: accessibility)
    queryDictionary[secValueData] = value
    
    if accessibility == nil {
      // Default protection level. The data is only valid when the device is unlocked.
      queryDictionary[secAttrAccessible] = KeychainItemAccessibility.whenUnlocked.keychainAttrValue
    }
    
    let status = SecItemAdd(queryDictionary as CFDictionary, nil)
    
    if status == errSecSuccess {
      return true
    }
    else if status == errSecDuplicateItem {
      return update(value, forKey: key, withAccessibility: accessibility)
    }
    else {
      return false
    }
  }
  
  /// Remove an object associated with a specific key. If re-using a key but with a different accessibility,
  /// you should call this method to delete the previous value first.
  ///
  /// - parameter forKey: The key of data to be deleted.
  /// - parameter withAccessibility: Optional accessibility level to use when looking up the keychain item.
  /// - returns: `True` if successful, `False` otherwise.
  @discardableResult open func removeObject(
    forKey key: String,
    withAccessibility accessbility: KeychainItemAccessibility? = nil) -> Bool {
    let queryDictionary: [String: Any] = setupQueryDictionary(forKey: key, withAccessibility: accessbility)
    let status = SecItemDelete(queryDictionary as CFDictionary)
    
    return (status == errSecSuccess)
  }
  
  /// Remove all keychain data added through the keychain wrapper.
  @discardableResult open func removeAllKeys() -> Bool {
    var queryDictionary: [String: Any] = [secClass: kSecClassGenericPassword]
    queryDictionary[secAttrService] = serviceName
    
    if let accessGroup = accessGroup {
      queryDictionary[secAttrAccessGroup] = accessGroup
    }
    
    let status = SecItemDelete(queryDictionary as CFDictionary)
    
    return (status == errSecSuccess)
  }
  
  /// Remove all keychain data even those not added by this keychain wrapper
  ///
  /// - Warning: This may remove custom keychain items you did not add via the keychain wrapper.
  ///
  open class func wipeKeychain() {
    deleteKeychainSecClass(kSecClassGenericPassword)
    deleteKeychainSecClass(kSecClassInternetPassword)
    deleteKeychainSecClass(kSecClassCertificate)
    deleteKeychainSecClass(kSecClassKey)
    deleteKeychainSecClass(kSecClassIdentity)
  }
  
  
  /// Private methods
  
  /// Remove all items for a given keychain item class.
  @discardableResult private class func deleteKeychainSecClass(
    _ destSecClass: AnyObject) -> Bool {
    let queryDictionary = [secClass: destSecClass]
    let status = SecItemDelete(queryDictionary as CFDictionary)
    
    return (status == errSecSuccess)
  }
  
  /// Update existing data associated with a key name.
  private func update(
    _ value: Data,
    forKey key: String,
    withAccessibility accessbility: KeychainItemAccessibility? = nil) -> Bool {
    let queryDictionary = setupQueryDictionary(
      forKey: key, withAccessibility: accessbility)
    let updateDictionary = [secValueData: value]
    
    let status = SecItemUpdate(
      queryDictionary as CFDictionary, updateDictionary as CFDictionary)
    
    return (status == errSecSuccess)
  }
  
  /// Setup the query dictionary used to access the keychain on iOS for a specific key name.
  ///
  /// - parameter forKey: The key this query is for
  /// - parameter withAccessibility: Optional accessibility to use when setting the keychain item.
  /// Default to `.whenUnlocked`
  /// - returns: A dictionary with all the needed properties setup to access the keychain on iOS.
  private func setupQueryDictionary(
    forKey key: String,
    withAccessibility accessibility: KeychainItemAccessibility? = nil) -> [String: Any] {
    var queryDictionary: [String: Any] = [secClass: kSecClassGenericPassword]
    queryDictionary[secAttrService] = serviceName
    
    if let accessibility = accessibility {
      queryDictionary[secAttrAccessible] = accessibility.keychainAttrValue
    }
    
    if let accessGroup = accessGroup {
      queryDictionary[secAttrAccessGroup] = accessGroup
    }
    
    let encodedKey = key.data(using: .utf8)
    
    queryDictionary[secAttrGeneric] = encodedKey
    queryDictionary[secAttrAccount] = encodedKey
    
    return queryDictionary
  }
}
