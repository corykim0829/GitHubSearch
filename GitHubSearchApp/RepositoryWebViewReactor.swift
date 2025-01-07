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
	}
	
	enum Mutation {
		case setURL(repositoryName: String)
	}
	
	struct State {
		var currentURL: URL?
	}
	
	var initialState: State = State()
	
	func mutate(action: Action) -> Observable<Mutation> {
		switch action {
		case .loadView(repositoryName: let repositoryName):
			return .just(Mutation.setURL(repositoryName: repositoryName))
		}
	}
	
	func reduce(state: State, mutation: Mutation) -> State {
		var state = state
		switch mutation {
		case .setURL(repositoryName: let repositoryName):
			let hostURL = "https://github.com/"
			state.currentURL = URL(string: hostURL + repositoryName)
		}
		return state
	}
	
}
