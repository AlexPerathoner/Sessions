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
	// MARK: searchfield
	@IBOutlet weak var searchField: NSSearchField!
	var isSearching = false
	
	
	override func viewDidLoad() {
		super.viewDidLoad()
		setupTable()
		setupSearchfield()
		preferredContentSize = NSSize(width: 243, height: 316)
		if let r: [Session] = retrieveSession() {
			print("Sessions retrieved")
			sessions = r
		}
		ignoringPinnedTabsOutlet.state =
			UserDefaults.standard.bool(forKey: Constants.ignoringPinned) ? .on : .off
    }
	
	
	//MARK: - pinned tabs switch
	@IBOutlet weak var ignoringPinnedTabsOutlet: NSSwitch!
	
	@IBAction func ignorePinnedTabsBtn(_ sender: NSSwitch) {
		UserDefaults.standard.setValue(sender.state == .on, forKey: Constants.ignoringPinned)
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
	
	
	

	@IBAction func cellTitleChanged(_ sender: NSTextField) {
		let newName = sender.stringValue
		let index = tableView.row(for: sender)
		sessions[index].name = newName
		saveSessions(session: sessions)
		print("Name changed to \(newName)")
	}
	
	
	@IBAction func restoreMenuItem(sender: NSMenuItem) {
		restoreSession(index: tableView.clickedRow, asPrivate: false)
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
