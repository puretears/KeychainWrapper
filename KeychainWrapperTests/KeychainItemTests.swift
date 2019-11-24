//
//  KeychainItemTests.swift
//  KeychainWrapperTests
//
//  Created by Mars on 2019/9/22.
//  Copyright © 2019 Mars. All rights reserved.
//

import XCTest
@testable import KeychainWrapper

struct Point: Codable, Equatable {
  var x: Double = 0
  var y: Double = 0
  
  
}

class Demo {
  @KeychainStoreNumber(key: "int.demo.key") var value: Int?
  @KeychainStoreObject(key: "point.demo.key") var point: Point?
  @KeychainStoreString(key: "string.demo.key") var string: String?
}

class KeychainItemTests: XCTestCase {
  var demo: Demo!
  
  override func setUp() {
    demo = Demo()
  }

  override func tearDown() {
    demo.$value.removeObject(forKey: "int.demo.key")
    demo.$point.removeObject(forKey: "point.demo.key")
    demo.$string.removeObject(forKey: "string.demo.key")
  }

  func testKeychainItemNumber() {
    demo.value = 1110
    XCTAssertEqual(demo.value, 1110)
    
    var valueInKC = KeychainWrapper.default.object(of: Int.self, forKey: "int.demo.key")
    XCTAssertEqual(valueInKC, 1110)
    
    demo.value = 1010
    valueInKC = KeychainWrapper.default.object(of: Int.self, forKey: "int.demo.key")
    XCTAssertEqual(valueInKC, 1010)
  }
  
  func testKeychainItemObject() {
    demo.point = Point(x: 0, y: 0)
    XCTAssertEqual(demo.point, Point(x: 0, y: 0))
    
    var valueInKC = KeychainWrapper.default.object(of: Point.self, forKey: "point.demo.key")
    XCTAssertEqual(valueInKC, Point(x: 0, y: 0))
    
    demo.point = Point(x: 1, y: 1)
    valueInKC = KeychainWrapper.default.object(of: Point.self, forKey: "point.demo.key")
    XCTAssertEqual(valueInKC, Point(x: 1, y: 1))
  }
  
  func testKeychainItemString() {
    demo.string = "KeychainWrapper"
    XCTAssertEqual(demo.string, "KeychainWrapper")
    
    var valueInKC = KeychainWrapper.default.string(forKey: "string.demo.key")
    XCTAssertEqual(valueInKC, "KeychainWrapper")

    demo.string = "PropertyWrapper"
    valueInKC = KeychainWrapper.default.string(forKey: "string.demo.key")
    XCTAssertEqual(valueInKC, "PropertyWrapper")
  }
}
