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
		self.getTabs { (actTabs) in
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
	
	
	

	@IBAction func cellTitleChanged(_ sender: NSTextField) {
		let newName = sender.stringValue
		let index = tableView.row(for: sender)
		sessions[index].name = newName
		saveSessions(session: sessions)
		print("Name changed to \(newName)")
	}
	
	
	@IBOutlet var meeenu: NSMenu!
	
	var indexClicked = 0
	
	
	
	@IBAction func restoreMenuItem(sender: NSMenuItem) {
		if(indexClicked == -1) { return }
		restoreSession(index: indexClicked, asPrivate: false)
		indexClicked = -1
	}
	
	
	@IBAction func restoreAsPrivate(_ sender: NSMenuItem) {
		if(indexClicked == -1) { return }
		if(!readPrivileges(prompt: true)) {return}
		restoreSession(index: indexClicked, asPrivate: true)
		indexClicked = -1
	}
	
	
	
	@IBAction func removeMenuItem(_ sender: Any) {
		if(indexClicked == -1) { return }
		if(isSearching) {
			let deleted = filteredSessions.remove(at: indexClicked).id
			for (i,d) in sessions.enumerated() {
				if d.id == deleted {
					sessions.remove(at: i)
				}
			}
		} else {
			sessions.remove(at: indexClicked)
		}
		indexClicked = -1
	}
	
	
	@IBAction func replaceMenuItem(_ sender: Any) {
		if(indexClicked == -1) { return }
		
		self.getTabs { (actTabs) in
			if actTabs.count > 0 {
				let oldSession = self.sessions[self.indexClicked]
				let newSession = Session(name: oldSession.name, pages: actTabs, id: oldSession.id)
				self.sessions[self.indexClicked] = newSession
				self.indexClicked = -1
			}
		}
	}
	
	@IBAction func renameMenuItem(_ sender: Any) {
		if(indexClicked == -1) { return }
		let cellView  = self.tableView.view(atColumn: 0, row: indexClicked, makeIfNecessary: false) as! NSTableCellView
		cellView.textField?.becomeFirstResponder()
		indexClicked = -1
	}
	
	@IBAction func exportMenuItem(_ sender: Any) {
		if(indexClicked == -1) { return }
		let dateFormatter = DateFormatter()
		dateFormatter.dateFormat = "dd/MM - h:mm"
		let name = DateFormatter().string(from: Date())
		print(encodeToJSONAndSaveTo(data: sessions[indexClicked], file: "Session" + name)!)
		indexClicked = -1
	}
	
	
	
	
	
	func restoreSession(index: Int, asPrivate: Bool) {
		var interestingSession: Session
		if(isSearching) {
			interestingSession = filteredSessions[index]
		} else {
			interestingSession = sessions[index]
		}
		
		if(asPrivate) {
			//press cmd + shift + n (new private window)
			KeyPress.simulateCmdShiftN()
			SFSafariApplication.getActiveWindow { (window) in
				//keyevent isn't dispatched synchroniously. A sleep is needed to not open the urls before the window is open
				usleep(700000) //sleep for 0.7 seconds
				window?.getAllTabs(completionHandler: { (tabs) in
					tabs[0].navigate(to: interestingSession.pages.first!.url)
				})
				for i in 1 ..< interestingSession.pages.count {
					window?.openTab(with: interestingSession.pages[i].url, makeActiveIfPossible: false, completionHandler: { _ in})
				}
				print("Session \"\(String(describing: interestingSession.name))\" restored - \(interestingSession.pages.count) tabs opened in PRIVATE mode")
			}
		} else {
			SFSafariApplication.openWindow(with: (interestingSession.pages.first!.url)) { (window) in
				for i in 1 ..< interestingSession.pages.count {
					window?.openTab(with: interestingSession.pages[i].url, makeActiveIfPossible: false, completionHandler: { (tab) in
					})
				}
			}
			print("Session \"\(String(describing: interestingSession.name))\" restored - \(interestingSession.pages.count) tabs opened")
		}
	}
	
	
	
}
