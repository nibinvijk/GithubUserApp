//
//  UserListViewControllerTests.swift
//  GitBrowserUITests
//
//  Created by Nibin Varghese on 2024/08/26.
//

import XCTest

final class UserListViewControllerTests: XCTestCase {

    var app: XCUIApplication!
    
    override func setUpWithError() throws {
        continueAfterFailure = false
        
        app = XCUIApplication()
        app.launch()
    }

    override func tearDownWithError() throws {
        app = nil
    }

    func testSearchBarExistsAndFiltersResults() throws {

        XCTAssertTrue(app.navigationBars["GitHub Users"].exists)
        
        let searchBar = app.searchFields["Search Users"]
        XCTAssertTrue(searchBar.exists)
        
        searchBar.tap()
        searchBar.typeText("mojombo")
        
        let tableView = app.tables.element(boundBy: 0)
        let firstCell = tableView.cells.element(boundBy: 0)
        XCTAssertTrue(firstCell.exists)
        
        let firstCellText = firstCell.staticTexts.element(boundBy: 0).label
        XCTAssertTrue(firstCellText.lowercased().contains("mojombo"))
        
        searchBar.buttons["Clear text"].tap()
        
        XCTAssertTrue(tableView.cells.count > 0)
    }

    // Uncomment for performance test
//    func testLaunchPerformance() throws {
//        if #available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 7.0, *) {
//            measure(metrics: [XCTApplicationLaunchMetric()]) {
//                XCUIApplication().launch()
//            }
//        }
//    }
}
