//
//  Collection+safe.swift
//  GitHubSearchApp
//
//  Created by Cory Kim on 1/11/25.
//

import Foundation

extension Collection {
	
	subscript (safe index: Index) -> Element? {
		return indices.contains(index) ? self[index] : nil
	}
	
}
