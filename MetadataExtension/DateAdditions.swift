//
//  DateAdditions.swift
//  Colloquy (Metadata Extension)
//
//  Created by C.W. Betts on 1/30/23.
//  Copyright © 2023 Colloquy Project. All rights reserved.
//

import Foundation

private let dateFormatter: DateFormatter = {
	let aDateFormatter = DateFormatter()
	aDateFormatter.dateFormat = "yyyy-MM-DD HH:mm:ss ZZZZZ"
	return aDateFormatter
}()

internal func dateFrom(_ str: String) -> Date? {
	return dateFormatter.date(from: str)
}
