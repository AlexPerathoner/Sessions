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
	
	override func rightMouseDown(with event: NSEvent) {
		super.rightMouseDown(with: event)
		let correctLocation = convert(event.locationInWindow, from: nil)
		singleMenu.popUp(positioning: singleMenu.items.first, at: correctLocation, in: self)
		
	}
}
