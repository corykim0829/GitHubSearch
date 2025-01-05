//
//  MainReactorTests.swift
//  MainReactorTests
//
//  Created by Cory Kim on 12/22/24.
//

import XCTest
@testable import GitHubSearchApp

import RxSwift

final class MainReactorTests: XCTestCase {
	
	func testSearchAction() throws {
		// Given
		let mockAPI = GitHubSearchAPIMock()
		let sut = MainReactor(searchAPI: mockAPI) // Mock API 에서 검색 결과 2개 반환하고 있음
		
		// When
		sut.action.onNext(.search("TEST"))
		
		// Then
		XCTAssertEqual(sut.currentState.currentKeyword, "TEST")
		XCTAssertEqual(sut.currentState.repositoryNames.count, 2)
	}
	
	func testfetchingNextPage() throws {
		// Given
		let mockAPI = GitHubSearchAPIMock()
		let sut = MainReactor(searchAPI: mockAPI) // Mock API 에서 검색 결과 2개 반환하고 있음
		
		// When
		sut.action.onNext(.search("TEST"))
		sut.action.onNext(.fetchNextPage)
		
		// Then
		XCTAssertEqual(sut.currentState.currentKeyword, "TEST")
		XCTAssertEqual(sut.currentState.repositoryNames.count, 4)
	}
	
}
