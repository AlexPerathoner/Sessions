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
		tableView.delegate = self
		tableView.dataSource = self
		tableView.menu?.autoenablesItems = true
	}
	
	
	func numberOfRows(in tableView: NSTableView) -> Int {
		if(isSearching) {
			return filteredSessions.count
		}
		return sessions.count
	}
	
	func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
		
		var image: NSImage?
		var text = ""
		var view: NSView?
		if (tableColumn?.identifier.rawValue == "titleColumn") {
			text = (isSearching ? filteredSessions : sessions)[row].name
			view = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "titleCell"), owner: nil) as? NSTableCellView
			(view as? NSTableCellView)?.textField?.stringValue = text
			if let textField = (view as? NSTableCellView)?.textField {
				textField.action = #selector(cellTitleChanged(sender:))
			}
		} else {
			if((isSearching ? filteredSessions : sessions)[row].isUpdating ?? false) {
				image = NSImage(named: "NSStatusAvailable")
			}
			view = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "imageCell"), owner: nil) as? NSImageView
		   (view as? NSImageView)?.image = image ?? nil
		}
		
		return view
	}
	
	
	
	@IBAction func tableDoubleClick(_ sender: Any?) {
		restoreMenuItem(sender: sender)
	}
}
