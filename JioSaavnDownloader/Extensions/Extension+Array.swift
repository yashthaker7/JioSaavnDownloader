//
//  Extension+Array.swift
//  JioSaavnDownloader
//
//  Created by Yash on 05/06/22.
//

import Foundation

import Foundation

extension Collection where Indices.Iterator.Element == Index {
   public subscript(safe index: Index) -> Iterator.Element? {
     return (startIndex <= index && index < endIndex) ? self[index] : nil
   }
}
