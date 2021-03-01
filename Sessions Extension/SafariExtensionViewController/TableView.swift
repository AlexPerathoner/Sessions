//
//  TableView.swift
//  Sessions Extension
//
//  Created by Alex Perathoner on 28/02/2021.
//  Copyright © 2021 Alex Perathoner. All rights reserved.
//

import Cocoa

class TableView: NSTableView {
	weak var singleMenu: NSMenu!
	weak var vc: SafariExtensionViewController?
	override func rightMouseDown(with event: NSEvent) {
		super.rightMouseDown(with: event)
		let correctLocation = convert(event.locationInWindow, from: nil)
			if let singleMenuWTabs = singleMenu {
				let sessions = vc?.sessions
				let pages = sessions?[self.clickedRow].pages ?? []
				singleMenuWTabs.item(withTag: 1)?.submenu?.removeAllItems()
				for page in pages {
					let menuItem = NSMenuItem(title: page.title, action: nil, keyEquivalent: "")
					singleMenuWTabs.item(withTag: 1)?.submenu?.addItem(menuItem)
				}
				singleMenuWTabs.item(withTag: 1)?.title = "\(pages.count) tabs:"
				singleMenuWTabs.popUp(positioning: singleMenuWTabs.items.first, at: correctLocation, in: self)
			}
	}
}
