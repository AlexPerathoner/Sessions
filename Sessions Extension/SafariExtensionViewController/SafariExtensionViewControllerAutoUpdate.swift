//
//  SafariExtensionViewControllerAutoUpdate.swift
//  Sessions Extension
//
//  Created by Alex Perathoner on 28/12/2020.
//  Copyright © 2020 Alex Perathoner. All rights reserved.
//

import Cocoa
import SafariServices

extension SafariExtensionViewController {
	
	
	@IBAction func restoreAndAutoUpdateClicked(_ sender: Any) {
		let index = tableView.clickedRow
		restoreAndAutoUpdate(sender, index: index)
	}
	
	func restoreAndAutoUpdate(_ sender: Any, index: Int) {
		//manually setting updated image performs better than reloading the entire table
		statusImage = tableView.view(atColumn: 1, row: index, makeIfNecessary: false) as? NSImageView
		statusImage?.image = NSImage(named: "NSStatusAvailable")
		sessions[index].isUpdating = true
		
		restoreSession(index: index, asPrivate: false) { (window) in
			DispatchQueue.main.sync {
				self.timer = Timer.scheduledTimer(timeInterval: 10.0, target: self, selector: #selector(self.fireTimer), userInfo: (window, index), repeats: true)
				self.timer?.tolerance = 2
				
				RunLoop.main.add(self.timer!, forMode: .common)
			}
		}
	}
	
	
	@objc func fireTimer(timer: Timer) {
		guard let info = timer.userInfo as? (SFSafariWindow?, Int) else { return }
		let window = info.0
		let index = info.1
		let id = sessions[index].id
		getTabs(window: window) { (pages) in
			print("Session \(id) has now \(pages.count) tabs - will update ...")
			guard pages.count > 0 else { //window has been closed
				timer.invalidate() //stopping to auto-update
				self.deleteTimer?.invalidate() //not updating session if tabs have been removed in the last 10 seconds
				//has to access through id - index could have changed
				self.getSession(id: id)?.isUpdating = false
				
				DispatchQueue.main.async {
					//update table
					self.tableView.reloadData()
				}
				
				print("Window with session \(id) was closed. Stopped updating.")
				return
			}
			
			//tabs are removed x seconds after
			self.deleteTimer?.invalidate()
			self.deleteTimer = Timer.scheduledTimer(withTimeInterval: 30, repeats: false, block: { (deleteTimer) in
				self.replacePagesInSession(id: id, pages: pages)
				print("Updaetd session \(id) - \(pages.count) tabs saved")
			})
		}
	}
}
