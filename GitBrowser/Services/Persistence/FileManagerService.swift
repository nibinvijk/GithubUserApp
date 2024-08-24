//
//  FileManagerService.swift
//  GitBrowser
//
//  Created by Nibin Varghese on 2024/08/25.
//

import Foundation

class FileManagerService {
    
    private let plistFileName = "Keys"
    
    func getTokenFromPlist() -> String? {
        guard let token = readTokenFromPlist() else {
            return nil
        }
        
        return token
    }
    
    private func readTokenFromPlist() -> String? {
        guard let plistPath = Bundle.main.path(forResource: plistFileName, ofType: "plist"),
              let plistData = FileManager.default.contents(atPath: plistPath),
              let plistDict = try? PropertyListSerialization.propertyList(from: plistData, format: nil) as? [String: AnyObject],
              let token = plistDict["AccessToken"] as? String else {
            return nil
        }
        return token
    }
}
