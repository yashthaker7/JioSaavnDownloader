//
//  API.swift
//  JioSaavnDownloader
//
//  Created by Yash on 05/06/22.
//

import Foundation

enum APIBaseURLStr: String {
 
    case songDetails = "https://www.jiosaavn.com/api.php?__call=song.getDetails&cc=in&_marker=0%3F_marker%3D0&_format=json&pids="
    
    var urlStr: String { return rawValue }
}
