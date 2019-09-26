//
//  KeychainItemTests.swift
//  KeychainWrapperTests
//
//  Created by Mars on 2019/9/22.
//  Copyright © 2019 Mars. All rights reserved.
//

import XCTest
@testable import KeychainWrapper

class Point: Codable {
  var x: Double = 0
  var y: Double = 0
}

class Demo {
  @KeychainStoreNumber(key: "int.demo.key") var value: Int
  @KeychainStoreObject(key: "point.demo.key") var point: Point?
}

class KeychainItemTests: XCTestCase {
  override func setUp() {
      // Put setup code here. This method is called before the invocation of each test method in the class.
  }

  override func tearDown() {
      // Put teardown code here. This method is called after the invocation of each test method in the class.
  }

  func testKeychainItemNumber() {
    let demo = Demo()
    demo.value = 1110
    
    XCTAssertEqual(demo.value, 1110)
    
    var valueInKC = KeychainWrapper.default.object(of: Int.self, forKey: "int.demo.key")
    XCTAssertEqual(valueInKC, 1110)
    
    demo.value = 1010
    valueInKC = KeychainWrapper.default.object(of: Int.self, forKey: "int.demo.key")
    XCTAssertEqual(valueInKC, 1010)
  }
}
