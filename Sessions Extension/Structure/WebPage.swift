//
//  WebPage.swift
//  Sessions Extension
//
//  Created by Alex Perathoner on 25/11/2019.
//  Copyright © 2019 Alex Perathoner. All rights reserved.
//

import Foundation

class WebPage: NSObject, NSCoding, Codable, NSSecureCoding {
	let title: String
	let url: URL
	let privat: Bool
	
	required init(title:String, url:URL, privat:Bool) {
		self.title = title
		self.url = url
		self.privat = privat
		super.init()
	}
	
	//MARK: - NSCoding -
	required init(coder aDecoder: NSCoder) {
		title = aDecoder.decodeObject(forKey: "title") as? String ?? ""
		url = aDecoder.decodeObject(forKey: "url") as? URL ?? URL(fileURLWithPath: "/")
		privat = aDecoder.decodeBool(forKey: "privat")
	}
	
	func encode(with aCoder: NSCoder) {
		aCoder.encode(title, forKey: "title")
		aCoder.encode(url, forKey: "url")
		aCoder.encode(privat, forKey: "privat")
	}
	
	static var supportsSecureCoding: Bool {
        return true
    }
}
