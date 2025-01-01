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
		case setRepositoryNames([String], nextPage: Int?)
		case setCurrentKeyword(String?)
		case setIsSearching(Bool)
		case setFetchingNextPage(Bool)
		case appendNextPageRepos([String], nextPage: Int?)
		case setError(Error?)
	}
	
	struct State {
		var isSearching: Bool = false
		var currentKeyword: String?
		var isFetchingNextPage: Bool = false
		var repositoryNames: [String] = []
		var nextPage: Int?
		@Pulse var error: Error?
	}
	
	var initialState: State = State()
	
	private let searchAPI: GitHubSearchAPI
	
	init(searchAPI: GitHubSearchAPI) {
		self.searchAPI = searchAPI
	}
	
	func mutate(action: Action) -> Observable<Mutation> {
		switch action {
		case .search(let keyword):
			return Observable.concat([
				Observable.just(Mutation.setIsSearching(true)),
				Observable.just(Mutation.setCurrentKeyword(keyword)),
				search(query: keyword, page: 1),
				Observable.just(Mutation.setIsSearching(false))
			])
		case .fetchNextPage:
			guard !currentState.isFetchingNextPage else { return Observable.empty() }
			return Observable.concat([
				Observable.just(Mutation.setFetchingNextPage(true)),
				fetchNextPageRepositories(),
				Observable.just(Mutation.setFetchingNextPage(false))
			])
		}
	}
	
	private func search(query: String?, page: Int) -> Observable<Mutation> {
		searchAPI.search(query: query, page: 1)
			.take(until: self.action.filter(Action.isUpdateQueryAction))
			.map { Mutation.setRepositoryNames($0, nextPage: $1) }
			.catch { error in
				return .just(Mutation.setError(error))
			}
	}
	
	private func fetchNextPageRepositories() -> Observable<Mutation> {
		guard let page = currentState.nextPage else { return Observable.empty() }
		return searchAPI.search(query: currentState.currentKeyword, page: page)
			.take(until: self.action.filter(Action.isUpdateQueryAction))
			.map { Mutation.appendNextPageRepos($0, nextPage: $1)}
			.catch { error in
				return .just(Mutation.setError(error))
			}
	}
	
	func reduce(state: State, mutation: Mutation) -> State {
		var newState = state
		switch mutation {
		case .setCurrentKeyword(let keyword):
			newState.currentKeyword = keyword
		case .setRepositoryNames(let repositoryNames, nextPage: let nextPage):
			newState.repositoryNames = repositoryNames
			newState.nextPage = nextPage
		case .setIsSearching(let isSearching):
			newState.isSearching = isSearching
		case .setFetchingNextPage(let isFetchingNextPage):
			newState.isFetchingNextPage = isFetchingNextPage
		case .appendNextPageRepos(let repos, nextPage: let nextPage):
			newState.repositoryNames.append(contentsOf: repos)
			newState.nextPage = nextPage
		case .setError(let error):
			newState.error = error
		}
		return newState
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
