//
//  GitHubSearchAPI.swift
//  GitHubSearchApp
//
//  Created by Cory Kim on 12/23/24.
//

import Foundation
import RxCocoa
import RxSwift

protocol GitHubSearchAPI {
	func search(query: String?, page: Int) -> Observable<(repos: [String], nextPage: Int?)>
}

final class GitHubSearchAPIImpl: GitHubSearchAPI {
	
	func url(forQuery query: String?, page: Int) -> URL? {
		guard let query = query else { return nil }
		return URL(string: "https://api.github.com/search/repositories?q=\(query)&page=\(page)")
	}
	
	func search(query: String?, page: Int) -> Observable<(repos: [String], nextPage: Int?)> {
		let emptyResult: ([String], Int?) = ([], nil)
		guard let url = url(forQuery: query, page: page), query != "" else {
			return .just(emptyResult)
		}
		
		return URLSession.shared.rx.json(url: url)
			.map { json -> ([String], Int?) in
				guard let dict = json as? [String: Any] else { return emptyResult }
				guard let items = dict["items"] as? [[String: Any]] else { return emptyResult }
				let repos = items.compactMap { $0["full_name"] as? String }
				let nextPage = repos.isEmpty ? nil : page + 1
				return (repos, nextPage)
			}
			.do(onError: { error in
				if case let .some(.httpRequestFailed(response, _)) = error as? RxCocoaURLError, response.statusCode == 403 {
					print("⚠️ GitHub API rate limit exceeded. Wait for 60 seconds and try again.")
				}
				
			})
			.catchAndReturn(emptyResult)
		
	}
}
