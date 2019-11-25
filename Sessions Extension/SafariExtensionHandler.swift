//
//  SafariExtensionHandler.swift
//  Sessions Extension
//
//  Created by Alex Perathoner on 14/08/2019.
//  Copyright © 2019 Alex Perathoner. All rights reserved.
//

import SafariServices

class SafariExtensionHandler: SFSafariExtensionHandler {
    
    override func messageReceived(withName messageName: String, from page: SFSafariPage, userInfo: [String : Any]?) {
        // This method will be called when a content script provided by your extension calls safari.extension.dispatchMessage("message").
        page.getPropertiesWithCompletionHandler { properties in
//            print("hey \(properties?.url) \(properties?.title)")
        }
        
    }
    
    override func toolbarItemClicked(in window: SFSafariWindow) {
        // This method will be called when your toolbar item is clicked.
        NSLog("The extension's toolbar item was clicked")
    }
    
    override func validateToolbarItem(in window: SFSafariWindow, validationHandler: @escaping ((Bool, String) -> Void)) {
        // This is called when Safari's state changed in some way that would require the extension's toolbar item to be validated again.

        validationHandler(true, "")
    }
	
	override func popoverViewController() -> SFSafariExtensionViewController {
		return SafariExtensionViewController.shared
	}
	
	
    
//    override func popoverWillShow(in window: SFSafariWindow) {
//        window.get
//        window.getActiveTab { (t) in
//            t?.getActivePage(completionHandler: { (d) in
//                d?.getPropertiesWithCompletionHandler({ (g) in
//                    print(g?.url)
//                })
//            })
//        }
//        
//    }

//    func getTabs() -> [SFSafariTab] {
//
//
//
//    }
    
}
