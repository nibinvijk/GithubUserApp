//
//  KeychainServiceTests.swift
//  GitBrowserTests
//
//  Created by Nibin Varghese on 2024/08/25.
//

import XCTest
@testable import GitBrowser

final class KeychainServiceTests: XCTestCase {

    var keychainService: KeychainService!
    
    override func setUpWithError() throws {
        keychainService = KeychainService()
    }

    override func tearDownWithError() throws {
        _ = keychainService.deleteToken()
        keychainService = nil
    }

    func testSaveAndRetrieveString() {
        let value = "testValue"
        
        XCTAssertTrue(keychainService.saveToken(value))
        
        let retrievedValue = keychainService.retrieveToken()
        
        XCTAssertEqual(retrievedValue, value)
    }
    
    func testSaveAndRetrieveNonExistentKey() {
        let retrievedValue = keychainService.retrieveToken()
        
        XCTAssertNil(retrievedValue)
    }
    
    func testDeleteKey() {
        let value = "testValue"
        
        XCTAssertTrue(keychainService.saveToken(value))
        XCTAssertTrue(keychainService.deleteToken())
        
        let retrievedValue = keychainService.retrieveToken()
        
        XCTAssertNil(retrievedValue)
    }

}
