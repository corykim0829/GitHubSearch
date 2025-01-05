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
		let sut = MainReactor(searchAPI: mockAPI)
		mockAPI.searchResultStub = .just((["TEST1", "TEST2"], 1)) // Mock API 에서 검색 결과 2개 반환하고 있음
		
		// When
		sut.action.onNext(.search("TEST"))
		
		// Then
		XCTAssertEqual(sut.currentState.currentKeyword, "TEST")
		XCTAssertEqual(sut.currentState.repositoryNames.count, 2)
	}
	
	func testfetchingNextPage() throws {
		// Given
		let mockAPI = GitHubSearchAPIMock()
		let sut = MainReactor(searchAPI: mockAPI)
		mockAPI.searchResultStub = .just((["TEST1", "TEST2"], 1)) // Mock API 에서 검색 결과 2개 반환하고 있음
		sut.action.onNext(.search("TEST"))
		mockAPI.searchResultStub = .just((["TEST3"], nil)) // 다음 search 요청에서는 검색 결과 1개 더 추가한다
		
		// When
		sut.action.onNext(.fetchNextPage)
		
		// Then
		XCTAssertEqual(sut.currentState.currentKeyword, "TEST")
		XCTAssertEqual(sut.currentState.repositoryNames.count, 3)
	}
	
}
