//
//  ArrayTests.swift
//  MovieQuizTests

import XCTest
@testable import MovieQuiz

class ArrayTests: XCTest {
    func testGetValueInRange() {
        // Given
        let array = [1, 1, 2, 3, 5]
        // When
        let value = array[safe: 2]
        // Then
        XCTAssertEqual(value, 2)
    }
    
    func testGetValueOutRange() {
        // Given
        let array = [1, 1, 2, 3, 5]
        // When
        let value = array[safe: 20]
        // Then
        XCTAssertNil(value)
    }
}


