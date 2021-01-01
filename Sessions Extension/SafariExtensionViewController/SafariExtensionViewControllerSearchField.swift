//
//  SafariExtensionViewControllerSearchField.swift
//  Sessions Extension
//
//  Created by Alex Perathoner on 19/12/2020.
//  Copyright © 2020 Alex Perathoner. All rights reserved.
//

import Cocoa

extension SafariExtensionViewController: NSSearchFieldDelegate {
	func setupSearchfield() {
		self.searchField.delegate = self
	}
	
	@IBAction func searching(_ sender: NSSearchField) {
		if(sender.stringValue != "") {
			isSearching = true
			filteredSessions.removeAll()
			for i in sessions {
				if shouldShowItem(item: i, str: sender.stringValue.lowercased()) {
					filteredSessions.append(i)
				}
			}
		} else {
			isSearching = false
			filteredSessions = []
		}
		tableView.reloadData()
	}
	
	private func shouldShowItem(item: Session, str: String) -> Bool {
		let nameContains = item.name.lowercased().contains(str)
		for page in item.pages {
			if(page.title.lowercased().contains(str)) {
				return true
			}
		}
		return nameContains
	}
}
