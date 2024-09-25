//
//  testChallengeUITests.swift
//  testChallengeUITests
//
//  Created by Wim Tanudjaja on 9/16/24.
//

import XCTest

class FlickrAppUITests: XCTestCase {

    var app: XCUIApplication!

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.

        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false

        // Launch the app
        app = XCUIApplication()
        app.launch()
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        app = nil
    }

    // Test to verify the search functionality and images appearing in the grid
    func testSearchAndDisplayImages() throws {
        // Verify if the search bar exists
        let searchField = app.textFields["Image Search Bar"]
        XCTAssertTrue(searchField.exists, "The search bar should be visible")
        
        // Tap the search bar and enter text
        searchField.tap()
        searchField.typeText("porcupine")
        
        // Dismiss the keyboard (if needed)
        app.keyboards.buttons["return"].tap()
        
        // Wait for the images to appear
        let firstImage = app.images.firstMatch
        let exists = firstImage.waitForExistence(timeout: 10) // Wait up to 10 seconds for the images to load
        XCTAssertTrue(exists, "Images should appear in the grid after a search")
    }
    
    // Test to verify the share button in the detail view
    func testDetailViewAndShareButton() throws {
        // Search for images
        let searchField = app.textFields["Image Search Bar"]
        searchField.tap()
        searchField.typeText("porcupine")
        
        app.keyboards.buttons["return"].tap()

        // Wait for the first image and tap it
        let firstImage = app.images.firstMatch
        XCTAssertTrue(firstImage.waitForExistence(timeout: 10), "First image should appear")
        firstImage.tap()
        
        // Verify if the share button exists in the detail view
        let shareButton = app.buttons["Share Image"]
        XCTAssertTrue(shareButton.exists, "The share button should be visible in the detail view")
        
        // Tap the share button
        shareButton.tap()
        
        // Verify that the share sheet appears
        let activitySheet = app.otherElements["ActivityListView"]
        XCTAssertTrue(activitySheet.waitForExistence(timeout: 5), "The share sheet should appear")
    }
}
