//
//  MainReactor.swift
//  GitHubSearchApp
//
//  Created by Cory Kim on 12/22/24.
//

import Foundation
import ReactorKit

final class MainReactor: Reactor {
	
	enum Action {
		case search(String?)
	}
	
	enum Mutation {
		case setRepos([String], nextPage: Int?)
		case setCurrentKeyword(String?)
		case setSearchingState(Bool)
	}
	
	struct State {
		var isSearching: Bool = false
		var currentKeyword: String?
		var isFetchingMore: Bool = false
		var repos: [String] = []
		var nextPage: Int?
	}
	
	var initialState: State = State()
	
	let searchAPI: GitHubSearchAPI
	
	init(searchAPI: GitHubSearchAPI) {
		self.searchAPI = searchAPI
	}
	
	func mutate(action: Action) -> Observable<Mutation> {
		switch action {
		case .search(let keyword):
			return Observable.concat([
				Observable.just(Mutation.setSearchingState(true)),
				Observable.just(Mutation.setCurrentKeyword(keyword)),
				searchAPI.search(query: keyword, page: 1)
					.take(until: self.action.filter(Action.isUpdateQueryAction))
					.map { Mutation.setRepos($0, nextPage: $1) },
				Observable.just(Mutation.setSearchingState(false))
			])
		}
	}
	
	func reduce(state: State, mutation: Mutation) -> State {
		var newState = state
		switch mutation {
		case .setCurrentKeyword(let keyword):
			newState.currentKeyword = keyword
			return newState
		case .setRepos(let repos, nextPage: let nextPage):
			newState.repos = repos
			newState.nextPage = nextPage
			return newState
		case .setSearchingState(let isSearching):
			newState.isSearching = isSearching
			return newState
		}
	}
	
}

extension MainReactor.Action {
	static func isUpdateQueryAction(_ action: MainReactor.Action) -> Bool {
		if case .search(_) = action {
			return true
		} else {
			return false
		}
	}
}
