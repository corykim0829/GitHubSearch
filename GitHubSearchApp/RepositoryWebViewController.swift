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
		
		webView.rx.didStartLoad
			.subscribe { [weak self] _ in
				self?.indicatorView.startAnimating()
			}
			.disposed(by: disposeBag)
		
		webView.rx.didFinishLoad
			.subscribe { [weak self] _ in
				self?.indicatorView.stopAnimating()
			}
			.disposed(by: disposeBag)
		
		webView.rx.didFailLoad
			.subscribe { [weak self] _ in
				self?.indicatorView.stopAnimating()
			}
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
	
}

extension Reactive where Base: WKWebView {
	var navigationDelegate: DelegateProxy<WKWebView, WKNavigationDelegate> {
		RxWKNavigationDelegateProxy.proxy(for: base)
	}
	
	var didStartLoad: Observable<Void> {
		navigationDelegate
			.methodInvoked(#selector(WKNavigationDelegate.webView(_:didStartProvisionalNavigation:)))
			.map { _ in }
	}
	
	var didFinishLoad: Observable<Void> {
		navigationDelegate
			.methodInvoked(#selector(WKNavigationDelegate.webView(_:didFinish:)))
			.map { _ in }
	}
	
	var didFailLoad: Observable<Error> {
		navigationDelegate
			.methodInvoked(#selector(WKNavigationDelegate.webView(_:didFailProvisionalNavigation:withError:)))
			.map { $0[2] as? Error }
			.compactMap { $0 }
	}
}
