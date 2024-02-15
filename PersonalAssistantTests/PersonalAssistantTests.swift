//
//  PersonalAssistantTests.swift
//  PersonalAssistantTests
//
//  Created by 顾艳华 on 2/10/24.
//

import XCTest
@testable import PersonalAssistant

final class PersonalAssistantTests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testCompareStringArrays() throws {
        let vm = ViewModel()
        let oldStrings = ["a", "b", "c", "d"]
        let newStrings = ["b", "c", "e", "f"]

        let changes = vm.compareStringArrays(oldArray: oldStrings, newArray: newStrings)
        print("To Delete: \(changes.toDelete)")
        print("To Add: \(changes.toAdd)")
    }

    func testCompareStringArrays2() throws {
        let vm = ViewModel()
        let oldStrings = ["a", "b", "c", "d"]
        let newStrings = ["b", "a"]

        let changes = vm.compareStringArrays(oldArray: oldStrings, newArray: newStrings)
        print("To Delete: \(changes.toDelete)")
        print("To Add: \(changes.toAdd)")
    }
    
    func testCompareStringArrays3() throws {
        let vm = ViewModel()
        let oldStrings = ["a", "b", "c", "d"]
        let newStrings = ["bccc", "c", "e", "f"]

        let changes = vm.compareStringArrays(oldArray: oldStrings, newArray: newStrings)
        print("To Delete: \(changes.toDelete)")
        print("To Add: \(changes.toAdd)")
    }
}
