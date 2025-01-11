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
	
	private let indicatorView = UIActivityIndicatorView()
	
	var disposeBag = DisposeBag()
	
	private let repositoryName: String
	
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
		configureWebViewDelegate()
		
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
		
		reactor.state
			.map { $0.isLoading }
			.distinctUntilChanged()
			.bind(to: indicatorView.rx.isAnimating)
			.disposed(by: disposeBag)
	}
	
	private func configureUI() {
		configureSubviews()
		configureConstraints()
	}
	
	private func configureSubviews() {
		view.addSubview(webView)
		view.addSubview(indicatorView)
	}
	
	private func configureConstraints() {
		webView.snp.makeConstraints { make in
			make.edges.equalToSuperview()
		}
		indicatorView.snp.makeConstraints { make in
			make.center.equalToSuperview()
		}
	}
	
	private func configureWebViewDelegate() {
		webView.navigationDelegate = self
	}
	
}

extension RepositoryWebViewController: WKNavigationDelegate {
	func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
		reactor?.action.onNext(.webLoadStart)
	}
	
	func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
		reactor?.action.onNext(.webLoadFinish)
	}
	
	func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: any Error) {
		reactor?.action.onNext(.webLoadFinish)
	}
}
