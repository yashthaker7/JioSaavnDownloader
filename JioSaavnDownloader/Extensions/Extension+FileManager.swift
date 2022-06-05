//
//  Extension+FileManager.swift
//  JioSaavnDownloader
//
//  Created by Yash on 05/06/22.
//

import UIKit

extension FileManager {
    
    var documentDirectory: URL {
        return urls(for: .documentDirectory, in: .userDomainMask).first!
    }
    
    func createURLInDD(_ name: String) -> URL {
        return documentDirectory.appendingPathComponent(name)
    }
    
    func removeFileIfExists(_ fileURL: URL) {
        guard fileExists(atPath: fileURL.path) else { return }
        do {
            try removeItem(at: fileURL)
            print(fileURL.lastPathComponent, " file removed.")
        } catch {
            print("Could not delete file at \(fileURL)")
        }
    }
    
    func getAllFilesFromDD() -> [URL] {
        do {
            let files = try self.contentsOfDirectory(at: documentDirectory, includingPropertiesForKeys: nil)
            return files
        } catch {
            print(error.localizedDescription)
        }
        return []
    }
    
    func removeAllFilesFromDD() {
        do {
            let files = try self.contentsOfDirectory(atPath: documentDirectory.path)
            for file in files {
                let filePath = URL(fileURLWithPath: documentDirectory.path).appendingPathComponent(file).absoluteURL
                try removeItem(at: filePath)
            }
        } catch {
            print(error.localizedDescription)
        }
    }
}

extension URL {
    
    func nameWithoutExtension() -> String {
        return self.deletingPathExtension().lastPathComponent
    }
}
