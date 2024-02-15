//
//  PersonalAssistantTests.swift
//  PersonalAssistantTests
//
//  Created by 顾艳华 on 2/10/24.
//

import XCTest
import LangChain
@testable import PersonalAssistant

final class PersonalAssistantTests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testCompareStringArrays() throws {
        let vm = ChatModel()
        let oldStrings = [Document(page_content: "a", metadata: [:]),Document(page_content: "b", metadata: [:]),Document(page_content: "c", metadata: [:]),Document(page_content: "d", metadata: [:])]
        let newStrings = [Document(page_content: "b", metadata: [:]),Document(page_content: "c", metadata: [:]),Document(page_content: "e", metadata: [:]),Document(page_content: "f", metadata: [:])]

        let changes = vm.compareStringArrays(oldArray: oldStrings, newArray: newStrings)
        print("To Delete: \(changes.toDelete)")
        print("To Add: \(changes.toAdd)")
    }

    func testCompareStringArrays2() throws {
        let vm = ChatModel()
        let oldStrings = [Document(page_content: "a", metadata: [:]),Document(page_content: "b", metadata: [:]),Document(page_content: "c", metadata: [:]),Document(page_content: "d", metadata: [:])]
        let newStrings = [Document(page_content: "b", metadata: [:]),Document(page_content: "a", metadata: [:])]

        let changes = vm.compareStringArrays(oldArray: oldStrings, newArray: newStrings)
        print("To Delete: \(changes.toDelete)")
        print("To Add: \(changes.toAdd)")
    }
    
    func testCompareStringArrays3() throws {
        let vm = ChatModel()
        let oldStrings = [Document(page_content: "a", metadata: [:]),Document(page_content: "b", metadata: [:]),Document(page_content: "c", metadata: [:]),Document(page_content: "d", metadata: [:])]
        let newStrings = [Document(page_content: "bccc", metadata: [:]),Document(page_content: "c", metadata: [:]),Document(page_content: "e", metadata: [:]),Document(page_content: "f", metadata: [:])]

        let changes = vm.compareStringArrays(oldArray: oldStrings, newArray: newStrings)
        print("To Delete: \(changes.toDelete)")
        print("To Add: \(changes.toAdd)")
    }
}
