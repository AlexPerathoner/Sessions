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
				if i.name.lowercased().contains(sender.stringValue.lowercased()) {
					filteredSessions.append(i)
				}
			}
		} else {
			isSearching = false
			filteredSessions = []
		}
		tableView.reloadData()
	}
}
