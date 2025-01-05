//
//  GitHubSearchAPIMock.swift
//  GitHubSearchApp
//
//  Created by Cory Kim on 12/29/24.
//

import Foundation

import RxSwift


final class GitHubSearchAPIMock: GitHubSearchAPI {
	
	var searchResultStub: Observable<(repositoryNames: [String], nextPage: Int?)> = .empty()
	
	func search(query: String?, page: Int) -> Observable<(repositoryNames: [String], nextPage: Int?)> {
		
		return searchResultStub
	}
	
}
