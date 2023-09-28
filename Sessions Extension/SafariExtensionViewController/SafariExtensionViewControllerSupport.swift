//
//  SafariExtensionViewControllerSupport.swift
//  Sessions Extension
//
//  Created by Alex Perathoner on 19/12/2020.
//  Copyright © 2020 Alex Perathoner. All rights reserved.
//

import Cocoa
import SafariServices

extension SafariExtensionViewController {
	// MARK: - Userdefaults
	
	func retrieveSession() -> [Session]? {
        NSLog("Try to retrieve session...")
		if let unarchivedObject = UserDefaults.standard.object(forKey: "pages") as? NSData {
			do {
				return try (NSKeyedUnarchiver.unarchivedObject(ofClasses: [Session.self, NSArray.self, WebPage.self, NSURL.self], from: unarchivedObject as Data) as? [Session])
			} catch {
                NSLog("Error!")
			   print("Error: \(error)")
			}
		}
        NSLog("Returning nil...")
		return nil
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
        NSLog("save sessions0")
		let archivedObject = archiveSessions(sessions: session)
        NSLog("save sessions1")
		let defaults = UserDefaults.standard
        NSLog("save sessions2")
		defaults.set(archivedObject, forKey: "pages")
        NSLog("save sessions3")
		defaults.synchronize()
        NSLog("save sessions4")
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
	
	// MARK: - miscellaneous
	func isSessionsPrivate(index: Int) -> Bool {
		var interestingSession: Session
		if(isSearching) {
			interestingSession = filteredSessions[index]
		} else {
			interestingSession = sessions[index]
		}
		let we: WebPage = interestingSession.pages.first!
		return we.privat
	}
	
	
	func readPrivileges(prompt: Bool) -> Bool {
		let options: NSDictionary = [kAXTrustedCheckOptionPrompt.takeRetainedValue() as NSString: prompt]
		let status = AXIsProcessTrustedWithOptions(options)
		//print("Reading Accessibility privileges - Current access status " + String(status))
		return status
	}
	
	
	// MARK: - safari methods
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
	func getTabs(window: SFSafariWindow?, completion: @escaping ([WebPage]) -> ()) {
		var pages = [WebPage]()
		let shouldIgnorePinnedTabs = UserDefaults.standard.bool(forKey: Constants.ignoringPinned)
		window?.getAllTabs(completionHandler: { (tabs) in // as the method to get the active windows is on another dispatchqueue we need to invoke it in this way
			guard tabs.count > 0 else {
				completion([])
				return
			}
			for tab in tabs {
				tab.getContainingWindow { (containerWindow) in //checking if tab is pinned: https://stackoverflow.com/questions/63509871/check-if-tab-page-is-pinned-in-safari-app-extension
					if((containerWindow != nil) || shouldIgnorePinnedTabs) {
						//Tab is not pinned
						self.getPage(tab: tab, completion: { (title, u, privat) in //method to get title, url and private condition for every page in the actual tab
							if let url = u {
								let pageT = WebPage(title: title ?? "", url: url, privat: privat ?? false)
								DispatchQueue.main.async {
									pages.append(pageT)
									if(tabs.firstIndex(of: tab)! + 1 == tabs.count) { //last tab
										completion(pages)
										return
									}
								}
							}
						})
					} else {
						//Tab is pinned!
						print("Tab was pinned... ignoring")
					}
				}
			}
		})
		
	}
	
	
	
	func restoreSession(index: Int, asPrivate: Bool, completion: ((SFSafariWindow?) -> ())? = nil) {
		guard index != -1 else {
			return
		}
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
				completion?(window)
			}
		} else {
            NSLog("Opening new window...")
			SFSafariApplication.openWindow(with: (interestingSession.pages.first!.url)) { (window) in
				for i in 1 ..< interestingSession.pages.count {
                    NSLog("opening tab...")
					window?.openTab(with: interestingSession.pages[i].url, makeActiveIfPossible: false, completionHandler: { (tab) in
					})
				}
				print("Session \"\(String(describing: interestingSession.name))\" restored - \(interestingSession.pages.count) tabs opened")
				completion?(window)
			}
		}
	}
	
	func getSession(id: String) -> Session? {
		for session in sessions {
			if(session.id == id) {
				return session
			}
		}
		return nil
	}
	
	func replacePagesInSession(id: String, pages: [WebPage]) {
		if let session = getSession(id: id) {
			session.pages = pages
		}
	}
	
	func replacePagesInSession(index: Int, pages: [WebPage]) {
		self.sessions[index].pages = pages
	}
}
