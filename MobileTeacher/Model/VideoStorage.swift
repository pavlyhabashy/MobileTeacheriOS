//
//  VideoStorage.swift
//  MobileTeacher
//
//  Created by james oeth on 2/12/20.
//  Copyright © 2020 Pavly Habashy. All rights reserved.
//

//import UIKit
//
///// Saves and loads images to the file system.
//final class VideoStorage {
//    
//    private let fileManager: FileManager
//    private let path: String
//    
//    init(name: String, fileManager: FileManager = FileManager.default) throws {
//        self.fileManager = fileManager
//
//        let url = try fileManager.url(for: .cachesDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
//        let path = url.appendingPathComponent(name, isDirectory: true).path
//        self.path = path
//        
//        try createDirectory()
//        try setDirectoryAttributes([.protectionKey: FileProtectionType.complete])
//    }
//    
//    func setVideo(_ videoPath: NSURL, forKey key: String) throws {
//        var data:NSData
//        do {
//            data = try NSData(contentsOfURL: videoPath, options: .DataReadingMappedIfSafe)
//        } catch {
//           print(error)
//           return
//        }
//        let filePath = makeFilePath(for: key)
//        _ = fileManager.createFile(atPath: filePath, contents: data, attributes: nil)
//    }
//    //probably want to send back the url and give that the the avplayer
//    func video(forKey key: String) throws -> UIImage {
//        let filePath = makeFilePath(for: key)
//        let data = try Data(contentsOf: URL(fileURLWithPath: filePath))
//        guard let video = UIImage(data: data) else {
//            throw Error.invalidImage
//        }
//        return image
//    }
//}
//
//// MARK: - File System Helpers
//
//private extension VideoStorage {
//
//    func setDirectoryAttributes(_ attributes: [FileAttributeKey: Any]) throws {
//        try fileManager.setAttributes(attributes, ofItemAtPath: path)
//    }
//    
//    func makeFileName(for key: String) -> String {
//        let fileExtension = URL(fileURLWithPath: key).pathExtension
//        return fileExtension.isEmpty ? key : "\(key).\(fileExtension)"
//    }
//
//    func makeFilePath(for key: String) -> String {
//        return "\(path)/\(makeFileName(for: key))"
//    }
//    
//    func createDirectory() throws {
//        guard !fileManager.fileExists(atPath: path) else {
//            return
//        }
//        
//        try fileManager.createDirectory(atPath: path, withIntermediateDirectories: true, attributes: nil)
//    }
//}
//
//// MARK: - Error
//
//private extension VideoStorage {
//    
//    enum Error: Swift.Error {
//        case invalidImage
//    }
//}
