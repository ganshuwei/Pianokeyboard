//
//  UITestsHelpers.swift
//  ExampleUITests
//
//  Created by Shuwei Gan on 2021/8/1.
//  Copyright © 2021 Shuwei Gan. All rights reserved.
//

import XCTest

extension XCTestCase {

    func waitForElementToExist(_ element: XCUIElement) {
      let exists = NSPredicate(format: "exists == true")
      expectation(for: exists, evaluatedWith: element, handler: nil)
      waitForExpectations(timeout: 10, handler: nil)
    }

}

extension XCUIElement {

    func assertContains(text: String) {
        let predicate = NSPredicate(format: "label CONTAINS[c] %@", text)
        let elementQuery = staticTexts.containing(predicate)
        XCTAssertTrue(elementQuery.count > 0)
    }
}
