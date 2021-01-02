//
//  SafariExtensionViewController.swift
//  Sessions Extension
//
//  Created by Alex Perathoner on 14/08/2019.
//  Copyright © 2019 Alex Perathoner. All rights reserved.
//

import SafariServices
import AppKit

class SafariExtensionViewController: SFSafariExtensionViewController, NSControlTextEditingDelegate {
	
    static let shared = SafariExtensionViewController()
	var sessions = [Session]() {
		didSet {
			print("Value changed - Now \(sessions.count) sessions")
			saveSessions(session: sessions) //saves to userdefaults
			tableView.reloadData()
		}
	}
	var filteredSessions = [Session]()
	// MARK: table
	@IBOutlet weak var tableView: NSTableView!
	let dragDropType = NSPasteboard.PasteboardType.string
	
	// MARK: searchfield
	@IBOutlet weak var searchField: NSSearchField!
	var isSearching = false
	
	// MARK: auto update
	var timer: Timer?
	var statusImage: NSImageView?
	var deleteTimer: Timer?
	
	override func viewDidLoad() {
		super.viewDidLoad()
		setupTable()
		setupSearchfield()
		preferredContentSize = NSSize(width: 243, height: 321)
		if let r: [Session] = retrieveSession() {
			print("Sessions retrieved")
			sessions = r
		}
		ignoringPinnedTabsOutlet.state =
			UserDefaults.standard.bool(forKey: Constants.ignoringPinned) ? .on : .off
		alwaysAutoUpdateOutlet.state = UserDefaults.standard.bool(forKey: Constants.alwaysAutoUpdate) ? .on : .off
    }
	
	//MARK: - Settings
	
	@IBOutlet var settingsMenu: NSMenu!
	
	@IBAction func showSettings(_ sender: Any) {
		settingsMenu.popUp(positioning: nil, at: NSEvent.mouseLocation, in: nil)
	}
	
	//MARK: - pinned tabs switch
	@IBOutlet weak var ignoringPinnedTabsOutlet: NSMenuItem!
	@IBAction func ignorePinnedTabsBtn(_ sender: NSMenuItem) {
		sender.state = sender.state == .on ? .off : .on
		UserDefaults.standard.setValue(sender.state == .on, forKey: Constants.ignoringPinned)
	}
	
	//MARK: - auto-update switch
	@IBOutlet weak var alwaysAutoUpdateOutlet: NSMenuItem!
	@IBAction func alwaysAutoUpdateBtn(_ sender: NSMenuItem) {
		sender.state = sender.state == .on ? .off : .on
		UserDefaults.standard.setValue(sender.state == .on, forKey: Constants.alwaysAutoUpdate)
	}
	
	// MARK: - IBActions
	
    @IBAction func addSession(_ sender: Any) {
//		encodeToJSONAndSaveTo(file: "sessions.json")
		
		SFSafariApplication.getActiveWindow { (window) in
			self.getTabs(window: window) { (actTabs) in
				if actTabs.count > 0 {
					
					let name = actTabs.first!.title
					let id = self.generateId()
					
					//adds to the top of the table (note insert at)
					self.sessions.insert(Session(name: name, pages: actTabs, id: id), at: 0)
					
					//adds to the bottom of the table
					//self.sessions.append(Session(name: name, pages: actTabs))
					
					print("Added session")
				}
			}
		}
	}
	
	
	

	@objc func cellTitleChanged(sender: NSTextField) {
		let newName = sender.stringValue
		let index = tableView.row(for: sender)
		sessions[index].name = newName
		saveSessions(session: sessions)
		print("Name changed to \(newName)")
	}
	
	
	@IBAction func restoreMenuItem(sender: Any) {
		if(UserDefaults.standard.bool(forKey: Constants.alwaysAutoUpdate)) {
			restoreAndAutoUpdateClicked(sender)
		} else {
			let index = tableView.clickedRow
			restoreSession(index: index, asPrivate: isSessionsPrivate(index: index))
		}
	}
	
	
	
	@IBAction func restoreAsPrivate(_ sender: NSMenuItem) {
		if(!readPrivileges(prompt: true)) {return}
		restoreSession(index: tableView.clickedRow, asPrivate: true)
	}
	
	
	
	@IBAction func removeMenuItem(_ sender: Any) {
		if(isSearching) {
			let deleted = filteredSessions.remove(at: tableView.clickedRow).id
			for (i,d) in sessions.enumerated() {
				if d.id == deleted {
					sessions.remove(at: i)
				}
			}
		} else {
			sessions.remove(at: tableView.clickedRow)
		}
	}
	
	
	@IBAction func replaceMenuItem(_ sender: Any) {
		SFSafariApplication.getActiveWindow { (window) in
			self.getTabs(window: window) { (actTabs) in
				if actTabs.count > 0 {
					self.replacePagesInSession(index: self.tableView.clickedRow, pages: actTabs)
				}
			}
		}
	}
	
	
	@IBAction func renameMenuItem(_ sender: Any) {
		let cellView  = self.tableView.view(atColumn: 0, row: tableView.clickedRow, makeIfNecessary: false) as! NSTableCellView
		cellView.textField?.becomeFirstResponder()
	}
	
	@IBAction func exportMenuItem(_ sender: Any) {
		let dateFormatter = DateFormatter()
		dateFormatter.dateFormat = "dd/MM - h:mm"
		let name = DateFormatter().string(from: Date())
		print(encodeToJSONAndSaveTo(data: sessions[tableView.clickedRow], file: "Session" + name)!)
	}
	
	
}
