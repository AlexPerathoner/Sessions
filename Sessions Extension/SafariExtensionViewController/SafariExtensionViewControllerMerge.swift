//
//  SafariExtensionViewControllerMerge.swift
//  Sessions Extension
//
//  Created by Alex Perathoner on 28/02/2021.
//  Copyright © 2021 Alex Perathoner. All rights reserved.
//

import Cocoa

extension SafariExtensionViewController {
	
	func merge(s: [Session]) -> Session {
		var sessions = s
		let firstSess = sessions.removeFirst()
		var urls: [URL] = []
		for page in firstSess.pages {
			urls.append(page.url)
		}
		for item in sessions {
			for page in item.pages {
				if(!urls.contains(page.url)) {
					firstSess.pages.append(page)
				}
			}
		}
		return firstSess
	}
	
	
}
