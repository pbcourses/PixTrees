//
//  PixTreesTests.swift
//  PixTreesTests
//
//  Created by Matteo Piombo on 08/01/16.
//  Copyright © 2016 Matteo Piombo. All rights reserved.
//

import XCTest
@testable import PixTrees

class PixTreesTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        
        let t1_1 = ForestLocation(x: 1, y: 1)
        let t2_3 = ForestLocation(x: 2, y: 3)
        let t4_4 = ForestLocation(x: 4, y: 4)
        let t9_11 = ForestLocation(x: 9, y: 11)
        let t20_30 = ForestLocation(x: 20, y: 30)
        
        let foo = Forest(id: "foo", xLength: 10, yLength: 12)
        
        // Test additions
        let validAddition = foo.addTree(t1_1)
        foo.addTree(t2_3)
        foo.addTree(t4_4)
        foo.addTree(t9_11)
        let failingAddition = foo.addTree(t20_30)
        XCTAssert(validAddition == true, "Valid addition Failed")
        XCTAssert(failingAddition == false, "Invalid addition Failed")
        
        let expectedTrees = [t1_1, t2_3, t4_4, t9_11]
        let trees = foo.treeLocations
        XCTAssert(trees.elementsEqual(expectedTrees, isEquivalent: ==), "Location additions Failed")
        
        
        // Test search areas
        let expectedSearchResult = [(t1_1, t4_4), (t2_3, t9_11)]
        let searchResult = foo.rectanglesContaining(3)
        XCTAssert(searchResult.elementsEqual(expectedSearchResult, isEquivalent: { $0.0 == $1.0 && $0.1 == $1.1 }) , "Search Test Failed")
        
        // Test remove trees
        let removed = foo.removeBetween(firstVertex: ForestLocation(x: 1, y: 1), secondVertex: ForestLocation(x: 2, y: 3))
        XCTAssert(removed == 2, "Test Remove Between Failed")
        
        // Test remaining trees after operations
        let expectedRemainingTrees = [t4_4, t9_11]
        
        let remainingTrees = foo.treeLocations
        
        XCTAssert(remainingTrees.elementsEqual(expectedRemainingTrees, isEquivalent: ==), "Remaining Trees Failed")
        XCTAssert(foo.count == 2, "Tree Count after operations Failed")
    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measureBlock {
            // Put the code you want to measure the time of here.
        }
    }
    
}
