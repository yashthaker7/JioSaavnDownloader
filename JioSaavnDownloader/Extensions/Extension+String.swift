//
//  Extension+String.swift
//  JioSaavnDownloader
//
//  Created by Yash on 05/06/22.
//

import Foundation

extension String {
    
    var trimmingWhiteSpaces: String {
        return self.trimmingCharacters(in: .whitespacesAndNewlines)
    }
}
