//
//  testChallengeTests.swift
//  testChallengeTests
//
//  Created by Wim Tanudjaja on 9/16/24.
//

import XCTest
import Combine
@testable import testChallenge

class FlickrViewModelTests: XCTestCase {
    var viewModel: FlickrViewModel!
    var cancellables: Set<AnyCancellable>!
    
    override func setUp() {
        super.setUp()
        viewModel = FlickrViewModel()
        cancellables = [] // Initialize the cancellables set
    }
    
    override func tearDown() {
        cancellables = nil // Reset cancellables after each test
        super.tearDown()
    }
    
    func testFetchImages() {
        let expectation = self.expectation(description: "Fetching images")
        
        // Observe the images publisher
        viewModel.$images.dropFirst().sink { images in
            XCTAssertFalse(images.isEmpty, "Images should not be empty after fetching.")
            expectation.fulfill()
        }.store(in: &cancellables) // Store subscription in cancellables
        
        // Trigger the fetch
        viewModel.searchTerm = "porcupine"
        
        waitForExpectations(timeout: 5, handler: nil)
    }
}
