//
//  ViewController.swift
//  GitHubSearchApp
//
//  Created by Cory Kim on 12/22/24.
//

import UIKit

import ReactorKit
import RxCocoa
import RxSwift
import SnapKit

final class MainViewController: UIViewController, View {

	typealias Reactor = MainReactor
	
	enum Section {
		case main
	}
	
	enum Text {
		static let navigationTitle = "GitHub Search"
	}
	
	let searchBar: UISearchBar = {
		let searchBar = UISearchBar()
		return searchBar
	}()
	
	let tableView: UITableView = {
		let tableView = UITableView()
		return tableView
	}()
	
	let loadingView: UIView = {
		let view = UIView()
		view.backgroundColor = .white
		view.isHidden = true
		return view
	}()
	
	let loadingIndicator: UIActivityIndicatorView = {
		let indicatorView = UIActivityIndicatorView(style: .medium)
		indicatorView.startAnimating()
		return indicatorView
	}()
	
	var tableViewDataSource: UITableViewDiffableDataSource<Section, String>?
	
	var disposeBag: DisposeBag = DisposeBag()

	override func viewDidLoad() {
		super.viewDidLoad()
		
		configureUI()
		configureTableView()
	}
	
	// MARK: - bind
	
	func bind(reactor: MainReactor) {
		bindAction(reactor)
		bindState(reactor)
	}
	
	private func bindAction(_ reactor: MainReactor) {
		// action (View -> Reactor)
		searchBar.rx.text
			.throttle(.milliseconds(300), scheduler: MainScheduler.instance)
			.map { keyword in
				Reactor.Action.search(keyword)
			}
			.bind(to: reactor.action)
			.disposed(by: disposeBag)
		
		tableView.rx.contentOffset
			.filter { [weak self] offset in
				guard let `self` = self else { return false }
				guard self.tableView.frame.height > 0 else { return false }
				return offset.y + self.tableView.frame.height >= self.tableView.contentSize.height - 100
			}
			.map { _ in Reactor.Action.fetchNextPage }
			.bind(to: reactor.action)
			.disposed(by: disposeBag)
		
		tableView.rx.itemSelected
			.subscribe(onNext: { [weak self] indexPath in
				let repositoryName = reactor.currentState.repositoryNames[indexPath.row]
				let webViewController = RepositoryWebViewController(repositoryName: repositoryName)
				webViewController.reactor = RepositoryWebViewReactor()
				self?.navigationController?.pushViewController(webViewController, animated: true)
			})
			.disposed(by: disposeBag)
	}
	
	private func bindState(_ reactor: MainReactor) {
		reactor.state
			.map { $0.repositoryNames }
			.distinctUntilChanged()
			.observe(on: MainScheduler.instance)
			.subscribe(onNext: { [weak self] repositoryNames in
				guard self?.tableViewDataSource != nil else { return }
				var snapshot = NSDiffableDataSourceSnapshot<Section, String>()
				snapshot.appendSections([.main])
				snapshot.appendItems(repositoryNames)
				self?.tableViewDataSource?.apply(snapshot, animatingDifferences: true)
			})
			.disposed(by: disposeBag)
		
		reactor.state
			.map { $0.isSearching }
			.distinctUntilChanged()
			.map { !$0 }
			.bind(to: loadingView.rx.isHidden)
			.disposed(by: disposeBag)
		
		reactor
			.pulse(\.$error)
			.compactMap { $0 }
			.observe(on: MainScheduler.instance)
			.subscribe(onNext: { [weak self] error in
				self?.alert(error: error)
			})
			.disposed(by: disposeBag)
		
	}
	
	// MARK: - private method
	
	private func alert(error: Error?) {
		guard let error = error else { return }
		let alertController = UIAlertController(
			title: "에러",
			message: error.localizedDescription,
			preferredStyle: .alert)
		let doneAction = UIAlertAction(title: "확인", style: .default)
		alertController.addAction(doneAction)
		present(alertController, animated: true)
	}
	
	// MARK: - Configuration
	
	private func configureUI() {
		configureBackgroundColor()
		configureNavigationTitle()
		configureSubViews()
		configureConstraints()
	}
	
	private func configureNavigationTitle() {
		navigationController?.navigationBar.isHidden = false
		title = Text.navigationTitle
	}
	
	private func configureBackgroundColor() {
		view.backgroundColor = .white
	}
	
	private func configureSubViews() {
		view.addSubview(searchBar)
		view.addSubview(tableView)
		view.addSubview(loadingView)
		loadingView.addSubview(loadingIndicator)
	}
	
	private func configureConstraints() {
		searchBar.snp.makeConstraints { make in
			make.top.leading.trailing.equalTo(view.safeAreaLayoutGuide)
		}
		tableView.snp.makeConstraints { make in
			make.top.equalTo(searchBar.snp.bottom)
			make.leading.trailing.bottom.equalToSuperview()
		}
		loadingView.snp.makeConstraints { make in
			make.edges.equalTo(tableView)
		}
		loadingIndicator.snp.makeConstraints { make in
			make.center.equalToSuperview()
		}
	}
	
	private func configureTableView() {
		tableView.register(SearchResultRepoCell.self, forCellReuseIdentifier: SearchResultRepoCell.reuseIdentifier)
		
		tableViewDataSource = UITableViewDiffableDataSource(
			tableView: tableView,
			cellProvider: { tableView, indexPath, item in
				let cell = tableView.dequeueReusableCell(withIdentifier: SearchResultRepoCell.reuseIdentifier, for: indexPath) as! SearchResultRepoCell
				cell.update(title: item)
				cell.selectionStyle = .none
				return cell
			})
	}

}
