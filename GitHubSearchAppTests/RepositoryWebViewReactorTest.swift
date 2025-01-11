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
	
}
