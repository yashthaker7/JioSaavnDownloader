//
//  TYIdentifiable.swift
//  JioSaavnDownloader
//
//  Created by Yash on 05/06/22.
//

import Foundation

protocol TYIdentifiable {
    static var identifier: String { get }
    var identifier: String { get }
}

extension TYIdentifiable {
    static var identifier: String {
        return String(describing: self)
    }
    var identifier: String {
        return String(describing: self)
    }
}

