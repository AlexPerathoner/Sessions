//
//  SafariExtensionViewController.swift
//  Sessions Extension
//
//  Created by Alex Perathoner on 14/08/2019.
//  Copyright © 2019 Alex Perathoner. All rights reserved.
//

import SafariServices
import AppKit

class SafariExtensionViewController: SFSafariExtensionViewController, NSTableViewDelegate, NSTableViewDataSource, NSControlTextEditingDelegate, NSSearchFieldDelegate {
	
    static let shared = SafariExtensionViewController()
	var sessions = [Session]() {
		didSet {
			print("Value changed - Now \(sessions.count) sessions")
			saveSessions(session: sessions) //saves to userdefaults
			tableView.reloadData()
		}
	}
	var filteredSessions = [Session]()
    //static let sessions = [[Webpage]]()
 
	@IBOutlet weak var tableView: NSTableView!
	@IBOutlet weak var searchField: NSSearchField!
	var isSearching = false
	
	override func viewDidLoad() {
		super.viewDidLoad()
        preferredContentSize = NSSize(width: 232, height: 290)
		self.tableView.delegate = self
		self.tableView.dataSource = self
		self.searchField.delegate = self
		if let r: [Session] = retrieveSession() {
			print("Sessions retrieved")
			sessions = r
			filteredSessions = r
		}
		tableView.doubleAction = #selector(tableDoubleClick(_:)) //item of table clicked
    }
	
	@objc func tableDoubleClick(_ sender: Any?) {
		restoreSession(index: tableView.selectedRow) //gets index of item clicked
	}
	
	
	func retrieveSession() -> [Session]? {
		if let unarchivedObject = UserDefaults.standard.object(forKey: "pages") as? NSData {
			// MARK: TODO - Deprecated, should be updated
			//return NSKeyedUnarchiver.unarchivedObject(ofClasses: .init(arrayLiteral: Session.self), from: unarchivedObject as Data) as? [Session]
			
			do {
				return try (NSKeyedUnarchiver.unarchivedObject(ofClasses: [Session.self, NSArray.self, WebPage.self, NSURL.self], from: unarchivedObject as Data) as? [Session])
			} catch {
			   print("Error: \(error)")
			}
			
			//return NSKeyedUnarchiver.unarchiveObject(with: unarchivedObject as Data) as? [Session]
		}
		return nil
	}
	
	
    func getProp(page: SFSafariPage?, completion: @escaping (String?, URL?, Bool?) -> ()) {
        page?.getPropertiesWithCompletionHandler({ (p) in
            if let properties = p {
                let title = properties.title
				let privat = properties.usesPrivateBrowsing
                if let url = properties.url {
                    completion(title, url, privat)
                    return
                }
            }
            completion(nil, nil, nil)
        })
    }
    
    func getPage(tab: SFSafariTab, completion: @escaping ((String?, URL?, Bool?)) -> ()) {
        tab.getActivePage(completionHandler: { (page) in
            var titleT: String?
            var urlT: URL?
			var privatT: Bool?
            self.getProp(page: page, completion: { (title, url, privat) in
                titleT = title
                urlT = url
				privatT = privat
                DispatchQueue.main.async {
                    completion((titleT, urlT, privatT))
                }
            })
        })
    }
    func getTabs(completion: @escaping ([WebPage]) -> ()) {
        var pages = [WebPage]()
        SFSafariApplication.getActiveWindow { (window) in //get safari window
            window?.getAllTabs(completionHandler: { (tabs) in // as the method to get the active windows is on another dispatchqueue we need to invoke it in this way
                for tab in tabs {
                    var pageT: WebPage?
                    self.getPage(tab: tab, completion: { (title, u, privat) in //method to get title, url and private condition for every page in the actual tab
                        if let url = u {
                            pageT = WebPage(title: title ?? "", url: url, privat: privat ?? false)
                            DispatchQueue.main.async {
                                pages.append(pageT!)
                                if(tabs.firstIndex(of: tab)! + 1 == tabs.count) { //last tab
                                    completion(pages)
									return
                                }
                            }
                        }
						completion([]) //no pages
                    })
                }
            })
        }
    }
	
	func archiveSessions(sessions: [Session]) -> NSData? {
		do {
			let archivedObject = try NSKeyedArchiver.archivedData(withRootObject: sessions, requiringSecureCoding: false)
			return archivedObject as NSData
		} catch let error {
			print("Unspecified Error: \(error)")
		}
		return nil
	}
	
	func saveSessions(session: [Session]) {
		let archivedObject = archiveSessions(sessions: session)
		let defaults = UserDefaults.standard
		defaults.set(archivedObject, forKey: "pages")
		defaults.synchronize()
	}
	
	func idUsed(id: String) -> Bool {
		for i in self.sessions {
			if i.id == id {
				return true
			}
		}
		return false
	}
	func generateId() -> String {
		var id: Int = 0
		var alreadyUsedId = true
		while(alreadyUsedId) {
			id = Int.random(in: 0..<Int.max) //generates a not already used id
			alreadyUsedId = idUsed(id: String(id))
		}
		print("Generated id \(id)")
		return String(id)
	}
	
    @IBAction func addSession(_ sender: Any) {
//		encodeToJSONAndSaveTo(file: "sessions.json")
		self.getTabs { (actTabs) in
			if actTabs.count > 0 {
//				let dateFormatter = DateFormatter()
//				dateFormatter.dateFormat = "dd/MM - h:mm"
//				let name = DateFormatter().string(from: Date())
				
//				var name = actTabs.first!.url.absoluteString
//				name.removeSubrange(name.startIndex..<name.firstIndex(of: ".")!)
//				name.removeFirst()
//				name.removeSubrange(name.firstIndex(of: ".")!..<name.endIndex)
				
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
	
	
	func numberOfRows(in tableView: NSTableView) -> Int {
		if(isSearching) {
			return filteredSessions.count
		}
		return sessions.count
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
			filteredSessions = sessions
		}
		tableView.reloadData()
	}
	
	
	func tableView(_ tableView: NSTableView, objectValueFor tableColumn: NSTableColumn?, row: Int) -> Any?
	{
		var item: Session
		if(isSearching) {
			item = (filteredSessions)[row]
		} else {
			item = (sessions)[row]
		}
		return item.name
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
	
	@IBAction func options(_ sender: Any) {
		indexClicked = tableView.row(for: sender as! NSView)
		meeenu.popUp(positioning: meeenu.item(at: 0), at: NSEvent.mouseLocation, in: nil)
	}
	
	@IBAction func restoreMenuItem(sender: NSMenuItem) {
		if(indexClicked == -1) { return }
		restoreSession(index: indexClicked)
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
	
	func restoreSession(index: Int) {
		var interestingSession: Session
		if(isSearching) {
			interestingSession = filteredSessions[index]
		} else {
			interestingSession = sessions[index]
		}
		//opens new window with first url, removes first item from list and opens other urls in new tabs
		 //interestingSession.pages.first!.privat
		
		
		SFSafariApplication.openWindow(with: (interestingSession.pages.first!.url)) { (window) in
			for i in 1 ..< interestingSession.pages.count {
				window?.openTab(with: interestingSession.pages[i].url, makeActiveIfPossible: false, completionHandler: { (tab) in
				})
			}
		}
		
		print("Session \"\(String(describing: interestingSession.name))\" restored - \(interestingSession.pages.count) tabs opened")
	}
//
//	@IBAction func restoreSession(_ sender: Any) {
//		let index = tableView.row(for: sender as! NSView)
//		restoreSession(index: index)
//
//	}
//
//
	
	/// Gets a Session variable, converts it to a human readable String and saves everything to a path given by the user through a dialog. The created string is then returned
	/// - Parameter data: the variable of type Session that will be converted into a string
	/// - Parameter file: the name of the file where the string will be saved
	func encodeToJSONAndSaveTo(data: Session, file: String) -> String? {
		let encoder = JSONEncoder()
		encoder.outputFormatting = .prettyPrinted
		
		if let encodedData = try? encoder.encode(data) {
			//let path = FileManager.default.homeDirectoryForCurrentUser.appendingPathComponent("Library/Sessions/sessions.json")
			//let path = askPath()?.appendingPathComponent(file + ".json")
			let path = FileManager.default.homeDirectoryForCurrentUser.appendingPathComponent("Downloads").appendingPathComponent(file + ".json")
			
			var isDirectory: ObjCBool = false
			let fileManager = FileManager.default
			if !fileManager.fileExists(atPath: path.path, isDirectory: &isDirectory) {
				let created = fileManager.createFile(atPath: path.path, contents: nil, attributes: nil)
				if created {
					print("File created ")
				} else {
					print("Couldn't create file for some reason")
				}
			} else {
				print("File already exists")
			}
			do {
				try encodedData.write(to: path)
				print("Wrote to file")
				//NSWorkspace.shared.open(FileManager.default.homeDirectoryForCurrentUser.appendingPathComponent("Downloads"))
				// MARK:  TODO: open folder the file was saved to
				NSWorkspace.shared.openFile(path.path) // opens json file
			}
			catch {
				print("Failed to write JSON data: \(error.localizedDescription)")
			}
			return String(data: encodedData, encoding: .utf8)!
		}
		return nil
	}
	
	func askPath() -> URL? {
		let dialog = NSOpenPanel();
		
		dialog.title                   = "Choose a folder to save the file"
		dialog.directoryURL			= FileManager.default.homeDirectoryForCurrentUser.appendingPathComponent("Downloads")
		dialog.showsResizeIndicator    = true
		dialog.showsHiddenFiles        = false
		dialog.canCreateDirectories    = true
		dialog.canChooseFiles = 		false
		dialog.canChooseDirectories = true

		if (dialog.runModal() == NSApplication.ModalResponse.OK) {
			let result = dialog.url // Pathname of the file
			return result
		} else {
			// User clicked on "Cancel"
			return nil
		}
	}
	
	
	
}
