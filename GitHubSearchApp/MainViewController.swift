//
//  ViewController.swift
//  GitHubSearchApp
//
//  Created by Cory Kim on 12/22/24.
//

import UIKit
import SnapKit

final class MainViewController: UIViewController {
	
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

	override func viewDidLoad() {
		super.viewDidLoad()
		
		configureUI()
		
	}
	
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
	}
	
	private func configureConstraints() {
		searchBar.snp.makeConstraints { make in
			make.top.leading.trailing.equalTo(view.safeAreaLayoutGuide)
		}
		tableView.snp.makeConstraints { make in
			make.top.equalTo(searchBar.snp.bottom)
			make.leading.trailing.bottom.equalToSuperview()
		}
	}

}
