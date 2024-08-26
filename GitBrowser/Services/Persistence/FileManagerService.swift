//
//  FileManagerService.swift
//  GitBrowser
//
//  Created by Nibin Varghese on 2024/08/25.
//

import Foundation

class FileManagerService {
    
    private static let plistFileName = "Keys"
    
    func getTokenFromPlist(fileName: String = plistFileName) -> String? {
        guard let token = readTokenFromPlist(fileName: fileName) else {
            return nil
        }
        
        return token
    }
    
    private func readTokenFromPlist(fileName: String) -> String? {
        guard let plistPath = Bundle.main.path(forResource: fileName, ofType: "plist"),
              let plistData = FileManager.default.contents(atPath: plistPath),
              let plistDict = try? PropertyListSerialization.propertyList(from: plistData, format: nil) as? [String: AnyObject],
              let token = plistDict["AccessToken"] as? String else {
            return nil
        }
        return token
    }
}
