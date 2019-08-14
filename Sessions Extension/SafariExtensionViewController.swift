//
//  SafariExtensionViewController.swift
//  Sessions Extension
//
//  Created by Alex Perathoner on 14/08/2019.
//  Copyright © 2019 Alex Perathoner. All rights reserved.
//

import SafariServices

class SafariExtensionViewController: SFSafariExtensionViewController {
    
    static let shared: SafariExtensionViewController = {
        let shared = SafariExtensionViewController()
        shared.preferredContentSize = NSSize(width:320, height:240)
        return shared
    }()

}
