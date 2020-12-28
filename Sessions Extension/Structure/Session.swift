//
//  File.swift
//  Sessions Extension
//
//  Created by Alex Perathoner on 18/08/2019.
//  Copyright © 2019 Alex Perathoner. All rights reserved.
//

import Foundation


class Session: NSObject, NSCoding, Codable, NSSecureCoding {
	public var name: String
	public var pages: [WebPage]
	public var id: String //using string not int to solve compatibility issues that happened with the encoding operations
	public var isUpdating: Bool? = false
	
	required init(name:String, pages:[WebPage], id:String) {
		self.name = name
		self.pages = pages
		self.id = id
		isUpdating = false
		print("Created session \"\(name)\" with \(pages.count) tabs, id: \(id)")
		super.init()
	}
	
	//MARK: - NSCoding -
	required init(coder aDecoder: NSCoder) {
		name = aDecoder.decodeObject(forKey: "name") as! String
		pages = aDecoder.decodeObject(forKey: "pages") as! [WebPage]
		id = aDecoder.decodeObject(forKey: "id") as! String? ?? ""
		isUpdating = false
		if id == "" {
			print("id is nil, assigning new id")
			id = String(Int.random(in: 0..<Int.max))
		}
	}
	
	func encode(with aCoder: NSCoder) {
		aCoder.encode(name, forKey: "name")
		aCoder.encode(pages, forKey: "pages")
		aCoder.encode(id, forKey: "id")
	}
	
	static var supportsSecureCoding: Bool {
        return true
    }
}
