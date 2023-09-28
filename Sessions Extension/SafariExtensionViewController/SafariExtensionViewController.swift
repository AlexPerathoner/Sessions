//
//  SafariExtensionViewController.swift
//  Sessions Extension
//
//  Created by Alex Perathoner on 14/08/2019.
//  Copyright © 2019 Alex Perathoner. All rights reserved.
//

import SafariServices
import AppKit
import os.log

class SafariExtensionViewController: SFSafariExtensionViewController, NSControlTextEditingDelegate {
	
    static let shared = SafariExtensionViewController()
	var sessions = [Session]() {
		didSet {
            os_log(.debug, "Value changed - Now %d sessions", sessions.count)
			saveSessions(session: sessions) //saves to userdefaults
			tableView.reloadData()
		}
	}
	var filteredSessions = [Session]()
	// MARK: table
	@IBOutlet weak var tableView: TableView!
	let dragDropType = NSPasteboard.PasteboardType.string
	
	// MARK: searchfield
	@IBOutlet weak var searchField: NSSearchField!
	var isSearching = false
	
	// MARK: auto update
	var timer: Timer?
	var statusImage: NSImageView?
	var deleteTimer: Timer?
	
	// MARK: menus
	@IBOutlet var singleSelectionMenu: NSMenu!
	
	
	override func viewDidLoad() {
		super.viewDidLoad()
		setupTable()
		setupSearchfield()
		preferredContentSize = NSSize(width: 243, height: 321)
		if let r: [Session] = retrieveSession() {
            os_log(.info, "Sessions retrieved")
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
        os_log(.debug, "Adding session...")
        DispatchQueue.global().sync {
            SFSafariApplication.getActiveWindow() { (window) in
                os_log(.debug, "retrieved active window")
                self.getTabs(window: window) { (actTabs) in
                    if actTabs.count > 0 {
                        
                        let name = actTabs.first!.title
                        let id = self.generateId()
                        
                        //adds to the top of the table (note insert at)
                        self.sessions.insert(Session(name: name, pages: actTabs, id: id), at: 0)
                        
                        //adds to the bottom of the table
                        //self.sessions.append(Session(name: name, pages: actTabs))
                        
                        os_log(.debug, "Added session.")
                    }
                }
            }
        }
	}
	
	
	

	@objc func cellTitleChanged(sender: NSTextField) {
		let newName = sender.stringValue
		let index = tableView.row(for: sender)
		sessions[index].name = newName
		saveSessions(session: sessions)
        os_log(.debug, "Name changed to %@", newName)
	}
	
	
	@IBAction func restoreMenuItem(sender: Any) {
        os_log(.debug, "Restore menu item...")
        
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
		let clickedRow = self.tableView.clickedRow
		SFSafariApplication.getActiveWindow { (window) in
			self.getTabs(window: window) { (actTabs) in
				if actTabs.count > 0 {
                    os_log(.debug, "Replacing session @s with a session of %d tabs", clickedRow, actTabs.count)
					self.replacePagesInSession(index: clickedRow, pages: actTabs)
				} else {
                    os_log(.error, "No tabs found while trying to replace")
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
