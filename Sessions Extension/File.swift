//
//  File.swift
//  Sessions Extension
//
//  Created by Alex Perathoner on 18/08/2019.
//  Copyright © 2019 Alex Perathoner. All rights reserved.
//

import Foundation

class Session: NSObject, NSCoding, Codable {
	var name: String
	var pages: [WebPage]
	var id: Int?
	
	required init(name:String, pages:[WebPage], id:Int) {
		self.name = name
		self.pages = pages
		self.id = id
		print("Created session \"\(name)\" with \(pages.count) tabs, id: \(id)")
		super.init()
	}
	
	public func changeName(name:String) -> String {
		let oldName = self.name
		self.name = name
		return oldName
	}
	
	//MARK: - NSCoding -
	required init(coder aDecoder: NSCoder) {
		name = aDecoder.decodeObject(forKey: "name") as! String
		pages = aDecoder.decodeObject(forKey: "pages") as! [WebPage]
		id = aDecoder.decodeObject(forKey: "id") as! Int?
		if id == nil {
			print("id is nil, assigning new id")
			id = Int.random(in: 0..<Int.max)
		}
	}
	
	func encode(with aCoder: NSCoder) {
		aCoder.encode(name, forKey: "name")
		aCoder.encode(pages, forKey: "pages")
		aCoder.encode(id, forKey: "id")
	}
}

class WebPage: NSObject, NSCoding, Codable {
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
		title = aDecoder.decodeObject(forKey: "title") as! String
		url = aDecoder.decodeObject(forKey: "url") as! URL
		privat = aDecoder.decodeObject(forKey: "privat") as? Bool ?? false
	}
	
	func encode(with aCoder: NSCoder) {
		aCoder.encode(title, forKey: "title")
		aCoder.encode(url, forKey: "url")
		aCoder.encode(privat, forKey: "privat")
	}
}
