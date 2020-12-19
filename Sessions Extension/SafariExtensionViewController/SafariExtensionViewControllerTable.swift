//
//  SafariExtensionViewControllerTable.swift
//  Sessions Extension
//
//  Created by Alex Perathoner on 19/12/2020.
//  Copyright © 2020 Alex Perathoner. All rights reserved.
//

import Cocoa

extension SafariExtensionViewController: NSTableViewDelegate, NSTableViewDataSource {
	
	
	func setupTable() {
		
		tableView.doubleAction = #selector(tableDoubleClick(_:)) //item of table clicked
		self.tableView.delegate = self
		self.tableView.dataSource = self
	}
	
	
	func numberOfRows(in tableView: NSTableView) -> Int {
		if(isSearching) {
			return filteredSessions.count
		}
		return sessions.count
	}
	
	func tableView(_ tableView: NSTableView, objectValueFor tableColumn: NSTableColumn?, row: Int) -> Any?
	{
		return (isSearching ? filteredSessions : sessions)[row].name
	}
	
	
	@objc func tableDoubleClick(_ sender: Any?) {
		let index = tableView.selectedRow
		restoreSession(index: index, asPrivate: isSessionsPrivate(index: index)) //gets index of item clicked
	}
}
