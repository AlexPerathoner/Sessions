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
		tableView.registerForDraggedTypes([dragDropType])
		tableView.singleMenu = singleSelectionMenu
		tableView.vc = self
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
	
	// MARK: reorder rows
	
	func tableView(_ tableView: NSTableView, pasteboardWriterForRow row: Int) -> NSPasteboardWriting? {
		let item = NSPasteboardItem()
		item.setString(String(row), forType: dragDropType)
		return item
	}
	
	func tableView(_ tableView: NSTableView, validateDrop info: NSDraggingInfo, proposedRow row: Int, proposedDropOperation dropOperation: NSTableView.DropOperation) -> NSDragOperation {
		if dropOperation == .above {
			return .move
		}
		return []
	}
	
	func tableView(_ tableView: NSTableView, acceptDrop info: NSDraggingInfo, row: Int, dropOperation: NSTableView.DropOperation) -> Bool {
		let originalRow = Int((info.draggingPasteboard.pasteboardItems?.first!.string(forType: .string))!) ?? -5
		if originalRow == -5 { return false }

		var newRow = row
		// When you drag an item downwards, the "new row" index is actually --1. Remember dragging operation is `.above`.
		if originalRow < newRow {
			newRow = row - 1
		}

		// Animate the rows
		tableView.beginUpdates()
		tableView.moveRow(at: originalRow, to: newRow)
		tableView.endUpdates()

		// Persist the ordering by saving your data model
		let trackItem = sessions[originalRow] //saving item
		sessions.remove(at: originalRow) //removing from old position
		sessions.insert(trackItem, at: newRow) //inserting at new pos
		
		return true
		
		
		/*
		var oldIndexes = [Int]()
		info.enumerateDraggingItems(options: [], for: tableView, classes: [NSPasteboardItem.self], searchOptions: [:]) { (item, i, pointer) in
			if let str = (item.item as! NSPasteboardItem).string(forType: self.dragDropType), let index = Int(str) {
				oldIndexes.append(index)
			}
		}

		var oldIndexOffset = 0
		var newIndexOffset = 0

		// For simplicity, the code below uses `tableView.moveRowAtIndex` to move rows around directly.
		// You may want to move rows in your content array and then call `tableView.reloadData()` instead.
		tableView.beginUpdates()
		for oldIndex in oldIndexes {
			if oldIndex < row {
				tableView.moveRow(at: oldIndex + oldIndexOffset, to: row - 1)
				sessions.swapAt(oldIndex + oldIndexOffset, row - 1)
				oldIndexOffset -= 1
			} else {
				tableView.moveRow(at: oldIndex, to: row + newIndexOffset)
				sessions.swapAt(oldIndex, row + newIndexOffset)
				newIndexOffset += 1
			}
		}
		tableView.endUpdates()
		*/
		return true
	}
	
}
