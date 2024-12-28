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
		case fetchNextPage
	}
	
	enum Mutation {
		case setRepos([String], nextPage: Int?)
		case setCurrentKeyword(String?)
		case setSearchingState(Bool)
		case setFetchingNextPage(Bool)
		case appendNextPageRepos([String], nextPage: Int?)
	}
	
	struct State {
		var isSearching: Bool = false
		var currentKeyword: String?
		var isFetchingNextPage: Bool = false
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
		case .fetchNextPage:
			guard !currentState.isFetchingNextPage else { return Observable.empty() }
			guard let page = currentState.nextPage else { return Observable.empty() }
			return Observable.concat([
				Observable.just(Mutation.setFetchingNextPage(true)),
				searchAPI.search(query: currentState.currentKeyword, page: page)
					.take(until: self.action.filter(Action.isUpdateQueryAction))
					.map { Mutation.appendNextPageRepos($0, nextPage: $1)},
				Observable.just(Mutation.setFetchingNextPage(false))
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
		case .setFetchingNextPage(let isFetchingNextPage):
			newState.isFetchingNextPage = isFetchingNextPage
			return newState
		case .appendNextPageRepos(let repos, nextPage: let nextPage):
			newState.repos.append(contentsOf: repos)
			newState.nextPage = nextPage
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
