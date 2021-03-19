//
//  ViewController.swift
//  Sessions
//
//  Created by Alex Perathoner on 14/08/2019.
//  Copyright © 2019 Alex Perathoner. All rights reserved.
//

import Cocoa
import SafariServices.SFSafariApplication
import Sparkle

class ViewController: NSViewController {

    @IBOutlet var appNameLabel: NSTextField!
    
	@IBOutlet weak var lastCheckForUpdatesOutlet: NSTextField!
	
	override func viewDidLoad() {
        super.viewDidLoad()
		self.appNameLabel.stringValue = "Sessions"
		let formatter = DateFormatter()
		formatter.dateFormat = "dd MMM yyyy - HH:mm"
		lastCheckForUpdatesOutlet.stringValue = "Last check: " + formatter.string(from: SUUpdater.shared()?.lastUpdateCheckDate ?? Date())
    }
    
	@IBAction func checkForUpdates(_ sender: Any) {
		SUUpdater.shared()?.checkForUpdates(self)
	}
	
	@IBAction func openSafariExtensionPreferences(_ sender: AnyObject?) {
        SFSafariApplication.showPreferencesForExtension(withIdentifier: "AlexP.Sessions-Extensions") { error in
            if let _ = error {
				NSLog("Couldn't open Safari Preferences. Please enable the extension manually")
            }
        }
    }

}
