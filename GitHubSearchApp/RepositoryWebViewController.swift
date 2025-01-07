//
//  RepositoryWebViewController.swift
//  GitHubSearchApp
//
//  Created by Cory Kim on 1/7/25.
//

import UIKit
import WebKit

import SnapKit
import ReactorKit
import RxCocoa
import RxSwift

final class RepositoryWebViewController: UIViewController, View {
	
	typealias Reactor = RepositoryWebViewReactor
	
	private let webView = WKWebView()
	
	var disposeBag = DisposeBag()
	
	let repositoryName: String
	
	init(repositoryName: String) {
		self.repositoryName = repositoryName
		super.init(nibName: nil, bundle: nil)
	}
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		configureUI()
		
		reactor?.action.onNext(.loadView(repositoryName: repositoryName))
	}
	
	func bind(reactor: RepositoryWebViewReactor) {
		
		reactor.state
			.compactMap { $0.currentURL }
			.distinctUntilChanged()
			.map { URLRequest(url: $0) }
			.subscribe(onNext: { [weak self] urlRequest in
				self?.webView.load(urlRequest)
			})
			.disposed(by: disposeBag)
	}
	
	private func configureUI() {
		configureSubviews()
		configureConstraints()
	}
	
	private func configureSubviews() {
		view.addSubview(webView)
	}
	
	private func configureConstraints() {
		webView.snp.makeConstraints { make in
			make.edges.equalToSuperview()
		}
	}
	
}
