//
//  UserRepositoryViewControllerTests.swift
//  GitBrowserUITests
//
//  Created by Nibin Varghese on 2024/08/26.
//

import XCTest

final class UserRepositoryViewControllerTests: XCTestCase {

    var app: XCUIApplication!
    
    override func setUpWithError() throws {
        continueAfterFailure = false
        
        app = XCUIApplication()
        app.launch()
    }

    override func tearDownWithError() throws {
        app = nil
    }

    func testNavigationToUserRepositoryViewController() throws {
        XCTAssertTrue(app.navigationBars["GitHub Users"].exists)
        
        let firstCell = app.tables.cells.element(boundBy: 0)
        XCTAssertTrue(firstCell.exists)
        firstCell.tap()
        
        let element = app.navigationBars["Repositories"]
        _ = element.waitForExistence(timeout: 10)
        
        let tableView = app.tables.element(boundBy: 0)
        XCTAssertTrue(tableView.exists)
        
        let firstRepoCell = tableView.cells.element(boundBy: 0)
        XCTAssertTrue(firstRepoCell.exists)
    }

        // Uncomment for performance test
//    func testLaunchPerformance() throws {
//        if #available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 7.0, *) {
//            // This measures how long it takes to launch your application.
//            measure(metrics: [XCTApplicationLaunchMetric()]) {
//                XCUIApplication().launch()
//            }
//        }
//    }
}
