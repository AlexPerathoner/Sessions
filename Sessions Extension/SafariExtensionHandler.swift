//
//  SafariExtensionHandler.swift
//  Sessions Extension
//
//  Created by Alex Perathoner on 14/08/2019.
//  Copyright © 2019 Alex Perathoner. All rights reserved.


import SafariServices
import os.log

class SafariExtensionHandler: SFSafariExtensionHandler {
    
    
    override func toolbarItemClicked(in window: SFSafariWindow) {
        // This method will be called when your toolbar item is clicked.
        NSLog("The extension's toolbar item was clicked")
    }
    
    override func validateToolbarItem(in window: SFSafariWindow, validationHandler: @escaping ((Bool, String) -> Void)) {
        // This is called when Safari's state changed in some way that would require the extension's toolbar item to be validated again.

        validationHandler(true, "")
    }
	
	override func popoverViewController() -> SFSafariExtensionViewController {
        os_log(.error, "showing popup")
		return SafariExtensionViewController.shared
	}
	
}
