//
//  Copyright © 2018 Fredrik Bystam. All rights reserved.
//

import XCTest
@testable import Frallware

class DiffingTests: XCTestCase {

    private struct Person: Equatable {
        let id: String
        let name: String
    }

    func testMyers_Same() {
        let old: [String] = [
            "example"
        ]
        let new: [String] = [
            "example"
        ]

        let diff = Different.myers(between: old, and: new)

        XCTAssertTrue(diff.isEmpty)
    }

    func testMyers_SameEmpty() {
        let old: [String] = [
        ]
        let new: [String] = [
        ]

        let diff = Different.myers(between: old, and: new)

        XCTAssertTrue(diff.isEmpty)
    }

    func testMyers_Insert() {
        let old: [String] = [
            "example"
        ]
        let new: [String] = [
            "example",
            "example2"
        ]

        let diff = Different.myers(between: old, and: new)

        XCTAssertEqual(diff.deleted, [])
        XCTAssertEqual(diff.inserted, [1])
        XCTAssertEqual(diff.lcs, [.init(old: 0, new: 0)])
    }

    func testMyers_InsertFromEmpty() {
        let old: [String] = [
        ]
        let new: [String] = [
            "example",
            "example2"
        ]

        let diff = Different.myers(between: old, and: new)

        XCTAssertEqual(diff.deleted, [])
        XCTAssertEqual(diff.inserted, [1, 0])
        XCTAssertEqual(diff.lcs, [])
    }

    func testMyers_Delete() {
        let old: [String] = [
            "example",
            "example2"
        ]
        let new: [String] = [
            "example"
        ]

        let diff = Different.myers(between: old, and: new)

        XCTAssertEqual(diff.deleted, [1])
        XCTAssertEqual(diff.inserted, [])
        XCTAssertEqual(diff.lcs, [.init(old: 0, new: 0)])
    }

    func testMyers_DeleteToEmpty() {
        let old: [String] = [
            "example",
            "example2"
        ]
        let new: [String] = [
        ]

        let diff = Different.myers(between: old, and: new)

        XCTAssertEqual(diff.deleted, [1, 0])
        XCTAssertEqual(diff.inserted, [])
        XCTAssertEqual(diff.lcs, [])
    }

    func testMyers_Move() {
        let old: [String] = [
            "example",
            "example2"
        ]
        let new: [String] = [
            "example2",
            "example"
        ]

        let diff = Different.myers(between: old, and: new)

        XCTAssertEqual(diff.deleted, [0])
        XCTAssertEqual(diff.inserted, [1])
        XCTAssertEqual(diff.lcs, [.init(old: 1, new: 0)])
    }

    func testMyers_Compound() {
        let old: [Int] = [
            1, 2, 3, 4, 5
        ]
        let new: [Int] = [
            5, -1, 2, 4, 6, 7
        ]

        let diff = Different.myers(between: old, and: new)

        XCTAssertEqual(diff.deleted, [0, 2, 4])
        XCTAssertEqual(diff.inserted, [0, 1, 4, 5])
        XCTAssertEqual(diff.lcs, [
            .init(old: 1, new: 2), // the 2
            .init(old: 3, new: 3), // the 4
        ])
    }

    func testMyers_Disjunct() {
        let old: [Int] = [
            1, 2, 3, 4, 5
        ]
        let new: [Int] = [
            6, 7, 8, 9, 10, 11
        ]

        let diff = Different.myers(between: old, and: new)

        XCTAssertEqual(diff.deleted, [0, 1, 2, 3, 4])
        XCTAssertEqual(diff.inserted, [0, 1, 2, 3, 4, 5])
        XCTAssertEqual(diff.lcs, [])
    }

    func testMyers_LongMove() {
        let old: [Int] = [
            1, 2, 3, 4, 5, 6, 7, 8, 9, 10
        ]
        let new: [Int] = [
            2, 3, 4, 5, 6, 7, 8, 9, 10, 1
        ]

        let diff = Different.myers(between: old, and: new)

        XCTAssertEqual(diff.deleted, [0])
        XCTAssertEqual(diff.inserted, [9])
        XCTAssertEqual(diff.lcs, [
            .init(old: 1, new: 0),
            .init(old: 2, new: 1),
            .init(old: 3, new: 2),
            .init(old: 4, new: 3),
            .init(old: 5, new: 4),
            .init(old: 6, new: 5),
            .init(old: 7, new: 6),
            .init(old: 8, new: 7),
            .init(old: 9, new: 8),
        ])
    }

    func testDiff_Same() {
        let old: [Person] = [
            Person(id: "1", name: "Test")
        ]
        let new: [Person] = [
            Person(id: "1", name: "Test")
        ]

        let diff = Different.diff(between: old, and: new, matchOn: \.id)

        XCTAssertTrue(diff.isEmpty)
    }

    func testDiff_Insert() {
        let old: [Person] = [
            Person(id: "1", name: "Test")
        ]
        let new: [Person] = [
            Person(id: "1", name: "Test"),
            Person(id: "2", name: "Test2")
        ]

        let diff = Different.diff(between: old, and: new, matchOn: \.id)

        XCTAssertEqual(diff.deleted, [])
        XCTAssertEqual(diff.inserted, [1])
        XCTAssertEqual(diff.updated, [])
    }

    func testDiff_Delete() {
        let old: [Person] = [
            Person(id: "1", name: "Test"),
            Person(id: "2", name: "Test2"),
            Person(id: "3", name: "Test3")
        ]
        let new: [Person] = [
            Person(id: "1", name: "Test"),
            Person(id: "3", name: "Test3")
        ]

        let diff = Different.diff(between: old, and: new, matchOn: \.id)

        XCTAssertEqual(diff.deleted, [1])
        XCTAssertEqual(diff.inserted, [])
        XCTAssertEqual(diff.updated, [])
    }

    func testDiff_Updated() {
        let old: [Person] = [
            Person(id: "1", name: "Test"),
            Person(id: "2", name: "Test2")
        ]
        let new: [Person] = [
            Person(id: "1", name: "Test_new"),
            Person(id: "2", name: "Test2")

        ]

        let diff = Different.diff(between: old, and: new, matchOn: \.id)

        XCTAssertEqual(diff.deleted, [])
        XCTAssertEqual(diff.inserted, [])
        XCTAssertEqual(diff.updated, [0])
    }

    func testDiff_Compound() {
        let old: [Person] = [
            Person(id: "1", name: "Test"),
            Person(id: "2", name: "Test2"),
            Person(id: "3", name: "Test3"),
            Person(id: "4", name: "Test4"),
            Person(id: "5", name: "Test5"),
            Person(id: "6", name: "Test6")
        ]
        let new: [Person] = [
            Person(id: "2", name: "Test2_new"),
            Person(id: "3", name: "Test3"),
            Person(id: "5", name: "Test5_new"),
            Person(id: "6", name: "Test6"),
            Person(id: "1", name: "Test_new")
        ]

        let diff = Different.diff(between: old, and: new, matchOn: \.id)

        XCTAssertEqual(diff.deleted, [0, 3])
        XCTAssertEqual(diff.inserted, [4])
        XCTAssertEqual(diff.updated, [0, 2])
    }
}
