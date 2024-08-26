//
//  FileManagerServiceTests.swift
//  GitBrowserTests
//
//  Created by Nibin Varghese on 2024/08/25.
//

import XCTest
@testable import GitBrowser

final class FileManagerServiceTests: XCTestCase {

    var fileManagerService: FileManagerService!

    override func setUpWithError() throws {
        fileManagerService = FileManagerService()
    }

    override func tearDownWithError() throws {
        fileManagerService = nil
    }

    func testGetTokenFromPlist_ReturnsToken_WhenPlistIsValid() {
        let expectedToken = "AccessToken"
        let mockFileName = "MockKeys"
        
        let bundle = Bundle(for: type(of: self))
        guard let plistPath = bundle.path(forResource: mockFileName, ofType: "plist") else {
            XCTFail("file not found")
            return
        }
        
        let plistDict: [String: Any] = ["AccessToken": expectedToken]
        let plistData = try! PropertyListSerialization.data(fromPropertyList: plistDict, format: .xml, options: 0)
        FileManager.default.createFile(atPath: plistPath, contents: plistData, attributes: nil)
        
        let token = fileManagerService.getTokenFromPlist()
        
        XCTAssertEqual(token, expectedToken)
    }
    
    func testGetTokenFromPlist_ReturnsNil_WhenTokenIsMissing() {
        let mockFileName = "MockKeys"
        
        let bundle = Bundle(for: type(of: self))
        guard let plistPath = bundle.path(forResource: mockFileName, ofType: "plist") else {
            XCTFail("Empty mock plist file not found")
            return
        }
        
        let plistDict: [String: Any] = [:]
        let plistData = try! PropertyListSerialization.data(fromPropertyList: plistDict, format: .xml, options: 0)
        FileManager.default.createFile(atPath: plistPath, contents: plistData, attributes: nil)
        
        let token = fileManagerService.getTokenFromPlist(fileName: mockFileName)
        
        XCTAssertNil(token)
    }
    
    func testGetTokenFromPlist_ReturnsNil_WhenPlistDoesNotExist() {
        let nonExistentFileName = "NonExistentKeys"
        
        let token = fileManagerService.getTokenFromPlist(fileName: nonExistentFileName)
        
        XCTAssertNil(token)
    }
}
