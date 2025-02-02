//
//  RepositoryWebViewReactorTest.swift
//  GitHubSearchAppTests
//
//  Created by Cory Kim on 1/7/25.
//

import XCTest

import RxSwift

@testable import GitHubSearchApp

final class RepositoryWebViewReactorTest: XCTestCase {
	
	func test_loadView_action이_실행되면_레포지토리_이름에_맞는_URL을_만든다() throws {
		// Given
		let sut = RepositoryWebViewReactor()
		let dummyRepositoryName = "swiftlang/swift"
			
		// When
		sut.action.onNext(.loadView(repositoryName: dummyRepositoryName))
		
		// Then
		XCTAssertEqual(sut.currentState.currentURL?.absoluteString, "https://github.com/" + dummyRepositoryName)
	}
	
	func test_webLoadStart_action이_실행되면_isLoading은_true가_된다() throws {
		// Given
		let sut = RepositoryWebViewReactor()
		
		// When
		sut.action.onNext(.webLoadStart)
		
		// Then
		XCTAssertEqual(sut.currentState.isLoading, true)
	}
	
	func test_webLoadFinish_action이_실행되면_isLoading은_false가_된다() throws {
		// Given
		let sut = RepositoryWebViewReactor()
		
		// When
		sut.action.onNext(.webLoadFinish)
		
		// Then
		XCTAssertEqual(sut.currentState.isLoading, false)
	}
	
}
