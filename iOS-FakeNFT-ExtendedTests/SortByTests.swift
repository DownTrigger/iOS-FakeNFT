//
//  SortByTests.swift
//  iOS-FakeNFT-ExtendedTests
//
//  Created by Irina Muravyeva on 23.09.2026.
//

import XCTest
@testable import iOS_FakeNFT_Extended

struct Person {
    let name: String
    let age: Int
}

final class SortByTests: XCTestCase {
    
    func testSortByAscending() {
        // Given
        let people = [
            Person(name: "Anna", age: 30),
            Person(name: "Maria", age: 20),
            Person(name: "Olga", age: 40)
        ]
        
        // When
        let result = sortBy(
            people,
            keyPath: \.age
        )
        
        // Then
        XCTAssertEqual(
            result.map(\.age),
            [20, 30, 40]
        )
    }
    
    func testSortByDescending() {
        // Given
        let people = [
            Person(name: "Anna", age: 30),
            Person(name: "Maria", age: 20),
            Person(name: "Olga", age: 40)
        ]
        
        // When
        let result = sortBy(
            people,
            keyPath: \.age,
            ascending: false
        )
        
        // Then
        XCTAssertEqual(
            result.map(\.age),
            [40, 30, 20]
        )
    }
    
    func testSortByString() {
        // Given
        let people = [
            Person(name: "Olga", age: 40),
            Person(name: "Anna", age: 30),
            Person(name: "Maria", age: 20)
        ]
        
        // When
        let result = sortBy(
            people,
            keyPath: \.name
        )
        
        // Then
        XCTAssertEqual(
            result.map(\.name),
            ["Anna", "Maria", "Olga"]
        )
    }
    
    func testSortByDoesNotModifyOriginalArray() {
        // Given
        let people = [
            Person(name: "Olga", age: 40),
            Person(name: "Anna", age: 30),
            Person(name: "Maria", age: 20)
        ]
        
        // When
        _ = sortBy(
            people,
            keyPath: \.age
        )
        
        // Then
        XCTAssertEqual(
            people.map(\.age),
            [40, 30, 20]
        )
    }
    
    func testSortByEmptyArray() {
        // Given
        let people: [Person] = []
        
        // When
        let result = sortBy(
            people,
            keyPath: \.age
        )
        
        // Then
        XCTAssertTrue(result.isEmpty)
    }
}
