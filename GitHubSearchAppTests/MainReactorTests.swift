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
	
	enum GitHubSearchAPIMockError: Error {
		case responseStatus403Error
	}
	
	func test_search_action이_들어올_때_검색이_성공한_경우_현재키워드와_레포지토리이름을_업데이트합니다() throws {
		// Given
		let apiMock = GitHubSearchAPIMock()
		let sut = MainReactor(searchAPI: apiMock)
		// API Mock 에서 검색 결과 2개 반환하도록 설정
		apiMock.searchResultStub = .just((["TEST1", "TEST2"], 1))
		
		// When
		sut.action.onNext(.search("TEST"))
		
		// Then
		XCTAssertEqual(sut.currentState.currentKeyword, "TEST")
		XCTAssertEqual(sut.currentState.repositoryNames.count, 2)
		XCTAssertNil(sut.currentState.error)
	}
	
	func test_search_action이_들어올_때_검색이_실패한_경우_레포지토리이름은_빈_배열이고_에러를_업데이트합니다() throws {
		// Given
		let mockAPI = GitHubSearchAPIMock()
		let sut = MainReactor(searchAPI: mockAPI)
		mockAPI.searchResultStub = .error(GitHubSearchAPIMockError.responseStatus403Error)
		
		// When
		sut.action.onNext(.search("TEST"))
		
		// Then
		XCTAssertEqual(sut.currentState.repositoryNames, [])
		XCTAssertNotNil(sut.currentState.error)
	}
	
	func test_fetchNextPage_action이_들어올_때_다음_페이지_조회가_성공한_경우_현재키워드를_업데이트하고_레포지토리_이름을_기존레포지토리이름에_추가합니다() throws {
		// Given
		let mockAPI = GitHubSearchAPIMock()
		let sut = MainReactor(searchAPI: mockAPI)
		// API Mock 에서 검색 결과 2개 반환하도록 설정
		mockAPI.searchResultStub = .just((["TEST1", "TEST2"], 1))
		sut.action.onNext(.search("TEST"))
		// 다음 search 요청에서는 검색 결과를 1개 반환하도록 설정
		mockAPI.searchResultStub = .just((["TEST3"], nil))
		
		// When
		sut.action.onNext(.fetchNextPage)
		
		// Then
		XCTAssertEqual(sut.currentState.currentKeyword, "TEST")
		XCTAssertEqual(sut.currentState.repositoryNames.count, 3)
		XCTAssertNil(sut.currentState.error)
	}
	
	func test_fetchNextPage_action이_들어올_때_다음_페이지_조회가_실패한_경우_현재키워드를_업데이트하고_레포지토리_이름을_이전_응답_데이터를_유지합니다() throws {
		// Given
		let mockAPI = GitHubSearchAPIMock()
		let sut = MainReactor(searchAPI: mockAPI)
		// API Mock 에서 검색 결과 2개 반환하도록 설정
		mockAPI.searchResultStub = .just((["TEST1", "TEST2"], 1))
		sut.action.onNext(.search("TEST"))
		mockAPI.searchResultStub = .error(GitHubSearchAPIMockError.responseStatus403Error)
		
		// When
		sut.action.onNext(.fetchNextPage)
		
		// Then
		XCTAssertEqual(sut.currentState.currentKeyword, "TEST")
		XCTAssertEqual(sut.currentState.repositoryNames.count, 2)
		XCTAssertNotNil(sut.currentState.error)
	}
	
}
