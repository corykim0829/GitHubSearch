//
//  MockGitHubSearchAPI.swift
//  GitHubSearchApp
//
//  Created by Cory Kim on 12/29/24.
//

import Foundation

import RxSwift


final class MockGitHubSearchAPI: GitHubSearchAPI {
	func search(query: String?, page: Int) -> Observable<(repositoryNames: [String], nextPage: Int?)> {
		Observable.just((["dummy1", "dummy2"], 2))
	}
	
}
