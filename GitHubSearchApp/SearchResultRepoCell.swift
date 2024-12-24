//
//  SearchResultRepoCell.swift
//  GitHubSearchApp
//
//  Created by Cory Kim on 12/24/24.
//

import UIKit
import SnapKit

final class SearchResultRepoCell: UITableViewCell {
	
	@objc
	static var reuseIdentifier: String {
		return String(describing: Self.self)
	}
	
	let titleLabel: UILabel = {
		let label = UILabel()
		label.textColor = .black
		return label
	}()
	
	override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
		super.init(style: style, reuseIdentifier: reuseIdentifier)
		
		configure()
	}
	
	required init?(coder: NSCoder) {
		super.init(coder: coder)
		
		configure()
	}
	
	private func configure() {
		configureUI()
	}
	
	func update(title: String) {
		titleLabel.text = title
	}
	
	private func configureUI() {
		contentView.addSubview(titleLabel)
		titleLabel.snp.makeConstraints { make in
			make.edges.equalToSuperview().inset(8)
		}
	}
}
