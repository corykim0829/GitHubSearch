//
//  ViewController.swift
//  GitHubSearchApp
//
//  Created by Cory Kim on 12/22/24.
//

import UIKit

final class MainViewController: UIViewController {
	
	enum Text {
		static let navigationTitle = "GitHub Search"
	}

	override func viewDidLoad() {
		super.viewDidLoad()
		
		configureUI()
		
	}
	
	private func configureUI() {
		configureBackgroundColor()
		configureNavigationTitle()
	}
	
	private func configureNavigationTitle() {
		navigationController?.navigationBar.isHidden = false
		title = Text.navigationTitle
	}
	
	private func configureBackgroundColor() {
		view.backgroundColor = .white
	}

}
