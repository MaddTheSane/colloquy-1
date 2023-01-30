//
//  ImportExtension.swift
//  newMD
//
//  Created by C.W. Betts on 1/30/23.
//  Copyright © 2023 Colloquy Project. All rights reserved.
//

import CoreSpotlight
import libxml2.parser
import libxml2.xmlerror

private let coverageFormatter: DateFormatter = {
	let formatter = DateFormatter()
	formatter.formatterBehavior = .behavior10_4
	formatter.dateStyle = .short
	formatter.timeStyle = .short
	return formatter
}()

private class JVChatTranscriptMetadataExtractor: NSObject, XMLParserDelegate {
	var content: String
	var participants: Set<String>
	
	private var inEnvelope = false
	private var inMessage = false
	private var dateStarted: Date? = nil
	private var lastEventDate: String? = nil
	private var source: String? = nil
	private var lastElement: String? = nil

	init(capacity: Int) {
		content = String()
		content.reserveCapacity(capacity)
		participants = Set<String>()
		participants.reserveCapacity(400)
		
		super.init()
	}
	
	convenience override init() {
		self.init(capacity: 40)
	}
	
	func writeMetadata(to attributeSet: CSSearchableItemAttributeSet) {
		attributeSet.textContent = content
		if let dateStarted {
			attributeSet.contentCreationDate = dateStarted
		}
		if let lastEventDate, let lastDate = dateFrom(lastEventDate) {
			attributeSet.contentModificationDate = lastDate
			attributeSet.lastUsedDate = lastDate

			if let dateStarted {
				// Set Duration
				let logDuration = lastDate.timeIntervalSince(dateStarted)
				attributeSet.duration = (logDuration) as NSNumber
				
				// Set Coverage
				let coverageWording = "\(coverageFormatter.string(from: dateStarted)) - \(coverageFormatter.string(from: lastDate))"
				attributeSet.coverage = [coverageWording]
			}
		}
		
		if !participants.isEmpty {
			attributeSet.contributors = Array(participants)
		}
		if let source, !source.isEmpty {
			attributeSet.contentSources = [source]
		}
		
		attributeSet.kind = "transcript"
		attributeSet.creator = "Colloquy"
	}
	
	// MARK: - XMLParserDelegate
	
	func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String] = [:]) {
		lastElement = elementName
		if elementName == "envelope" {
			inEnvelope = true
		} else if inEnvelope, elementName == "message" {
			inMessage = true
			if let date = attributeDict["received"] {
				lastEventDate = date
				if dateStarted == nil {
					dateStarted = dateFrom(date)
				}
			}
		} else if !inEnvelope, elementName == "event" {
			if let date = attributeDict["occurred"] {
				lastEventDate = date
				if dateStarted == nil {
					dateStarted = dateFrom(date)
				}
			}
		} else if !inEnvelope, elementName == "log" {
			if let date = attributeDict["began"] {
				if dateStarted == nil {
					dateStarted = dateFrom(date)
				}
			}
			if source == nil {
				source = attributeDict["source"]
			}
		}
	}
	
	func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
		if inEnvelope, elementName == "envelope" {
			inEnvelope = false
		} else if inEnvelope, inMessage, elementName == "message" {
			inMessage = false
			content.append("\n")
		}
		
		lastElement = nil
	}
	
	func parser(_ parser: XMLParser, foundCharacters string: String) {
		if inEnvelope, inMessage {
			let newString = string.trimmingCharacters(in: .newlines)
			if !newString.isEmpty {
				content.append(newString)
			}
		} else if inEnvelope, lastElement == "sender" {
			if !string.isEmpty {
				participants.insert(string)
			}
		}
	}
}

class ImportExtension: CSImportExtension {
    
    override func update(_ attributes: CSSearchableItemAttributeSet, forFileAt: URL) throws {
		guard let parser = XMLParser(contentsOf: forFileAt) else {
			throw CocoaError(.fileReadUnknown, userInfo: [NSURLErrorKey: forFileAt])
		}
		
		let resVals = try forFileAt.resourceValues(forKeys: [.fileSizeKey])
		let fileSize = resVals.fileSize ?? 15000
		
		// the message content takes up about a third of the XML file's size
		let capacity = Int(fileSize / 3)
		let extractor = JVChatTranscriptMetadataExtractor(capacity: capacity)
		
		parser.delegate = extractor
		guard parser.parse() else {
			throw parser.parserError!
		}
		
		extractor.writeMetadata(to: attributes)
		
		xmlSetStructuredErrorFunc(nil, nil)
    }
    
}
