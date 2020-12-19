//
//  SafariExtensionViewControllerExport.swift
//  Sessions Extension
//
//  Created by Alex Perathoner on 19/12/2020.
//  Copyright © 2020 Alex Perathoner. All rights reserved.
//

import Cocoa

extension SafariExtensionViewController {
	
	// MARK: Export to file
	/// Gets a Session variable, converts it to a human readable String and saves everything to a path given by the user through a dialog. The created string is then returned
	/// - Parameter data: the variable of type Session that will be converted into a string
	/// - Parameter file: the name of the file where the string will be saved
	func encodeToJSONAndSaveTo(data: Session, file: String) -> String? {
		let encoder = JSONEncoder()
		encoder.outputFormatting = .prettyPrinted
		
		if let encodedData = try? encoder.encode(data) {
			//let path = FileManager.default.homeDirectoryForCurrentUser.appendingPathComponent("Library/Sessions/sessions.json")
			if let fileURL = askPath()?.appendingPathComponent(file + ".json") {
				//let fileURL = FileManager.default.homeDirectoryForCurrentUser.appendingPathComponent("Downloads").appendingPathComponent(file + ".json")
				
				var isDirectory: ObjCBool = false
				let fileManager = FileManager.default
				if !fileManager.fileExists(atPath: fileURL.path, isDirectory: &isDirectory) {
					let created = fileManager.createFile(atPath: fileURL.path, contents: nil, attributes: nil)
					if created {
						print("File created ")
					} else {
						print("Couldn't create file for some reason")
					}
				} else {
					print("File already exists")
				}
				do {
					try encodedData.write(to: fileURL)
					print("Wrote to file")
					NSWorkspace.shared.open(fileURL.deletingLastPathComponent())
				}
				catch {
					print("Failed to write JSON data: \(error.localizedDescription)")
				}
				return String(data: encodedData, encoding: .utf8)!
			}
		}
		return nil
	}
	
	func askPath() -> URL? {
		let dialog = NSOpenPanel();
		
		dialog.title                   = "Choose a folder to save the file"
		dialog.directoryURL			= FileManager.default.homeDirectoryForCurrentUser.appendingPathComponent("Downloads")
		dialog.showsResizeIndicator    = true
		dialog.showsHiddenFiles        = false
		dialog.canCreateDirectories    = true
		dialog.canChooseFiles = 		false
		dialog.canChooseDirectories = true

		if (dialog.runModal() == NSApplication.ModalResponse.OK) {
			let result = dialog.url // Pathname of the file
			return result
		} else {
			// User clicked on "Cancel"
			return nil
		}
	}
	
}
