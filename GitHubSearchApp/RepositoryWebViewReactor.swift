//
//  RepositoryWebViewReactor.swift
//  GitHubSearchApp
//
//  Created by Cory Kim on 1/7/25.
//

import Foundation

import ReactorKit

final class RepositoryWebViewReactor: Reactor {
	
	enum Action {
		case loadView(repositoryName: String)
		case webViewLoadStart
		case webViewLoadFinish
	}
	
	enum Mutation {
		case setURL(repositoryName: String)
		case setIsLoading(isLoading: Bool)
	}
	
	struct State {
		let hostURL = "https://github.com/"
		var currentURL: URL?
		var isLoading: Bool = false
	}
	
	var initialState: State = State()
	
	func mutate(action: Action) -> Observable<Mutation> {
		switch action {
		case .loadView(repositoryName: let repositoryName):
			return .just(Mutation.setURL(repositoryName: repositoryName))
		case .webViewLoadStart:
			return .just(Mutation.setIsLoading(isLoading: true))
		case .webViewLoadFinish:
			return .just(Mutation.setIsLoading(isLoading: false))
		}
	}
	
	func reduce(state: State, mutation: Mutation) -> State {
		var state = state
		switch mutation {
		case .setURL(repositoryName: let repositoryName):
			state.currentURL = URL(string: currentState.hostURL + repositoryName)
		case .setIsLoading(let isLoading):
			state.isLoading = isLoading
		}
		return state
	}
	
}
